// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraCallManager {
  static RtcEngine? engine;

  static String? channelName;
  static int? myUid;

  static bool isVideoCall = false;
  static bool isMuted = false;
  static bool isSpeakerOn = true;
  static bool isVideoOff = false;

  static bool isTogglingMute = false;

  static int? remoteUid;

  static final Map<int, RemoteAudioState> lastRemoteAudioState = {};
  static final Set<int> forcingAudioReplayFor = {};

  static String lastLocalVideoState = 'none yet';

  // Connection health, for the call screen banners.
  // 'connected' | 'reconnecting' | 'rejoined'
  static final ValueNotifier<String> connection =
      ValueNotifier<String>('connected');
  static Timer? reconnectTimer;
  // Set by the call screen: runs when the connection stayed down for 2 minutes.
  static VoidCallback? onReconnectTimeout;

  static const Duration reconnectWindow = Duration(minutes: 2);

  static void resetConnection() {
    reconnectTimer?.cancel();
    reconnectTimer = null;
    connection.value = 'connected';
  }

  static void handleConnectionState(String state) {
    // `state` is the name of Agora's ConnectionStateType value.
    final s = state.toLowerCase();
    if (s.contains('reconnecting')) {
      if (connection.value != 'reconnecting') {
        connection.value = 'reconnecting';
      }
      reconnectTimer ??= Timer(reconnectWindow, () {
        reconnectTimer = null;
        if (engine != null && connection.value == 'reconnecting') {
          onReconnectTimeout?.call();
        }
      });
    } else if (s.contains('failed')) {
      reconnectTimer?.cancel();
      reconnectTimer = null;
      if (engine != null) onReconnectTimeout?.call();
    } else if (s.contains('connected') && !s.contains('disconnected')) {
      reconnectTimer?.cancel();
      reconnectTimer = null;
      if (connection.value == 'reconnecting') {
        connection.value = 'rejoined';
      }
    }
  }
}

Future<void> _forceRemoteAudioReplay(int remoteUid) async {
  final engine = AgoraCallManager.engine;
  if (engine == null) return;
  if (AgoraCallManager.forcingAudioReplayFor.contains(remoteUid)) return;

  AgoraCallManager.forcingAudioReplayFor.add(remoteUid);
  try {
    await engine.muteRemoteAudioStream(uid: remoteUid, mute: true);
    await Future.delayed(const Duration(milliseconds: 150));
    await engine.muteRemoteAudioStream(uid: remoteUid, mute: false);
    debugPrint('AgoraCallManager: forced audio replay for uid=$remoteUid');
  } catch (e) {
    debugPrint('AgoraCallManager: forceRemoteAudioReplay failed: $e');
  } finally {
    AgoraCallManager.forcingAudioReplayFor.remove(remoteUid);
  }
}

Future<void> _forceRemoteVideoReplay(int remoteUid) async {
  final engine = AgoraCallManager.engine;
  if (engine == null) return;
  try {
    await engine.muteRemoteVideoStream(uid: remoteUid, mute: true);
    await Future.delayed(const Duration(milliseconds: 150));
    await engine.muteRemoteVideoStream(uid: remoteUid, mute: false);
    debugPrint('AgoraCallManager: forced video replay for uid=$remoteUid');
  } catch (e) {
    debugPrint('AgoraCallManager: forceRemoteVideoReplay failed: $e');
  }
}

