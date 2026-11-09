// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';

class StoryDraftImageRow extends StatefulWidget {
  const StoryDraftImageRow({
    super.key,
    this.width,
    this.height,
    required this.onImageTap,
  });

  final double? width;
  final double? height;
  final Future Function() onImageTap;

  @override
  State<StoryDraftImageRow> createState() => _StoryDraftImageRowState();
}

class _StoryDraftImageRowState extends State<StoryDraftImageRow> {
  late PageController _pageController;
  int _currentPage = 0;
  final Map<int, TextEditingController> _captionControllers = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _captionControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(int index, String initialText) {
    return _captionControllers.putIfAbsent(
      index,
      () => TextEditingController(text: initialText),
    );
  }

  void _updateCaption(int index, String value) {
    final captions = List<String>.from(FFAppState().storyDraftCaptions);
    if (index < captions.length) {
      captions[index] = value;
      FFAppState().storyDraftCaptions = captions;
    }
  }

  void _toggleCarousel(int index) {
    final flags = List<bool>.from(FFAppState().storyDraftCarousel);
    while (flags.length <= index) {
      flags.add(false);
    }
    flags[index] = !flags[index];
    FFAppState().storyDraftCarousel = flags;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FFAppState(),
      builder: (context, _) {
        final originals = FFAppState().storyDraftOriginalImages;
        final edited = FFAppState().storyDraftEditedImages;
        final captions = FFAppState().storyDraftCaptions;
        final carousel = FFAppState().storyDraftCarousel;

        if (originals.isEmpty) {
          return SizedBox(width: widget.width, height: widget.height);
        }

        if (_currentPage >= originals.length) {
          _currentPage = 0;
        }

        final totalHeight = widget.height ?? 430.0;
        final imgHeight = totalHeight - 90;

        return SizedBox(
          width: widget.width,
          height: totalHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: imgHeight,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: originals.length,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (context, i) {
                    final useEdited = i < edited.length && edited[i].isNotEmpty;
                    final base64Str = useEdited ? edited[i] : originals[i];
                    final bytes = base64Decode(base64Str);
                    final isInCarousel = i < carousel.length && carousel[i];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: InkWell(
                        onTap: () {
                          FFAppState().storyDraftEditingIndex = i;
                          widget.onImageTap();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: useEdited
                                  ? const Color(0xFF935CCC)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(bytes, fit: BoxFit.cover),
                                Positioned(
                                  left: 10,
                                  bottom: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.55),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.image_outlined,
                                            color: Colors.white, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${i + 1}/${originals.length}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (useEdited)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF935CCC),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.check,
                                          color: Colors.white, size: 13),
                                    ),
                                  ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: InkWell(
                                    onTap: () => _toggleCarousel(i),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isInCarousel
                                            ? const Color(0xFF935CCC)
                                            : Colors.black.withOpacity(0.35),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: isInCarousel
                                          ? const Icon(Icons.check,
                                              color: Colors.white, size: 16)
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IndexedStack(
                    index: _currentPage,
                    children: List.generate(originals.length, (i) {
                      final initialText =
                          i < captions.length ? captions[i] : '';
                      return TextField(
                        controller: _controllerFor(i, initialText),
                        onChanged: (value) => _updateCaption(i, value),
                        maxLength: 300,
                        decoration: const InputDecoration(
                          hintText: 'Write a caption...',
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
