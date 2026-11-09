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

import '/custom_code/actions/index.dart' as actions;

class MediaQualitySettings extends StatefulWidget {
  const MediaQualitySettings({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<MediaQualitySettings> createState() => _MediaQualitySettingsState();
}

class _MediaQualitySettingsState extends State<MediaQualitySettings> {
  String _value = 'hd';
  bool _loaded = false;

  Color get _green => FlutterFlowTheme.of(context).primary;

  static const _options = [
    {
      'key': 'standard',
      'title': 'Standard quality',
      'desc':
          'Smaller files. Uploads fast and uses less data. Photos up to 1280px.',
    },
    {
      'key': 'hd',
      'title': 'HD quality',
      'desc': 'Recommended. Sharp photos up to 2560px and high quality video.',
    },
    {
      'key': 'original',
      'title': 'Original quality',
      'desc':
          'No resizing. Photos and videos keep their full resolution. Uses the most data.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await actions.mediaQualityPreference('');
    if (!mounted) return;
    setState(() {
      _value = v;
      _loaded = true;
    });
  }

  Future<void> _pick(String key) async {
    setState(() => _value = key);
    await actions.mediaQualityPreference(key);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose the quality used when you send photos and videos in chats and post stories.',
            style:
                TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4),
          ),
          const SizedBox(height: 14),
          for (final o in _options)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _pick(o['key']!),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          _value == o['key'] ? _green : const Color(0xFFE5E7EB),
                      width: _value == o['key'] ? 1.8 : 1,
                    ),
                    color: _value == o['key']
                        ? _green.withOpacity(0.06)
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              o['title']!,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              o['desc']!,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF6B7280),
                                  height: 1.35),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        _value == o['key']
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: _value == o['key']
                            ? _green
                            : const Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 4),
          const Text(
            'Applies to new photos, videos and stories you send from this device.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
