import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'addfriends_widget.dart' show AddfriendsWidget;
import 'package:flutter/material.dart';

class AddfriendsModel extends FlutterFlowModel<AddfriendsWidget> {
  ///  Local state fields for this page.

  List<ContactsDirectoryRow> favoritesList = [];
  void addToFavoritesList(ContactsDirectoryRow item) => favoritesList.add(item);
  void removeFromFavoritesList(ContactsDirectoryRow item) =>
      favoritesList.remove(item);
  void removeAtIndexFromFavoritesList(int index) =>
      favoritesList.removeAt(index);
  void insertAtIndexInFavoritesList(int index, ContactsDirectoryRow item) =>
      favoritesList.insert(index, item);
  void updateFavoritesListAtIndex(
          int index, Function(ContactsDirectoryRow) updateFn) =>
      favoritesList[index] = updateFn(favoritesList[index]);

  String searchQuery = 'a';

  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
