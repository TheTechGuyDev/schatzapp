import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'media_links_file_widget.dart' show MediaLinksFileWidget;
import 'package:flutter/material.dart';

class MediaLinksFileModel extends FlutterFlowModel<MediaLinksFileWidget> {
  ///  Local state fields for this page.

  List<MessagesRow> linkMessages = [];
  void addToLinkMessages(MessagesRow item) => linkMessages.add(item);
  void removeFromLinkMessages(MessagesRow item) => linkMessages.remove(item);
  void removeAtIndexFromLinkMessages(int index) => linkMessages.removeAt(index);
  void insertAtIndexInLinkMessages(int index, MessagesRow item) =>
      linkMessages.insert(index, item);
  void updateLinkMessagesAtIndex(int index, Function(MessagesRow) updateFn) =>
      linkMessages[index] = updateFn(linkMessages[index]);

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
