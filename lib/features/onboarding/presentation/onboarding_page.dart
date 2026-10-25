import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';
import '../data/onboarding_repository.dart';

@immutable
class _Page {
  const _Page(this.icon, this.badge, this.title, this.body, this.colors);
  final IconData icon;
  final IconData badge;
  final String title;
  final String body;
  final List<Color> colors;
}

const _pages = [
  _Page(
    Icons.qr_code_scanner_rounded,
    Icons.photo_camera_rounded,
    'بارکد را اسکن کنید',
    'دوربین گوشی را روی بارکد کالا بگیرید؛ نام و قیمت آن در یک چشم به هم زدن نمایش داده می‌شود.',
    [Color(0xFF6D5DF6), Color(0xFF4A3BD0)],
  ),
  _Page(
    Icons.shopping_bag_rounded,
    Icons.add_circle_rounded,
    'سبد خرید هوشمند',
    'کالاها را به سبد اضافه کنید، تعدادشان را تغییر دهید و جمع کل را لحظه‌ای ببینید.',
    [Color(0xFF4A3BD0), Color(0xFF1FBFA3)],
  ),
  _Page(
    Icons.receipt_long_rounded,
    Icons.print_rounded,
    'فاکتور زیبا و قابل چاپ',
    'با یک لمس فاکتور رسمی صادر کنید، آن را ذخیره کنید و هر زمان خواستید چاپ یا ارسال کنید.',
    [Color(0xFF1FBFA3), Color(0xFF16A08A)],
  ),
];

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  Future<void> _finish() async {
    await ref.read(onboardingRepositoryProvider).markCompleted();
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Text(
                    fa('${_index + 1} از ${_pages.length}'),
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: _isLast ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: _isLast ? null : _finish,
                      child: const Text('رد شدن'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _OnboardingPage(page: _pages[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: i == _index
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: .2),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: GradientButton(
                label: _isLast ? 'شروع کنید' : 'بعدی',
                icon: _isLast
                    ? Icons.rocket_launch_rounded
                    : Icons.arrow_forward_rounded,
                onPressed: _isLast
                    ? _finish
                    : () => _controller.nextPage(
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOutCubic,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.page});

  final _Page page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: page.colors.first.withValues(alpha: .08),
                  ),
                ),
                Container(
                  width: 196,
                  height: 196,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: page.colors.first.withValues(alpha: .12),
                  ),
                ),
                Container(
                  width: 136,
                  height: 136,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(42),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: page.colors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: page.colors.first.withValues(alpha: .4),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Icon(page.icon, size: 70, color: Colors.white),
                ),
                Positioned(
                  top: 40,
                  left: 40,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .08),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Icon(page.badge, color: page.colors.last, size: 26),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 44),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15.5,
              color: AppColors.muted,
              height: 1.9,
            ),
          ),
        ],
      ),
    );
  }
}
