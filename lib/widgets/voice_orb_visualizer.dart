import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../services/stt_service.dart';

/// An animated, multi-state pulsing orb designed specifically for APDM's voice interface.
/// Seamlessly reflects: Ready, Listening, Processing, and AI Speaking states.
class VoiceOrbVisualizer extends StatefulWidget {
  final VoiceState state;
  final VoidCallback? onTap;
  final double size;

  const VoiceOrbVisualizer({
    super.key,
    required this.state,
    this.onTap,
    this.size = 220,
  });

  @override
  State<VoiceOrbVisualizer> createState() => _VoiceOrbVisualizerState();
}

class _VoiceOrbVisualizerState extends State<VoiceOrbVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant VoiceOrbVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _adjustAnimationSpeedForState(widget.state);
    }
  }

  void _adjustAnimationSpeedForState(VoiceState state) {
    switch (state) {
      case VoiceState.ready:
        _pulseController.duration = const Duration(milliseconds: 2400);
        _pulseController.repeat(reverse: true);
        break;
      case VoiceState.listening:
        _pulseController.duration = const Duration(milliseconds: 900);
        _pulseController.repeat(reverse: true);
        break;
      case VoiceState.processing:
        _pulseController.duration = const Duration(milliseconds: 1500);
        _pulseController.repeat(reverse: true);
        break;
      case VoiceState.speaking:
        _pulseController.duration = const Duration(milliseconds: 1100);
        _pulseController.repeat(reverse: true);
        break;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Color _getStateColor() {
    switch (widget.state) {
      case VoiceState.ready:
        return AppColors.voiceReady;
      case VoiceState.listening:
        return AppColors.voiceListening;
      case VoiceState.processing:
        return AppColors.voiceProcessing;
      case VoiceState.speaking:
        return AppColors.voiceSpeaking;
    }
  }

  IconData _getStateIcon() {
    switch (widget.state) {
      case VoiceState.ready:
        return Icons.mic_none_rounded;
      case VoiceState.listening:
        return Icons.graphic_eq_rounded;
      case VoiceState.processing:
        return Icons.auto_awesome_rounded;
      case VoiceState.speaking:
        return Icons.volume_up_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateColor = _getStateColor();

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _pulseController,
            _waveController,
            _rotationController,
          ]),
          builder: (context, child) {
            return CustomPaint(
              painter: _VoiceOrbPainter(
                state: widget.state,
                pulseValue: _pulseController.value,
                waveValue: _waveController.value,
                rotationAngle: _rotationController.value * 2 * math.pi,
                color: stateColor,
              ),
              child: Center(
                child: Container(
                  width: widget.size * 0.42,
                  height: widget.size * 0.42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        stateColor.withAlpha(230),
                        stateColor.withAlpha(160),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: stateColor.withAlpha(100),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    _getStateIcon(),
                    color: Colors.white,
                    size: widget.size * 0.18,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VoiceOrbPainter extends CustomPainter {
  final VoiceState state;
  final double pulseValue;
  final double waveValue;
  final double rotationAngle;
  final Color color;

  _VoiceOrbPainter({
    required this.state,
    required this.pulseValue,
    required this.waveValue,
    required this.rotationAngle,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    switch (state) {
      case VoiceState.ready:
        _paintReadyState(canvas, center, maxRadius);
        break;
      case VoiceState.listening:
        _paintListeningState(canvas, center, maxRadius);
        break;
      case VoiceState.processing:
        _paintProcessingState(canvas, center, maxRadius);
        break;
      case VoiceState.speaking:
        _paintSpeakingState(canvas, center, maxRadius);
        break;
    }
  }

  void _paintReadyState(Canvas canvas, Offset center, double maxRadius) {
    // Gentle breathing halo
    final radius = maxRadius * (0.65 + 0.08 * pulseValue);
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withAlpha(60),
          color.withAlpha(20),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.3));

    canvas.drawCircle(center, radius * 1.25, haloPaint);

    final linePaint = Paint()
      ..color = color.withAlpha(75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius, linePaint);
  }

  void _paintListeningState(Canvas canvas, Offset center, double maxRadius) {
    // Expanding concentric acoustic waves
    for (var i = 0; i < 3; i++) {
      final progress = (waveValue + i * 0.33) % 1.0;
      final waveRadius = (maxRadius * 0.45) + (progress * maxRadius * 0.52);
      final alpha = ((1.0 - progress) * 160).round().clamp(0, 255);

      final wavePaint = Paint()
        ..color = color.withAlpha(alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 - (progress * 1.2);

      canvas.drawCircle(center, waveRadius, wavePaint);
    }

    // Outer reactive glow
    final glowRadius = maxRadius * (0.75 + 0.12 * pulseValue);
    final glowPaint = Paint()
      ..color = color.withAlpha(45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    canvas.drawCircle(center, glowRadius, glowPaint);
  }

  void _paintProcessingState(Canvas canvas, Offset center, double maxRadius) {
    // Rotating spiral/orbital reflection rings
    final radius = maxRadius * 0.72;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);

    final sweepGradient = SweepGradient(
      colors: [
        color.withAlpha(20),
        color.withAlpha(120),
        color.withAlpha(240),
        color.withAlpha(20),
      ],
      stops: const [0.0, 0.4, 0.8, 1.0],
    );

    final ringPaint = Paint()
      ..shader = sweepGradient.createShader(Rect.fromCircle(center: Offset.zero, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: radius),
      0,
      math.pi * 1.65,
      false,
      ringPaint,
    );

    canvas.restore();

    // Subtle counter-rotating dashed outer ring
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-rotationAngle * 0.6);

    final outerRingPaint = Paint()
      ..color = color.withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: radius * 1.18),
      0,
      math.pi * 1.2,
      false,
      outerRingPaint,
    );

    canvas.restore();
  }

  void _paintSpeakingState(Canvas canvas, Offset center, double maxRadius) {
    // Rhythmic audio wave spikes around the perimeter
    final baseRadius = maxRadius * (0.62 + 0.05 * pulseValue);
    const numBars = 32;

    for (var i = 0; i < numBars; i++) {
      final angle = (i / numBars) * 2 * math.pi;
      final waveOffset = math.sin((i * 0.8) + (waveValue * 2 * math.pi)) * 0.5 + 0.5;
      final barLength = 6.0 + (waveOffset * 18.0 * (0.7 + 0.3 * pulseValue));

      final startX = center.dx + math.cos(angle) * (baseRadius + 4);
      final startY = center.dy + math.sin(angle) * (baseRadius + 4);
      final endX = center.dx + math.cos(angle) * (baseRadius + 4 + barLength);
      final endY = center.dy + math.sin(angle) * (baseRadius + 4 + barLength);

      final barPaint = Paint()
        ..color = color.withAlpha((140 + waveOffset * 100).round().clamp(0, 255))
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VoiceOrbPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.waveValue != waveValue ||
        oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.state != state ||
        oldDelegate.color != color;
  }
}
