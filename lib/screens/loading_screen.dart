import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../mainscaffhold.dart';

const _black = Color(0xFF1A1A1A);
const _walnut = Color(0xFF8B5A2B);
const _white = Colors.white;
const _grey = Color(0xFF9E9E9E);

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _slash1;
  late final Animation<double> _slash2;
  late final Animation<double> _slash3;
  late final Animation<double> _slash4;
  late final Animation<double> _overlayOpacity;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Four slashes sweep across in quick succession
    _slash1 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.00, 0.18, curve: Curves.easeIn),
    );
    _slash2 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.10, 0.28, curve: Curves.easeIn),
    );
    _slash3 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.18, 0.38, curve: Curves.easeIn),
    );
    _slash4 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.26, 0.46, curve: Curves.easeIn),
    );

    // Dark overlay lifts after slashes to reveal background
    _overlayOpacity = Tween<double>(begin: 0.92, end: 0.60).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.58, curve: Curves.easeOut),
      ),
    );

    // Logo pops in with a scale + fade
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 0.70, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 0.70, curve: Curves.easeOutBack),
      ),
    );

    // Bottom text fades in last
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.68, 0.88, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const MainScaffold(),
            transitionsBuilder: (_, anim, _, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset('assets/filler.jpg', fit: BoxFit.cover),

          // Dark overlay that lifts as animation progresses
          AnimatedBuilder(
            animation: _overlayOpacity,
            builder: (_, _) => ColoredBox(
              color: Color.fromRGBO(26, 26, 26, _overlayOpacity.value),
            ),
          ),

          // Slash streaks
          AnimatedBuilder(
            animation: _controller,
            builder: (_, _) => CustomPaint(
              painter: _SlashesPainter(
                s1: _slash1.value,
                s2: _slash2.value,
                s3: _slash3.value,
                s4: _slash4.value,
              ),
            ),
          ),

          // Centered logo + branding
          AnimatedBuilder(
            animation: Listenable.merge([_logoOpacity, _logoScale]),
            builder: (_, _) => Opacity(
              opacity: _logoOpacity.value,
              child: Transform.scale(
                scale: _logoScale.value,
                child: const Center(child: _BrandingContent()),
              ),
            ),
          ),

          // Bottom loading text
          AnimatedBuilder(
            animation: _textOpacity,
            builder: (_, _) => Positioned(
              bottom: 56,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: _textOpacity.value,
                child: const Column(
                  children: [
                    Text(
                      'Preparing your kitchen...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _grey,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 14),
                    _PulsingDots(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slash painter ──────────────────────────────────────────────────────────────

class _SlashesPainter extends CustomPainter {
  const _SlashesPainter({
    required this.s1,
    required this.s2,
    required this.s3,
    required this.s4,
  });

  final double s1, s2, s3, s4;

  // Slash config: (progress, width, color, tiltDeg)
  static const _slashes = [
    // wide walnut warm flash
    (0, 110.0, Color(0xBB9C6B3C), 14.0),
    // narrow bright white streak
    (1, 40.0, Color(0x99FFFFFF), 12.0),
    // medium dark walnut
    (2, 80.0, Color(0xDD7B4A1E), 16.0),
    // thin bright accent
    (3, 28.0, Color(0xCCFFDDB0), 10.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final progresses = [s1, s2, s3, s4];
    for (final (idx, width, color, tiltDeg) in _slashes) {
      _paintSlash(canvas, size, progresses[idx], width, color, tiltDeg);
    }
  }

  void _paintSlash(
    Canvas canvas,
    Size size,
    double progress,
    double slashWidth,
    Color color,
    double tiltDeg,
  ) {
    if (progress <= 0) return;

    final tilt = size.height * math.tan(tiltDeg * math.pi / 180);
    final travel = size.width + slashWidth + tilt.abs();
    final x = travel * progress - slashWidth - tilt.abs();

    final path = Path()
      ..moveTo(x, 0)
      ..lineTo(x + slashWidth, 0)
      ..lineTo(x + slashWidth + tilt, size.height)
      ..lineTo(x + tilt, size.height)
      ..close();

    final rect = Rect.fromLTWH(x, 0, slashWidth + tilt.abs(), size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, color, Colors.transparent],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(rect);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SlashesPainter old) =>
      old.s1 != s1 || old.s2 != s2 || old.s3 != s3 || old.s4 != s4;
}

// ── Branding block ─────────────────────────────────────────────────────────────

class _BrandingContent extends StatelessWidget {
  const _BrandingContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo circle
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _walnut, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x608B5A2B),
                blurRadius: 36,
                spreadRadius: 6,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/filler.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Savr',
          style: TextStyle(
            color: _white,
            fontSize: 44,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Cut costs, not flavor.',
          style: TextStyle(
            color: _walnut,
            fontSize: 13,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ── Pulsing dots ───────────────────────────────────────────────────────────────

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final phase = ((_ctrl.value - i / 3) % 1.0 + 1.0) % 1.0;
          final opacity =
              (math.sin(phase * math.pi * 2) * 0.5 + 0.5).clamp(0.15, 1.0);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _walnut,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