Future<String> joinAgoraCall(
  String appId,
  String channelName,
  String token,
  int uid,
  bool isVideoCall,
) async {
  const maxAttempts = 2;
  String lastError = 'unknown error';

  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    String step = 'starting';

    try {
      step = 'requesting permissions';
      if (!kIsWeb) {
        await [
          Permission.microphone,
          if (isVideoCall) Permission.camera,
        ].request();
      }

      step = 'cleaning previous engine';
      if (AgoraCallManager.engine != null) {
        try {
          await AgoraCallManager.engine!.leaveChannel();
        } catch (_) {}
        try {
          await AgoraCallManager.engine!.release();
        } catch (_) {}
        AgoraCallManager.engine = null;
      }

      step = 'creating engine';
      final engine = createAgoraRtcEngine();
      AgoraCallManager.engine = engine;

      step = 'initializing engine';
      await engine.initialize(RtcEngineContext(appId: appId));

      step = 'enabling audio';
      await engine.enableAudio();

      AgoraCallManager.channelName = channelName;
      AgoraCallManager.myUid = uid;
      AgoraCallManager.isVideoCall = isVideoCall;
      AgoraCallManager.isMuted = false;
      AgoraCallManager.isSpeakerOn = true;
      AgoraCallManager.isVideoOff = false;
      AgoraCallManager.isTogglingMute = false;
      AgoraCallManager.remoteUid = null;
      AgoraCallManager.lastRemoteAudioState.clear();
      AgoraCallManager.forcingAudioReplayFor.clear();
      AgoraCallManager.lastLocalVideoState = 'engine initialized';
      AgoraCallManager.resetConnection();

      step = 'registering event handler';
      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            AgoraCallManager.lastLocalVideoState =
                'joined channel, localUid=${connection.localUid}';
            debugPrint(
                'AgoraCallManager: joined channel $channelName with uid=$uid');
          },
          onConnectionStateChanged: (connection, state, reason) {
            debugPrint('AgoraCallManager: connection state=${state.name} '
                'reason=${reason.name}');
            AgoraCallManager.handleConnectionState(state.name);
          },
          onLocalVideoStateChanged: (source, state, error) {
            AgoraCallManager.lastLocalVideoState =
                'local video state=$state error=$error';
            debugPrint(
                'AgoraCallManager: local video state=$state error=$error');
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            AgoraCallManager.remoteUid = remoteUid;
            debugPrint('AgoraCallManager: remote user joined uid=$remoteUid');
          },
          onUserOffline: (connection, remoteUid, reason) {
            if (AgoraCallManager.remoteUid == remoteUid) {
              AgoraCallManager.remoteUid = null;
            }
            AgoraCallManager.lastRemoteAudioState.remove(remoteUid);
            debugPrint('AgoraCallManager: remote user offline uid=$remoteUid');
          },
          onUserMuteAudio: (connection, remoteUid, muted) {
            debugPrint(
                'AgoraCallManager: remote user $remoteUid mute-audio changed to $muted');
            if (!muted) {
              _forceRemoteAudioReplay(remoteUid);
            }
          },
          onRemoteAudioStateChanged:
              (connection, remoteUid, state, reason, elapsed) {
            debugPrint(
                'AgoraCallManager: remote audio state for uid=$remoteUid changed to $state (reason=$reason)');

            final previousState =
                AgoraCallManager.lastRemoteAudioState[remoteUid];
            AgoraCallManager.lastRemoteAudioState[remoteUid] = state;

            final wasStopped =
                previousState == RemoteAudioState.remoteAudioStateStopped ||
                    previousState == null;
            final isStuck = state == RemoteAudioState.remoteAudioStateFrozen ||
                state == RemoteAudioState.remoteAudioStateFailed;

            if (wasStopped && isStuck) {
              debugPrint(
                  'AgoraCallManager: remote audio for uid=$remoteUid appears stuck recovering — forcing replay');
              _forceRemoteAudioReplay(remoteUid);
            }
          },
          onUserMuteVideo: (connection, remoteUid, muted) {
            debugPrint(
                'AgoraCallManager: remote user $remoteUid mute-video changed to $muted');
            if (!muted) {
              _forceRemoteVideoReplay(remoteUid);
            }
          },
          onTokenPrivilegeWillExpire: (connection, expiringToken) async {
            final channel = AgoraCallManager.channelName;
            final myUid = AgoraCallManager.myUid;
            if (channel == null || myUid == null) return;

            try {
              final freshToken = await getAgoraToken(channel, myUid);
              if (freshToken != null && freshToken.isNotEmpty) {
                await engine.renewToken(freshToken);
              }
            } catch (e) {
              debugPrint('Agora token renewal failed: $e');
            }
          },
        ),
      );

      if (isVideoCall) {
        step = 'enabling video';
        await engine.enableVideo();
        step = 'starting preview';
        await engine.startPreview();
        AgoraCallManager.lastLocalVideoState =
            'video enabled and preview started';
      }

      step = 'joining channel';
      await engine.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      if (!kIsWeb) {
        try {
          await engine
              .setEnableSpeakerphone(true)
              .timeout(const Duration(seconds: 5));
        } catch (e) {
          debugPrint('Speakerphone setup failed: $e');
        }
      }

      debugPrint('AgoraCallManager: joinAgoraCall completed successfully'
          '${attempt > 1 ? ' (on retry $attempt)' : ''}');
      return 'SUCCESS';
    } catch (e) {
      lastError = 'ERROR at step "$step": $e';
      debugPrint('joinAgoraCall attempt $attempt failed at "$step": $e');

      try {
        await AgoraCallManager.engine?.leaveChannel();
      } catch (_) {}
      try {
        await AgoraCallManager.engine?.release();
      } catch (_) {}
      AgoraCallManager.engine = null;

      if (attempt < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 900));
      }
    }
  }

  return lastError;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
