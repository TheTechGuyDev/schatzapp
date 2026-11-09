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

import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StorySettingsPage extends StatefulWidget {
  const StorySettingsPage({
    super.key,
    this.width,
    this.height,
    required this.currentUserId,
  });

  final double? width;
  final double? height;
  final String currentUserId;

  @override
  State<StorySettingsPage> createState() => _StorySettingsPageState();
}

class _StorySettingsPageState extends State<StorySettingsPage> {
  StorySettingsRow? _settings;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await getOrCreateStorySettings(widget.currentUserId);
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _loading = false;
    });
  }

  Future<void> _updateSettings(Map<String, dynamic> data) async {
    await SupaFlow.client
        .from('story_settings')
        .update(data)
        .eq('user_id', widget.currentUserId);
    final refreshed = await getOrCreateStorySettings(widget.currentUserId);
    if (!mounted) return;
    setState(() => _settings = refreshed);
  }

  Future<void> _openCustomViewersPicker() async {
    if (_settings?.viewVisibility != 'custom') {
      await _updateSettings({'view_visibility': 'custom'});
    }

    final contactsRows = await SupaFlow.client
        .from('contacts')
        .select('contact_user_id, saved_name, phone_number')
        .eq('owner_id', widget.currentUserId)
        .not('contact_user_id', 'is', null);

    final selectedRows = await SupaFlow.client
        .from('story_custom_viewers')
        .select('viewer_id')
        .eq('owner_id', widget.currentUserId);
    final selectedIds =
        selectedRows.map((r) => r['viewer_id'] as String).toSet();

    if (!mounted) return;
    final theme = FlutterFlowTheme.of(context);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
              ),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose specific people',
                        style: theme.bodyMedium.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                          ),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryText,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: contactsRows.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              "You don't have any contacts on the app yet.",
                              style: theme.bodyMedium.override(
                                font: GoogleFonts.plusJakartaSans(),
                                color: theme.secondaryText,
                                fontSize: 13.0,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(bottom: 8.0),
                            itemCount: contactsRows.length,
                            itemBuilder: (context, index) {
                              final row = contactsRows[index];
                              final id = row['contact_user_id'] as String;
                              final name = (row['saved_name'] as String?) ?? '';
                              final phone =
                                  (row['phone_number'] as String?) ?? '';
                              final isSelected = selectedIds.contains(id);
                              return CheckboxListTile(
                                value: isSelected,
                                activeColor: theme.primaryText,
                                checkColor: theme.secondaryBackground,
                                title: Text(
                                  name,
                                  style: theme.bodyMedium.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    color: theme.primaryText,
                                  ),
                                ),
                                subtitle: Text(
                                  phone,
                                  style: theme.bodyMedium.override(
                                    font: GoogleFonts.plusJakartaSans(),
                                    color: theme.secondaryText,
                                    fontSize: 11.0,
                                  ),
                                ),
                                onChanged: (val) async {
                                  if (val == true) {
                                    await SupaFlow.client
                                        .from('story_custom_viewers')
                                        .upsert(
                                      {
                                        'owner_id': widget.currentUserId,
                                        'viewer_id': id,
                                      },
                                      onConflict: 'owner_id,viewer_id',
                                    );
                                    selectedIds.add(id);
                                  } else {
                                    await SupaFlow.client
                                        .from('story_custom_viewers')
                                        .delete()
                                        .eq('owner_id', widget.currentUserId)
                                        .eq('viewer_id', id);
                                    selectedIds.remove(id);
                                  }
                                  setSheetState(() {});
                                },
                              );
                            },
                          ),
                  ),
                  SizedBox(
                    height:
                        MediaQuery.of(sheetContext).viewInsets.bottom + 16.0,
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    final refreshed = await getOrCreateStorySettings(widget.currentUserId);
    if (!mounted) return;
    setState(() => _settings = refreshed);
  }

  TextStyle _titleStyle(FlutterFlowTheme theme, {double fontSize = 14.0}) {
    return theme.bodyMedium.override(
      font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
      fontSize: fontSize,
      letterSpacing: 0.0,
      fontWeight: FontWeight.w600,
      color: theme.primaryText,
    );
  }

  TextStyle _subtitleStyle(FlutterFlowTheme theme, {double fontSize = 10.0}) {
    return theme.bodyMedium.override(
      font: GoogleFonts.plusJakartaSans(),
      color: theme.secondaryText,
      fontSize: fontSize,
      letterSpacing: 0.0,
    );
  }

  Widget _sectionCard(
    FlutterFlowTheme theme, {
    required Widget headerIcon,
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: theme.alternate),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: 35.0,
                      height: 35.0,
                      decoration: BoxDecoration(
                        color: theme.alternate,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: headerIcon,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: _titleStyle(theme)),
                            if (subtitle != null && subtitle.isNotEmpty) ...[
                              const SizedBox(height: 5.0),
                              Text(subtitle, style: _subtitleStyle(theme)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkboxRow(
    FlutterFlowTheme theme, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool recommended = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? theme.alternate : theme.primaryBackground,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: theme.alternate),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Theme(
                data: ThemeData(
                  checkboxTheme: CheckboxThemeData(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  unselectedWidgetColor:
                      selected ? theme.alternate : theme.secondaryText,
                ),
                child: Checkbox(
                  value: selected,
                  onChanged: (_) => onTap(),
                  side: BorderSide(
                    width: 2,
                    color: selected ? theme.alternate : theme.secondaryText,
                  ),
                  activeColor: theme.primaryText,
                  checkColor: theme.secondaryBackground,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(label, style: _titleStyle(theme)),
                ),
              ),
              if (recommended)
                Container(
                  width: 80.0,
                  height: 25.0,
                  decoration: BoxDecoration(
                    color: const Color(0xBCE9EDEF),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: theme.primaryBackground,
                      width: 1.0,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Recommended',
                      style: theme.bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                        ),
                        color: theme.secondaryText,
                        fontSize: 8.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconCheckboxRow(
    FlutterFlowTheme theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? theme.alternate : theme.primaryBackground,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: theme.alternate),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: 35.0,
                        height: 35.0,
                        decoration: BoxDecoration(
                          color: theme.alternate,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.primaryBackground),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child:
                              Icon(icon, color: theme.primaryText, size: 22.0),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: _titleStyle(theme, fontSize: 13.0)),
                              Text(subtitle, style: _subtitleStyle(theme)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Theme(
                data: ThemeData(
                  checkboxTheme: CheckboxThemeData(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  unselectedWidgetColor:
                      selected ? theme.alternate : theme.secondaryText,
                ),
                child: Checkbox(
                  value: selected,
                  onChanged: (_) => onTap(),
                  side: BorderSide(
                    width: 2,
                    color: selected ? theme.alternate : theme.secondaryText,
                  ),
                  activeColor: theme.primaryText,
                  checkColor: theme.secondaryBackground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customRow(FlutterFlowTheme theme) {
    final selected = _settings?.viewVisibility == 'custom';
    return InkWell(
      onTap: _openCustomViewersPicker,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? theme.alternate : theme.primaryBackground,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: theme.alternate),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: 35.0,
                        height: 35.0,
                        decoration: BoxDecoration(
                          color: theme.alternate,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.primaryBackground),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(Icons.person_add_alt,
                              color: theme.primaryText, size: 22.0),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Custom',
                                  style: _titleStyle(theme, fontSize: 13.0)),
                              Text('Choose specific people',
                                  style: _subtitleStyle(theme)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: Icon(Icons.keyboard_arrow_right,
                    color: theme.primaryText, size: 24.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _switchRow(
    FlutterFlowTheme theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 35.0,
                    height: 35.0,
                    decoration: BoxDecoration(
                      color: theme.alternate,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.primaryBackground),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Icon(icon, color: theme.primaryText, size: 22.0),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: _titleStyle(theme, fontSize: 14.0)),
                          Text(subtitle,
                              style: _subtitleStyle(theme, fontSize: 13.0)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: theme.primary,
            activeTrackColor: theme.alternate,
            inactiveTrackColor: theme.alternate,
            inactiveThumbColor: theme.secondaryBackground,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    if (_loading || _settings == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final settings = _settings!;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: theme.secondaryBackground,
          automaticallyImplyLeading: false,
          leading: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Icon(Icons.arrow_back_rounded,
                  color: theme.primaryText, size: 30.0),
            ),
          ),
          title: Text(
            'Story Settings',
            style: theme.headlineMedium.override(
              font: GoogleFonts.plusJakartaSans(
                fontWeight: theme.headlineMedium.fontWeight,
              ),
              color: theme.primaryText,
              fontSize: 22.0,
              letterSpacing: 0.0,
              fontWeight: theme.headlineMedium.fontWeight,
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Control how your stories are shared and who can see them.',
                        style: _subtitleStyle(theme, fontSize: 11.0),
                      ),
                    ),
                  ),
                  _sectionCard(
                    theme,
                    headerIcon: Icon(Icons.access_time,
                        color: theme.primaryText, size: 22.0),
                    title: 'Stories Lasting Hours',
                    subtitle: 'Choose how long your story will be visible.',
                    children: [
                      _checkboxRow(
                        theme,
                        label: '24 Hours',
                        selected: settings.durationHours == 24,
                        recommended: true,
                        onTap: () => _updateSettings({'duration_hours': 24}),
                      ),
                      _checkboxRow(
                        theme,
                        label: '12 Hours',
                        selected: settings.durationHours == 12,
                        onTap: () => _updateSettings({'duration_hours': 12}),
                      ),
                      _checkboxRow(
                        theme,
                        label: '36 Hours',
                        selected: settings.durationHours == 36,
                        onTap: () => _updateSettings({'duration_hours': 36}),
                      ),
                      _checkboxRow(
                        theme,
                        label: '52 Hours',
                        selected: settings.durationHours == 52,
                        onTap: () => _updateSettings({'duration_hours': 52}),
                      ),
                    ].divide(const SizedBox(height: 3.0)),
                  ),
                  _sectionCard(
                    theme,
                    headerIcon: FaIcon(FontAwesomeIcons.eye,
                        color: theme.primaryText, size: 22.0),
                    title: 'Stories Appearance',
                    subtitle: 'Choose how your stories are displayed.',
                    children: [
                      _checkboxRow(
                        theme,
                        label: 'Default by Time',
                        selected: (settings.sortOrder ?? 'time') == 'time',
                        onTap: () => _updateSettings({'sort_order': 'time'}),
                      ),
                      _checkboxRow(
                        theme,
                        label: 'Default Randomly',
                        selected: settings.sortOrder == 'random',
                        onTap: () => _updateSettings({'sort_order': 'random'}),
                      ),
                    ].divide(const SizedBox(height: 3.0)),
                  ),
                  _sectionCard(
                    theme,
                    headerIcon: Icon(Icons.shield_outlined,
                        color: theme.primaryText, size: 22.0),
                    title: 'Who Can View Your Stories',
                    subtitle: 'Control who can see your stories.',
                    children: [
                      _iconCheckboxRow(
                        theme,
                        icon: Icons.people_outline,
                        title: 'Everyone',
                        subtitle: 'All your followers and connections.',
                        selected: (settings.viewVisibility ?? 'everyone') ==
                            'everyone',
                        onTap: () =>
                            _updateSettings({'view_visibility': 'everyone'}),
                      ),
                      _iconCheckboxRow(
                        theme,
                        icon: Icons.lock_outline,
                        title: 'Phone Number',
                        subtitle: 'People with my number.',
                        selected: settings.viewVisibility == 'phone_number',
                        onTap: () => _updateSettings(
                            {'view_visibility': 'phone_number'}),
                      ),
                      _customRow(theme),
                    ].divide(const SizedBox(height: 3.0)),
                  ),
                  _sectionCard(
                    theme,
                    headerIcon: Icon(Icons.settings_outlined,
                        color: theme.primaryText, size: 22.0),
                    title: 'Additional Options',
                    children: [
                      _switchRow(
                        theme,
                        icon: Icons.file_download_outlined,
                        title: 'Allow Download',
                        subtitle: 'Let others save your stories.',
                        value: settings.allowDownload ?? true,
                        onChanged: (val) =>
                            _updateSettings({'allow_download': val}),
                      ),
                      Divider(thickness: 1.0, color: theme.alternate),
                      _switchRow(
                        theme,
                        icon: Icons.reply,
                        title: 'Allow Replies',
                        subtitle: 'Let others reply to your stories.',
                        value: settings.allowReplies ?? true,
                        onChanged: (val) =>
                            _updateSettings({'allow_replies': val}),
                      ),
                      Divider(thickness: 1.0, color: theme.alternate),
                      _switchRow(
                        theme,
                        icon: Icons.location_on_outlined,
                        title: 'Show Location',
                        subtitle: 'Add location to your stories.',
                        value: settings.showLocation ?? true,
                        onChanged: (val) =>
                            _updateSettings({'show_location': val}),
                      ),
                    ].divide(const SizedBox(height: 3.0)),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the `</>` button on the right!
