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
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:just_audio/just_audio.dart';

// ---------- tone generation (no internet file needed) ----------
const int _kRate = 16000;

void _addTone(List<double> out, List<double> freqs, double secs, double amp,
    {double harmonic = 0}) {
  final n = (secs * _kRate).round();
  final fade = (0.012 * _kRate).round();
  for (int i = 0; i < n; i++) {
    final t = i / _kRate;
    double v = 0;
    for (final f in freqs) {
      v += math.sin(2 * math.pi * f * t);
      if (harmonic > 0) v += harmonic * math.sin(2 * math.pi * f * 2 * t);
    }
    v = v / freqs.length * amp;
    double env = 1.0;
    if (i < fade) env = i / fade;
    if (n - i < fade) env = (n - i) / fade;
    out.add(v * env);
  }
}

void _addSilence(List<double> out, double secs) {
  final n = (secs * _kRate).round();
  for (int i = 0; i < n; i++) {
    out.add(0.0);
  }
}

Uint8List _toWav(List<double> samples) {
  final dataLen = samples.length * 2;
  final b = ByteData(44 + dataLen);
  void str(int o, String s) {
    for (int i = 0; i < s.length; i++) {
      b.setUint8(o + i, s.codeUnitAt(i));
    }
  }

  str(0, 'RIFF');
  b.setUint32(4, 36 + dataLen, Endian.little);
  str(8, 'WAVE');
  str(12, 'fmt ');
  b.setUint32(16, 16, Endian.little);
  b.setUint16(20, 1, Endian.little);
  b.setUint16(22, 1, Endian.little);
  b.setUint32(24, _kRate, Endian.little);
  b.setUint32(28, _kRate * 2, Endian.little);
  b.setUint16(32, 2, Endian.little);
  b.setUint16(34, 16, Endian.little);
  str(36, 'data');
  b.setUint32(40, dataLen, Endian.little);
  for (int i = 0; i < samples.length; i++) {
    final v = (samples[i].clamp(-1.0, 1.0) * 32767).round();
    b.setInt16(44 + i * 2, v, Endian.little);
  }
  return b.buffer.asUint8List();
}

final Map<String, Uint8List> _cache = {};

Uint8List _bytesFor(String mode) {
  return _cache.putIfAbsent(mode, () {
    final s = <double>[];
    if (mode == 'ringback') {
      // caller hears: 2s tone, 3s pause (classic phone ringback)
      _addTone(s, [440, 480], 2.0, 0.45);
      _addSilence(s, 3.0);
    } else {
      // callee ringtone: two melodic bursts, then a pause
      for (int k = 0; k < 2; k++) {
        _addTone(s, [880], 0.28, 0.6, harmonic: 0.3);
        _addTone(s, [1175], 0.28, 0.6, harmonic: 0.3);
        _addTone(s, [880], 0.28, 0.6, harmonic: 0.3);
        _addSilence(s, 0.18);
      }
      _addSilence(s, 1.3);
    }
    return _toWav(s);
  });
}

class _ToneSource extends StreamAudioSource {
  final Uint8List bytes;
  _ToneSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/wav',
    );
  }
}

// ---------- engine ----------
class _CallToneEngine {
  static AudioPlayer? _player;
  static String? _mode;
  static int _gen = 0;

  static Future<void> start(String mode) async {
    if (_mode == mode && _player != null) return;
    await stop();
    final my = ++_gen;
    _mode = mode;
    final p = AudioPlayer();
    _player = p;
    try {
      await p.setAudioSource(_ToneSource(_bytesFor(mode)));
      if (my != _gen) {
        try {
          await p.dispose();
        } catch (_) {}
        return;
      }
      await p.setLoopMode(LoopMode.one);
      await p.setVolume(1.0);
      unawaited(p.play().catchError((_) {}));
    } catch (_) {
      if (identical(_player, p)) {
        _player = null;
        _mode = null;
      }
      try {
        await p.dispose();
      } catch (_) {}
    }
  }

  static Future<void> stop() async {
    _gen++;
    final p = _player;
    _player = null;
    _mode = null;
    if (p != null) {
      try {
        await p.stop();
      } catch (_) {}
      try {
        await p.dispose();
      } catch (_) {}
    }
  }
}

// mode: 'ringtone' (callee hears), 'ringback' (caller hears), 'stop'
Future callTone(String mode) async {
  if (mode == 'stop') {
    await _CallToneEngine.stop();
  } else if (mode == 'ringtone' || mode == 'ringback') {
    await _CallToneEngine.start(mode);
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
