import '/auth/supabase_auth/auth_util.dart';
import '/components/media_library_sheet_component_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'write_story_model.dart';
export 'write_story_model.dart';

class WriteStoryWidget extends StatefulWidget {
  const WriteStoryWidget({super.key});

  static String routeName = 'write_story';
  static String routePath = '/writeStory';

  @override
  State<WriteStoryWidget> createState() => _WriteStoryWidgetState();
}

class _WriteStoryWidgetState extends State<WriteStoryWidget> {
  late WriteStoryModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WriteStoryModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Title(
        title: 'write_story',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              child: custom_widgets.WriteStoryComposer(
                width: double.infinity,
                height: double.infinity,
                currentUserId: currentUserUid,
                onClose: () async {
                  if (Navigator.of(context).canPop()) {
                    context.pop();
                  }
                  context.pushNamed(HomePageWidget.routeName);
                },
                onPosted: () async {
                  if (Navigator.of(context).canPop()) {
                    context.pop();
                  }
                  context.pushNamed(ViewYourStoriesWidget.routeName);
                },
                onPhotoTap: () async {
                  await showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    enableDrag: false,
                    context: context,
                    builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Padding(
                          padding: MediaQuery.viewInsetsOf(context),
                          child: MediaLibrarySheetComponentWidget(
                            currentSelection: <String>[],
                            onSelectionChanged: (selectedPaths) async {
                              safeSetState(() {});
                            },
                            onClose: () async {
                              Navigator.pop(context);
                            },
                            onSend: (selectedPaths, caption) async {
                              FFAppState().pendingStoryImagePaths =
                                  selectedPaths.toList().cast<String>();
                              safeSetState(() {});
                              await actions.initStoryDraftFromPending();
                              if (Navigator.of(context).canPop()) {
                                context.pop();
                              }
                              context.pushNamed(CreateAStoryWidget.routeName);
                            },
                          ),
                        ),
                      );
                    },
                  ).then((value) => safeSetState(() {}));
                },
                onWebImagesPicked: () async {
                  await actions.initStoryDraftFromPending();

                  context.pushNamed(CreateAStoryWidget.routeName);
                },
              ),
            ),
          ),
        ));
  }
}
