// Procedural WAV generator for pf_core_feedback's sound cues.
//
// Produces tiny PCM-16 mono 44.1kHz WAV files with deterministic, royalty-free
// tones. Run from the repo root:
//
//     dart run tools/gen_sounds.dart
//
// Outputs to packages/core/feedback/assets/sounds/.

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int _kSampleRate = 44100;
const int _kBitsPerSample = 16;
const int _kChannels = 1;

void main() {
  final String outDir = 'packages/core/feedback/assets/sounds';
  Directory(outDir).createSync(recursive: true);

  _write('$outDir/tap.wav', _genTap());
  _write('$outDir/success.wav', _genSuccess());
  _write('$outDir/error.wav', _genError());
  _write('$outDir/achievement.wav', _genAchievement());
}

void _write(String path, Uint8List data) {
  final File f = File(path);
  f.writeAsBytesSync(data);
  final int sizeKb = (data.lengthInBytes / 1024).round();
  // ignore: avoid_print
  print('wrote $path  ${data.lengthInBytes} bytes  (~${sizeKb}KB)');
}

// ---------------------------------------------------------------------------
// Generators
// ---------------------------------------------------------------------------

/// 40ms, ~600Hz sine with a fast exponential decay envelope.
Uint8List _genTap() {
  return _encodeWav(_synthesize(
    durationMs: 40,
    sampler: (double t) {
      final double env = math.exp(-t * 60); // ~17ms half-life
      return math.sin(2 * math.pi * 600 * t) * env * 0.85;
    },
  ));
}

/// 200ms total. Three-note ascending C-major triad: C5 / E5 / G5.
/// Each note ~30ms attack with sustain blended together via additive synthesis
/// for a chord-like "ding".
Uint8List _genSuccess() {
  const double c5 = 523.25;
  const double e5 = 659.25;
  const double g5 = 783.99;
  return _encodeWav(_synthesize(
    durationMs: 200,
    sampler: (double t) {
      // Stagger note onsets: C at 0ms, E at 40ms, G at 80ms.
      final double aC = _attackRelease(t, 0.000, 0.030, 0.140);
      final double aE = _attackRelease(t, 0.040, 0.030, 0.120);
      final double aG = _attackRelease(t, 0.080, 0.030, 0.100);
      final double s = math.sin(2 * math.pi * c5 * t) * aC +
          math.sin(2 * math.pi * e5 * t) * aE +
          math.sin(2 * math.pi * g5 * t) * aG;
      return s / 3 * 0.9;
    },
  ));
}

/// 150ms total. Descending minor second E5 -> Eb5 (75ms each).
Uint8List _genError() {
  const double e5 = 659.25;
  const double eb5 = 622.25;
  return _encodeWav(_synthesize(
    durationMs: 150,
    sampler: (double t) {
      final bool first = t < 0.075;
      final double freq = first ? e5 : eb5;
      // Gentle attack/release per note so the boundary isn't a click.
      final double envT = first ? t : (t - 0.075);
      final double env = _attackRelease(envT, 0.000, 0.008, 0.060);
      return math.sin(2 * math.pi * freq * t) * env * 0.85;
    },
  ));
}

/// 400ms total. Ascending major arpeggio: C5 / E5 / G5 / C6 at 100ms each.
Uint8List _genAchievement() {
  const List<double> freqs = <double>[523.25, 659.25, 783.99, 1046.50];
  return _encodeWav(_synthesize(
    durationMs: 400,
    sampler: (double t) {
      final int idx = (t / 0.100).floor().clamp(0, 3);
      final double freq = freqs[idx];
      final double localT = t - idx * 0.100;
      final double env = _attackRelease(localT, 0.000, 0.010, 0.085);
      return math.sin(2 * math.pi * freq * t) * env * 0.85;
    },
  ));
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Triangular attack/release envelope for [t] in seconds.
/// Returns 0 outside [startSec, startSec+attack+release].
double _attackRelease(double t, double startSec, double attack, double release) {
  if (t < startSec) return 0;
  final double dt = t - startSec;
  if (dt < attack) return dt / attack;
  if (dt < attack + release) return 1 - (dt - attack) / release;
  return 0;
}

/// Produce a list of float samples in [-1, 1] for [durationMs].
List<double> _synthesize({
  required int durationMs,
  required double Function(double tSeconds) sampler,
}) {
  final int n = (_kSampleRate * durationMs / 1000).round();
  final List<double> out = List<double>.filled(n, 0);
  for (int i = 0; i < n; i++) {
    final double t = i / _kSampleRate;
    final double s = sampler(t);
    out[i] = s.clamp(-1.0, 1.0);
  }
  return out;
}

/// Encode mono PCM-16 samples into a complete WAV byte buffer.
Uint8List _encodeWav(List<double> samples) {
  final int dataLen = samples.length * (_kBitsPerSample ~/ 8);
  final int riffLen = 36 + dataLen;
  final int byteRate =
      _kSampleRate * _kChannels * (_kBitsPerSample ~/ 8);
  final int blockAlign = _kChannels * (_kBitsPerSample ~/ 8);

  final BytesBuilder bb = BytesBuilder(copy: false);

  // RIFF header
  bb.add(_ascii('RIFF'));
  bb.add(_u32(riffLen));
  bb.add(_ascii('WAVE'));

  // fmt chunk
  bb.add(_ascii('fmt '));
  bb.add(_u32(16)); // PCM fmt chunk size
  bb.add(_u16(1)); // PCM
  bb.add(_u16(_kChannels));
  bb.add(_u32(_kSampleRate));
  bb.add(_u32(byteRate));
  bb.add(_u16(blockAlign));
  bb.add(_u16(_kBitsPerSample));

  // data chunk
  bb.add(_ascii('data'));
  bb.add(_u32(dataLen));

  // PCM samples
  final ByteData bd = ByteData(dataLen);
  for (int i = 0; i < samples.length; i++) {
    final int v = (samples[i] * 32767).round().clamp(-32768, 32767);
    bd.setInt16(i * 2, v, Endian.little);
  }
  bb.add(bd.buffer.asUint8List());

  return bb.takeBytes();
}

List<int> _ascii(String s) => s.codeUnits;

List<int> _u32(int v) {
  final ByteData bd = ByteData(4);
  bd.setUint32(0, v, Endian.little);
  return bd.buffer.asUint8List();
}

List<int> _u16(int v) {
  final ByteData bd = ByteData(2);
  bd.setUint16(0, v, Endian.little);
  return bd.buffer.asUint8List();
}
