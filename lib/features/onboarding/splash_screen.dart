import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';

/// Opening screen: the Z mark with a light sweep flowing across it,
/// then a clean hand-off to home. Continues seamlessly from the native
/// launch frame (same background, same centered logo).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        context.go('/home');
      }
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
      backgroundColor: ZTokens.bg,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // The sweep runs twice within the intro, left to right.
            final t = Curves.easeInOut
                .transform((_controller.value * 2) % 1.0);
            final dx = -1.5 + 3.0 * t;
            return ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment(dx - 0.6, -0.4),
                end: Alignment(dx + 0.6, 0.4),
                colors: [
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.75),
                  Colors.white.withValues(alpha: 0),
                ],
                stops: const [0.35, 0.5, 0.65],
              ).createShader(rect),
              child: child,
            );
          },
          child: Image.asset(
            'assets/images/logo_transparent.png',
            width: 260,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
