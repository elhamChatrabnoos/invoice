import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_logo.dart';
import '../onboarding/data/onboarding_repository.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  late final _logoScale = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0, .6, curve: Curves.elasticOut),
  );
  late final _textFade = CurvedAnimation(
    parent: _intro,
    curve: const Interval(.4, 1, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _boot();
  }

  static const _duration = Duration(milliseconds: 2600);

  Future<void> _boot() async {
    await Future<void>.delayed(_duration);
    if (!mounted) return;
    final onboarded = ref.read(onboardingRepositoryProvider).isCompleted;
    context.go(onboarded ? AppRoutes.home : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          child: Stack(
            children: [
              // Decorative blurred circles.
              Positioned(top: -80, left: -60, child: _bubble(220, .10)),
              Positioned(bottom: -100, right: -70, child: _bubble(280, .08)),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _logoScale,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .16),
                          borderRadius: BorderRadius.circular(48),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .3),
                          ),
                        ),
                        child: const AnimatedLogo(size: 132),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, .4),
                          end: Offset.zero,
                        ).animate(_textFade),
                        child: const Column(
                          children: [
                            Text(
                              appName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              appTagline,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _textFade,
                  child: const Center(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
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

  Widget _bubble(double size, double alpha) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: alpha),
    ),
  );
}
