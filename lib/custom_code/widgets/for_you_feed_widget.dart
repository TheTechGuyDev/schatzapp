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

import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/story_player.dart';

const Color kReactionPrimary = Color(0xFF935CCC);
const Color kReactionHeart = Color(0xFFE0245E);

/// Favorite keeps the heart icon; the others are emoji. Emoji can't be
/// recoloured, so inactive ones are faded and active ones get a highlight.
Widget _reactionIcon(String type, bool active, Color inactiveColor,
    {double size = 25.0}) {
  if (type == 'favorite') {
    return Icon(
      active ? Icons.favorite : Icons.favorite_border,
      color: active ? kReactionHeart : inactiveColor,
      size: size,
    );
  }
  return Opacity(
    opacity: active ? 1.0 : 0.6,
    child: Text(
      actions.kReactionEmoji[type] ?? '',
      style: TextStyle(fontSize: size - 3, height: 1.15),
    ),
  );
}

/// Counts and the viewer's own picks for one status post.
class _ReactionState {
  final Map<String, int> counts = {
    for (final t in actions.kReactionTypes) t: 0
  };
  final Set<String> mine = {};

  void reset() {
    for (final t in actions.kReactionTypes) {
      counts[t] = 0;
    }
    mine.clear();
  }

  void fromSummary(ReactionSummaryStructStruct s) {
    counts['favorite'] = s.favoriteCount;
    counts['peace'] = s.peaceCount;
    counts['laugh'] = s.laughCount;
    counts['sad'] = s.sadCount;
    counts['angry'] = s.angryCount;
    mine
      ..clear()
      ..addAll([
        if (s.favoriteActive) 'favorite',
        if (s.peaceActive) 'peace',
        if (s.laughActive) 'laugh',
        if (s.sadActive) 'sad',
        if (s.angryActive) 'angry',
      ]);
  }

  void _flip(String type, bool on) {
    final c = counts[type] ?? 0;
    if (on) {
      mine.add(type);
      counts[type] = c + 1;
    } else {
      mine.remove(type);
      counts[type] = c > 0 ? c - 1 : 0;
    }
  }
}

void _showReactionLimit(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(content: Text(actions.kReactionLimitMessage)),
    );
}

/// Optimistic toggle with the 2-reaction limit. [update] wraps setState.
Future<void> _toggleReactionUi({
  required BuildContext context,
  required String statusId,
  required String viewerId,
  required String type,
  required _ReactionState state,
  required void Function(VoidCallback fn) update,
  required bool Function() isMounted,
}) async {
  if (statusId.isEmpty) return;
  final wasActive = state.mine.contains(type);
  if (!wasActive && state.mine.length >= 2) {
    _showReactionLimit(context);
    return;
  }
  // Adding is instant. Removing waits for the server, because a reaction
  // older than 3 seconds is locked and must stay highlighted.
  if (!wasActive) update(() => state._flip(type, true));
  try {
    await actions.toggleReaction(statusId, viewerId, type);
    if (wasActive && isMounted()) update(() => state._flip(type, false));
  } on actions.ReactionLockedException {
    if (!isMounted()) return;
    if (!wasActive) update(() => state._flip(type, false));
    _showReactionSnack(context, actions.kReactionLockedMessage);
  } on actions.ReactionLimitException {
    if (!isMounted()) return;
    if (!wasActive) update(() => state._flip(type, false));
    _showReactionLimit(context);
  } catch (e) {
    if (!isMounted()) return;
    if (!wasActive) update(() => state._flip(type, false));
    _showReactionSnack(context, 'Could not save reaction. Try again.');
  }
}

void _showReactionSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

