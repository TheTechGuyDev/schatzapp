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

import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

/// True where the floating glass nav is used: iPhone/iPad and the web.
/// Android keeps the original bottom TabBar.
bool useGlassNavBar() =>
    kIsWeb || defaultTargetPlatform == TargetPlatform.iOS;

/// One tab in [GlassNavBar].
class GlassNavItem {
  const GlassNavItem({required this.icon, required this.label});
  final Widget icon;
  final String label;
}

/// iOS-style floating glass tab bar: blurred translucent pill, a highlight
/// that slides with the TabController (including mid-swipe), a small bounce
/// on the selected icon, and the unread badges from [HomeTabBadges].
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({
    super.key,
    required this.controller,
    required this.items,
    required this.currentUserId,
    this.height = 68.0,
    this.onTap,
  });

  final TabController controller;
  final List<GlassNavItem> items;
  final String currentUserId;
  final double height;
  final ValueChanged<int>? onTap;

  static const Color _purple = Color(0xFF935CCC);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final glass = dark
        ? const Color(0xFF1C1C1E).withValues(alpha: 0.62)
        : Colors.white.withValues(alpha: 0.70);
    final border = dark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.85);
    final highlight = dark
        ? Colors.white.withValues(alpha: 0.14)
        : _purple.withValues(alpha: 0.13);
    final idle = dark ? Colors.white : const Color(0xFF111B21);

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.45 : 0.14),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            decoration: BoxDecoration(
              color: glass,
              borderRadius: BorderRadius.circular(height / 2),
              border: Border.all(color: border, width: 1),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: dark ? 0.06 : 0.35),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
            padding: const EdgeInsets.all(5),
            child: LayoutBuilder(
              builder: (context, box) {
                final n = items.length;
                final slot = box.maxWidth / n;
                return AnimatedBuilder(
                  animation: controller.animation ?? controller,
                  builder: (context, _) {
                    final pos = (controller.animation?.value ??
                            controller.index.toDouble())
                        .clamp(0.0, (n - 1).toDouble());
                    final selected = pos.round();
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Sliding highlight capsule.
                        Positioned(
                          left: pos * slot,
                          top: 0,
                          bottom: 0,
                          width: slot,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: highlight,
                              borderRadius:
                                  BorderRadius.circular((height - 10) / 2),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            for (var i = 0; i < n; i++)
                              Expanded(
                                child: _GlassTab(
                                  item: items[i],
                                  selected: i == selected,
                                  activeColor: _purple,
                                  idleColor: idle,
                                  onTap: () {
                                    if (controller.index != i) {
                                      controller.animateTo(i,
                                          duration: const Duration(
                                              milliseconds: 320),
                                          curve: Curves.easeOutCubic);
                                    }
                                    onTap?.call(i);
                                  },
                                ),
                              ),
                          ],
                        ),
                        // Unread badges, aligned to the same 5 slots.
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 2,
                          height: 20,
                          child: HomeTabBadges(
                            width: box.maxWidth,
                            height: 20,
                            currentUserId: currentUserId,
                            selectedTab: controller.index,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassTab extends StatelessWidget {
  const _GlassTab({
    required this.item,
    required this.selected,
    required this.activeColor,
    required this.idleColor,
    required this.onTap,
  });

  final GlassNavItem item;
  final bool selected;
  final Color activeColor;
  final Color idleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : idleColor;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              child: IconTheme(
                data: IconThemeData(color: color, size: 24),
                child: item.icon,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
                height: 1.1,
              ),
              child: Text(item.label,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
