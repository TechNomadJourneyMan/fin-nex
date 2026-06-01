// Fullscreen-ish overlay shown while recording / uploading.
//
// Draws an animated bank of vertical bars via a [CustomPainter] whose heights
// re-randomize on every animation tick, alongside the live transcript and a
// Cancel button.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';

/// Overlay surface used during voice capture.
class VoiceOverlay extends StatefulWidget {
  /// Creates the overlay.
  const VoiceOverlay({
    super.key,
    required this.transcript,
    required this.onCancel,
    this.isUploading = false,
    this.barCount = 24,
  });

  /// Live (partial) transcript to display.
  final String transcript;

  /// Invoked when the user taps Cancel.
  final VoidCallback onCancel;

  /// When true, shows an "uploading" affordance instead of the live waveform.
  final bool isUploading;

  /// Number of waveform bars.
  final int barCount;

  @override
  State<VoiceOverlay> createState() => _VoiceOverlayState();
}

class _VoiceOverlayState extends State<VoiceOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  final Random _rng = Random();
  late List<double> _heights;

  @override
  void initState() {
    super.initState();
    _heights = _randomHeights();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    )..addStatusListener(_onTick);
    if (!widget.isUploading) {
      _ticker.forward();
    }
  }

  @override
  void didUpdateWidget(covariant VoiceOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isUploading && _ticker.isAnimating) {
      _ticker.stop();
    } else if (!widget.isUploading && !_ticker.isAnimating) {
      _ticker.forward(from: 0);
    }
  }

  void _onTick(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted && !widget.isUploading) {
      setState(() => _heights = _randomHeights());
      _ticker.forward(from: 0);
    }
  }

  List<double> _randomHeights() {
    return List<double>.generate(
      widget.barCount,
      (_) => 0.15 + _rng.nextDouble() * 0.85,
    );
  }

  @override
  void dispose() {
    _ticker
      ..removeStatusListener(_onTick)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final spacing = context.fnxSpacing;

    return Semantics(
      container: true,
      label: widget.isUploading ? 'Transcribing' : 'Listening',
      child: ColoredBox(
        color: colors.background.withValues(alpha: 0.94),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(spacing.s6),
            child: Column(
              children: [
                const Spacer(),
                Text(
                  widget.isUploading ? 'Transcribing…' : 'Listening…',
                  style: typo.heading2,
                ),
                SizedBox(height: spacing.s6),
                SizedBox(
                  height: 96,
                  width: double.infinity,
                  child: widget.isUploading
                      ? Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(colors.brand),
                            ),
                          ),
                        )
                      : CustomPaint(
                          painter: _WaveformPainter(
                            heights: _heights,
                            color: colors.brand,
                          ),
                        ),
                ),
                SizedBox(height: spacing.s6),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Text(
                    widget.transcript.isEmpty
                        ? 'Say something like "spent 1500 on coffee"'
                        : widget.transcript,
                    textAlign: TextAlign.center,
                    style: widget.transcript.isEmpty
                        ? typo.bodyMd.copyWith(color: colors.textMuted)
                        : typo.bodyLg,
                  ),
                ),
                const Spacer(),
                PfButton(
                  label: 'Cancel',
                  variant: PfButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: widget.onCancel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints [heights] (each in `[0, 1]`) as centered vertical bars.
class _WaveformPainter extends CustomPainter {
  _WaveformPainter({required this.heights, required this.color});

  final List<double> heights;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (heights.isEmpty) {
      return;
    }
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    const gap = 4.0;
    final barWidth = (size.width - gap * (heights.length - 1)) / heights.length;
    final midY = size.height / 2;
    for (var i = 0; i < heights.length; i++) {
      final barHeight = heights[i] * size.height;
      final left = i * (barWidth + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, midY - barHeight / 2, barWidth, barHeight),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.heights != heights || oldDelegate.color != color;
}