class ForYouFeedWidget extends StatefulWidget {
  const ForYouFeedWidget({
    Key? key,
    this.width,
    this.height,
    required this.currentUserId,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String currentUserId;

  @override
  State<ForYouFeedWidget> createState() => _ForYouFeedWidgetState();
}

class _ForYouFeedWidgetState extends State<ForYouFeedWidget> {
  List<StoryGroupStruct> _feed = [];
  bool _loading = true;
  Timer? _refreshTimer;
  Timer? _visibilityDebounce;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _listViewKey = GlobalKey();
  final Map<int, GlobalKey> _itemKeys = {};
  int? _activeVideoIndex;

  @override
  void initState() {
    super.initState();
    _loadFeed(showSpinner: true);
    _refreshTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      _loadFeed(showSpinner: false);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _visibilityDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFeed({required bool showSpinner}) async {
    if (showSpinner && mounted) {
      setState(() => _loading = true);
    }
    try {
      final result = await actions.getForYouFeed(widget.currentUserId);
      if (!mounted) return;
      setState(() {
        _feed = result;
        _loading = false;
        _itemKeys.clear();
      });
      _scheduleVisibilityCheck();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _onScroll() {
    _visibilityDebounce?.cancel();
    _visibilityDebounce =
        Timer(const Duration(milliseconds: 120), _scheduleVisibilityCheck);
  }

  void _scheduleVisibilityCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _computeActiveVideo());
  }

  void _computeActiveVideo() {
    if (!mounted || !_scrollController.hasClients) return;

    double? viewportTop;
    double? viewportBottom;
    final viewportRenderObject =
        _listViewKey.currentContext?.findRenderObject();
    if (viewportRenderObject is RenderBox && viewportRenderObject.attached) {
      final topLeft = viewportRenderObject.localToGlobal(Offset.zero);
      viewportTop = topLeft.dy;
      viewportBottom = viewportTop + viewportRenderObject.size.height;
    }
    if (viewportTop == null || viewportBottom == null) return;

    int? bestIndex;
    double bestFraction = 0.0;
    for (final entry in _itemKeys.entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject();
      if (box is! RenderBox || !box.attached || box.size.height == 0) {
        continue;
      }
      final top = box.localToGlobal(Offset.zero).dy;
      final bottom = top + box.size.height;
      final overlapTop = top > viewportTop ? top : viewportTop;
      final overlapBottom = bottom < viewportBottom ? bottom : viewportBottom;
      final overlap = overlapBottom - overlapTop;
      if (overlap <= 0) continue;
      final fraction = overlap / box.size.height;
      if (fraction > bestFraction) {
        bestFraction = fraction;
        bestIndex = entry.key;
      }
    }

    final newActive = bestFraction >= 0.55 ? bestIndex : null;
    if (newActive != _activeVideoIndex && mounted) {
      setState(() => _activeVideoIndex = newActive);
    }
  }

  void _openStory(StoryGroupStruct group, {int startIndex = 0}) {
    if (group.items.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _ForYouStoryViewerPage(
          group: group,
          viewerId: widget.currentUserId,
          startIndex: startIndex,
        ),
      ),
    );
  }

  String _timeAgoLabel(DateTime? createdAt) {
    if (createdAt == null) return '';
    final diff = DateTime.now().toUtc().difference(createdAt.toUtc());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(5.0, 0.0, 5.0, 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  FFLocalizations.of(context).getText(
                    'xd3garke' /* Stories */,
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).primaryText,
                        fontSize: 30.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
              ],
            ),
            Expanded(
              child: _loading && _feed.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _feed.isEmpty
                      ? RefreshIndicator(
                          onRefresh: () => _loadFeed(showSpinner: false),
                          child: ListView(
                            children: [
                              SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text(
                                    'No stories yet',
                                    style:
                                        FlutterFlowTheme.of(context).bodyMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => _loadFeed(showSpinner: false),
                          child: ListView.builder(
                            key: _listViewKey,
                            controller: _scrollController,
                            padding: EdgeInsets.zero,
                            itemCount: _feed.length,
                            itemBuilder: (context, index) {
                              final group = _feed[index];
                              final key = _itemKeys.putIfAbsent(
                                  index, () => GlobalKey());
                              return Padding(
                                key: key,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 20.0),
                                child: _ForYouCard(
                                  group: group,
                                  viewerId: widget.currentUserId,
                                  isActiveVideo: _activeVideoIndex == index,
                                  timeAgoLabel: _timeAgoLabel(group.items
                                      .elementAtOrNull(0)
                                      ?.createdAt),
                                  onOpen: (startIndex) =>
                                      _openStory(group, startIndex: startIndex),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForYouCard extends StatefulWidget {
  const _ForYouCard({
    required this.group,
    required this.viewerId,
    required this.isActiveVideo,
    required this.timeAgoLabel,
    required this.onOpen,
  });

  final StoryGroupStruct group;
  final String viewerId;
  final bool isActiveVideo;
  final String timeAgoLabel;
  final void Function(int startIndex) onOpen;

  @override
  State<_ForYouCard> createState() => _ForYouCardState();
}

class _ForYouCardState extends State<_ForYouCard> {
  VideoPlayerController? _videoController;
  bool _videoFailed = false;
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final _ReactionState _reactions = _ReactionState();

  StoryItemStruct? get _item =>
      widget.group.items.elementAtOrNull(_currentIndex);

  @override
  void initState() {
    super.initState();
    _loadReactions();
    if (widget.isActiveVideo) _activateVideo();
  }

  @override
  void didUpdateWidget(covariant _ForYouCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group.userId != widget.group.userId) {
      _disposeVideo();
      _currentIndex = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      _reactions.reset();
      _loadReactions();
      if (widget.isActiveVideo) _activateVideo();
      return;
    }
    if (widget.isActiveVideo && !oldWidget.isActiveVideo) {
      _activateVideo();
    } else if (!widget.isActiveVideo && oldWidget.isActiveVideo) {
      _disposeVideo();
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    _disposeVideo();
    setState(() {
      _currentIndex = index;
      _reactions.reset();
    });
    _loadReactions();
    if (widget.isActiveVideo) _activateVideo();
  }

  Future<void> _loadReactions() async {
    final statusId = _item?.id;
    if (statusId == null || statusId.isEmpty) return;
    try {
      final summary =
          await actions.getReactionSummary(statusId, widget.viewerId);
      if (!mounted || _item?.id != statusId) return;
      setState(() => _reactions.fromSummary(summary));
    } catch (_) {
      // Leave counts at their defaults if the summary fetch fails.
    }
  }

  Future<void> _toggle(String type) async {
    final statusId = _item?.id;
    if (statusId == null || statusId.isEmpty) return;
    await _toggleReactionUi(
      context: context,
      statusId: statusId,
      viewerId: widget.viewerId,
      type: type,
      state: _reactions,
      update: setState,
      isMounted: () => mounted && _item?.id == statusId,
    );
  }

  Future<void> _activateVideo() async {
    final item = _item;
    if (item == null || item.mediaType != 'video' || item.mediaUrl.isEmpty) {
      return;
    }
    if (_videoController != null) {
      _videoController!.play();
      return;
    }
    if (mounted && _videoFailed) setState(() => _videoFailed = false);
    // Videos can take a while to open on mobile data: wait up to 30 seconds
    // and try twice before giving up.
    for (var attempt = 0; attempt < 2; attempt++) {
      final vc = VideoPlayerController.networkUrl(Uri.parse(item.mediaUrl));
      try {
        await vc.initialize().timeout(const Duration(seconds: 30));
        if (!mounted || !widget.isActiveVideo || _item?.id != item.id) {
          vc.dispose();
          return;
        }
        await vc.setVolume(0.0);
        await vc.setLooping(true);
        vc.play();
        setState(() => _videoController = vc);
        return;
      } catch (_) {
        vc.dispose();
        if (!mounted || !widget.isActiveVideo || _item?.id != item.id) return;
      }
    }
    if (mounted) setState(() => _videoFailed = true);
  }

  void _disposeVideo() {
    final vc = _videoController;
    _videoController = null;
    vc?.pause();
    vc?.dispose();
    _videoFailed = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    final items = widget.group.items;

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => widget.onOpen(_currentIndex),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).primaryBackground,
            width: 2.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 510.0,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 1.0,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  items.length > 1
                      ? PageView.builder(
                          controller: _pageController,
                          itemCount: items.length,
                          onPageChanged: _onPageChanged,
                          itemBuilder: (context, i) =>
                              _buildMedia(context, items[i]),
                        )
                      : _buildMedia(context, item),
                  Positioned(
                    top: 15,
                    left: 15,
                    right: 15,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 45.0,
                          height: 45.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: Image.network(
                                valueOrDefault<String>(
                                  widget.group.avatarUrl,
                                  'https://plus.unsplash.com/premium_photo-1705009607118-5216fbbf8820?q=80&w=387&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                                ),
                              ).image,
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 0.0,
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                                offset: const Offset(0.0, 0.0),
                                spreadRadius: 2.0,
                              ),
                            ],
                            shape: BoxShape.circle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              15.0, 0.0, 0.0, 0.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 5.0),
                                child: Text(
                                  valueOrDefault<String>(
                                    widget.group.fullName,
                                    'Emma Johnson',
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                              ),
                              Text(
                                widget.timeAgoLabel,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (items.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(items.length, (i) {
                          final isCurrent = i == _currentIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isCurrent ? 8.0 : 6.0,
                            height: isCurrent ? 8.0 : 6.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCurrent
                                  ? kReactionPrimary
                                  : Colors.white.withOpacity(0.6),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
            if (item != null &&
                (item.mediaType == 'image' || item.mediaType == 'video') &&
                item.caption.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    15.0, 10.0, 15.0, 10.0),
                child: AutoSizeText(
                  item.caption,
                  maxLines: 4,
                  minFontSize: 13.0,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(15.0, 0.0, 15.0, 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reactions scroll sideways on small screens so Share
                  // always stays visible.
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final t in actions.kReactionTypes)
                            _reactionButton(
                              context,
                              type: t,
                              active: _reactions.mine.contains(t),
                              count: _reactions.counts[t] ?? 0,
                              onTap: () => _toggle(t),
                            ),
                        ].divide(const SizedBox(width: 2.0)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.share,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 24.0,
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          FFLocalizations.of(context).getText(
                            '7udrbfcq' /* Share */,
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.plusJakartaSans(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reactionButton(
    BuildContext context, {
    required String type,
    required bool active,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: active
              ? kReactionPrimary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _reactionIcon(
                type, active, FlutterFlowTheme.of(context).secondaryText),
            Text(
              count.toString(),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    fontSize: 12.0,
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedia(BuildContext context, StoryItemStruct? item) {
    if (item == null) return const SizedBox.shrink();
    switch (item.mediaType) {
      case 'video':
        return _buildVideoMedia(item);
      case 'text':
        return _buildTextMedia(item);
      case 'voice':
        return _buildVoiceMedia(item);
      default:
        return _buildImageMedia(item);
    }
  }

  Widget _buildImageMedia(StoryItemStruct item) {
    if (item.mediaUrl.isEmpty) {
      return Container(color: Colors.black12);
    }
    return Image.network(
      item.mediaUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(Icons.broken_image, color: Colors.white54, size: 40),
        );
      },
    );
  }

  Widget _buildVideoMedia(StoryItemStruct item) {
    final vc = _videoController;
    if (vc != null && vc.value.isInitialized && _item?.id == item.id) {
      return Container(
        color: Colors.black,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: vc.value.size.width,
            height: vc.value.size.height,
            child: VideoPlayer(vc),
          ),
        ),
      );
    }
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: _videoFailed
          ? const Icon(Icons.videocam_off, color: Colors.white54, size: 40)
          : (widget.isActiveVideo && _item?.id == item.id)
              ? const SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white54),
                )
              : const Icon(Icons.play_circle_outline,
                  color: Colors.white54, size: 44),
    );
  }

  Widget _buildTextMedia(StoryItemStruct item) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _parseGradientColors(item.backgroundColor),
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Text(
        item.caption,
        textAlign: TextAlign.center,
        style: _feedFontStyle(item.fontIndex, size: 22, color: Colors.white),
      ),
    );
  }

  Widget _buildVoiceMedia(StoryItemStruct item) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _parseGradientColors(item.backgroundColor),
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.mic, color: Colors.white, size: 34),
          ),
          if (item.caption.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              item.caption,
              textAlign: TextAlign.center,
              style:
                  _feedFontStyle(item.fontIndex, size: 15, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}

class _ForYouStoryViewerPage extends StatefulWidget {
  const _ForYouStoryViewerPage({
    required this.group,
    required this.viewerId,
    this.startIndex = 0,
  });

  final StoryGroupStruct group;
  final String viewerId;
  final int startIndex;

  @override
  State<_ForYouStoryViewerPage> createState() => _ForYouStoryViewerPageState();
}

class _ForYouStoryViewerPageState extends State<_ForYouStoryViewerPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex.clamp(0, widget.group.items.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = widget.group.items.elementAtOrNull(_currentIndex);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: StoryPlayer(
                items: widget.group.items,
                viewerId: widget.viewerId,
                isOwnStory: false,
                startIndex: _currentIndex,
                onIndexChanged: (index) async {
                  if (mounted) setState(() => _currentIndex = index);
                },
                onFinishedGroup: () async {
                  Navigator.of(context).maybePop();
                },
                onExitToPrevious: () async {
                  Navigator.of(context).maybePop();
                },
              ),
            ),
            Positioned(
              top: 28,
              left: 12,
              right: 4,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                      image: widget.group.avatarUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(widget.group.avatarUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.group.fullName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            if (currentItem != null)
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _ReactionRail(
                    key: ValueKey(currentItem.id),
                    statusId: currentItem.id,
                    viewerId: widget.viewerId,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReactionRail extends StatefulWidget {
  const _ReactionRail({
    super.key,
    required this.statusId,
    required this.viewerId,
  });

  final String statusId;
  final String viewerId;

  @override
  State<_ReactionRail> createState() => _ReactionRailState();
}

class _ReactionRailState extends State<_ReactionRail> {
  final _ReactionState _reactions = _ReactionState();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.statusId.isEmpty) return;
    try {
      final summary =
          await actions.getReactionSummary(widget.statusId, widget.viewerId);
      if (!mounted) return;
      setState(() => _reactions.fromSummary(summary));
    } catch (_) {
      // Leave counts at their defaults if the summary fetch fails.
    }
  }

  Future<void> _toggle(String type) => _toggleReactionUi(
        context: context,
        statusId: widget.statusId,
        viewerId: widget.viewerId,
        type: type,
        state: _reactions,
        update: setState,
        isMounted: () => mounted,
      );

  @override
  Widget build(BuildContext context) {
    // Scrolls if 5 reactions + Share don't fit (small screens, landscape).
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final t in actions.kReactionTypes) ...[
            _railButton(
              type: t,
              active: _reactions.mine.contains(t),
              count: _reactions.counts[t] ?? 0,
              onTap: () => _toggle(t),
            ),
            const SizedBox(height: 10),
          ],
          _railButton(
            type: 'share',
            active: false,
            count: null,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _railButton({
    required String type,
    required bool active,
    required int? count,
    required VoidCallback onTap,
  }) {
    final icon = type == 'share'
        ? const FaIcon(FontAwesomeIcons.share, color: Colors.white, size: 28.0)
        : _reactionIcon(type, active, Colors.white, size: 28.0);
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withValues(alpha: 0.22)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            if (count != null) ...[
              const SizedBox(height: 4),
              Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

List<Color> _parseGradientColors(String? hex) {
  if (hex == null || hex.isEmpty) {
    return [Colors.deepPurple, Colors.deepPurple];
  }
  final parts = hex.split(',');
  Color parseOne(String h) {
    var value = h.trim().replaceAll('#', '');
    if (value.length == 6) value = 'FF$value';
    try {
      return Color(int.parse(value, radix: 16));
    } catch (_) {
      return Colors.deepPurple;
    }
  }

  if (parts.length >= 2) {
    return [parseOne(parts[0]), parseOne(parts[1])];
  }
  final single = parseOne(parts[0]);
  return [single, single];
}

TextStyle _feedFontStyle(int index,
    {required double size, required Color color}) {
  switch (index) {
    case 0:
      return GoogleFonts.roboto(
          fontSize: size, color: color, fontWeight: FontWeight.w600);
    case 1:
      return GoogleFonts.openSans(
          fontSize: size, color: color, fontWeight: FontWeight.w600);
    case 2:
      return GoogleFonts.lato(
          fontSize: size, color: color, fontWeight: FontWeight.w600);
    case 3:
      return GoogleFonts.montserrat(
          fontSize: size, color: color, fontWeight: FontWeight.w600);
    case 4:
      return GoogleFonts.poppins(
          fontSize: size, color: color, fontWeight: FontWeight.w300);
    case 5:
      return GoogleFonts.dancingScript(
          fontSize: size, color: color, fontWeight: FontWeight.w600);
    case 6:
      return GoogleFonts.greatVibes(fontSize: size, color: color);
    case 7:
      return GoogleFonts.pacifico(fontSize: size, color: color);
    case 8:
      return GoogleFonts.sacramento(fontSize: size, color: color);
    case 9:
      return GoogleFonts.satisfy(fontSize: size, color: color);
    default:
      return GoogleFonts.roboto(
          fontSize: size, color: color, fontWeight: FontWeight.w600);
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!

// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
