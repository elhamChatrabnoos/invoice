import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/common.dart';
import '../../cart/application/cart_controller.dart';
import '../../products/application/products_controller.dart';
import '../../products/presentation/product_sheets.dart';

/// Opens the scanner; if the user leaves it via the cart pill, switches to
/// the cart tab.
Future<void> openScanner(BuildContext context) async {
  final result = await context.push<String>(AppRoutes.scan);
  if (result == _openCartResult && context.mounted) context.go(AppRoutes.cart);
}

const _openCartResult = '__open_cart__';

/// Full-screen camera scanner.
///
/// In normal mode every scanned code is looked up and offered for the cart.
/// With [pickOnly] the screen just returns the first scanned code.
class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key, this.pickOnly = false});

  final bool pickOnly;

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage>
    with SingleTickerProviderStateMixin {
  final _controller = MobileScannerController(
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.itf14,
      BarcodeFormat.qrCode,
    ],
  );
  late final _laser = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  bool _busy = false;
  String? _lastCode;
  DateTime _lastAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void dispose() {
    _laser.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final code = capture.barcodes
        .map((b) => b.rawValue?.trim())
        .whereType<String>()
        .where((c) => c.isNotEmpty)
        .firstOrNull;
    if (code == null || _busy) return;
    // Ignore the same code right after handling it, so the camera
    // doesn't immediately re-trigger on the product still in view.
    if (code == _lastCode &&
        DateTime.now().difference(_lastAt) < const Duration(seconds: 2)) {
      return;
    }
    unawaited(_handle(code));
  }

  Future<void> _handle(String code) async {
    setState(() => _busy = true);
    unawaited(HapticFeedback.mediumImpact());
    unawaited(SystemSound.play(SystemSoundType.click));

    if (widget.pickOnly) {
      context.pop(code);
      return;
    }

    final product = ref
        .read(productsControllerProvider.notifier)
        .findByCode(code);
    if (product != null) {
      final qty = await showProductFoundSheet(context, product);
      if (qty != null && mounted) {
        showToast(context, '${product.name} × ${fa(qty)} به سبد اضافه شد');
      }
    } else {
      final created = await showProductFormSheet(
        context,
        code: code,
        isNewScan: true,
      );
      if (created != null && mounted) {
        ref.read(cartControllerProvider.notifier).add(created);
        showToast(context, '${created.name} ثبت و به سبد اضافه شد');
      }
    }

    if (!mounted) return;
    setState(() {
      _busy = false;
      _lastCode = code;
      _lastAt = DateTime.now();
    });
  }

  Future<void> _manualEntry() async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const _ManualEntryDialog(),
    );
    final normalized = toLatinDigits(code ?? '').trim();
    if (normalized.isNotEmpty && mounted) await _handle(normalized);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final windowWidth = size.width * .78;
            final window = Rect.fromCenter(
              center: Offset(size.width / 2, size.height * .42),
              width: windowWidth,
              height: windowWidth * .62,
            );
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                    errorBuilder: (context, error) =>
                        _CameraError(error: error),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(painter: _ViewfinderPainter(window)),
                ),
                // Animated laser.
                AnimatedBuilder(
                  animation: _laser,
                  builder: (_, _) => Positioned(
                    left: window.left + 14,
                    width: window.width - 28,
                    top: window.top + 12 + (window.height - 24) * _laser.value,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: AppColors.amber,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.amber.withValues(alpha: .8),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: window.bottom + 24,
                  left: 24,
                  right: 24,
                  child: Text(
                    widget.pickOnly
                        ? 'بارکد کالا را داخل کادر قرار دهید'
                        : 'بارکد را داخل کادر قرار دهید\nپس از شناسایی، کالا نمایش داده می‌شود',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      height: 1.9,
                    ),
                  ),
                ),
                _topBar(),
                if (!widget.pickOnly) _bottomBar(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _topBar() => Positioned(
    left: 0,
    right: 0,
    top: 0,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _GlassButton(icon: Icons.close_rounded, onTap: () => context.pop()),
            const Expanded(
              child: Text(
                'اسکن بارکد',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (_, state, _) {
                final torch = state.torchState;
                return _GlassButton(
                  icon: torch == TorchState.on
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_rounded,
                  active: torch == TorchState.on,
                  onTap: torch == TorchState.unavailable
                      ? null
                      : _controller.toggleTorch,
                );
              },
            ),
          ],
        ),
      ),
    ),
  );

  Widget _bottomBar() => Positioned(
    left: 0,
    right: 0,
    bottom: 0,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            _GlassButton(
              icon: Icons.keyboard_alt_outlined,
              onTap: _manualEntry,
              size: 60,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CartPill(onTap: () => context.pop(_openCartResult)),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CartPill extends ConsumerWidget {
  const _CartPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartCountProvider);
    final total = ref.watch(cartTotalProvider);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              const SizedBox(width: 10),
              Badge(
                label: Text(fa(count)),
                isLabelVisible: count > 0,
                backgroundColor: AppColors.teal,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'سبد خرید',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                    Text(
                      toman(total),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded, color: AppColors.muted),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.onTap,
    this.active = false,
    this.size = 48,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.amber : Colors.white.withValues(alpha: .18),
      borderRadius: BorderRadius.circular(size * .36),
      child: InkWell(
        borderRadius: BorderRadius.circular(size * .36),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            color: active
                ? AppColors.ink
                : Colors.white.withValues(alpha: onTap == null ? .4 : 1),
          ),
        ),
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  _ViewfinderPainter(this.window);

  final Rect window;

  @override
  void paint(Canvas canvas, Size size) {
    final hole = RRect.fromRectAndRadius(window, const Radius.circular(24));
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(hole),
      ),
      Paint()..color = Colors.black.withValues(alpha: .58),
    );

    final corner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const len = 34.0, r = 24.0;
    final l = window.left, t = window.top, rt = window.right, b = window.bottom;
    canvas
      ..drawPath(
        Path()
          ..moveTo(l, t + len)
          ..lineTo(l, t + r)
          ..arcToPoint(Offset(l + r, t), radius: const Radius.circular(r))
          ..lineTo(l + len, t),
        corner,
      )
      ..drawPath(
        Path()
          ..moveTo(rt - len, t)
          ..lineTo(rt - r, t)
          ..arcToPoint(Offset(rt, t + r), radius: const Radius.circular(r))
          ..lineTo(rt, t + len),
        corner,
      )
      ..drawPath(
        Path()
          ..moveTo(rt, b - len)
          ..lineTo(rt, b - r)
          ..arcToPoint(Offset(rt - r, b), radius: const Radius.circular(r))
          ..lineTo(rt - len, b),
        corner,
      )
      ..drawPath(
        Path()
          ..moveTo(l + len, b)
          ..lineTo(l + r, b)
          ..arcToPoint(Offset(l, b - r), radius: const Radius.circular(r))
          ..lineTo(l, b - len),
        corner,
      );
  }

  @override
  bool shouldRepaint(_ViewfinderPainter old) => old.window != window;
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return ColoredBox(
      color: AppColors.ink,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_rounded,
                color: Colors.white70,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                denied
                    ? 'دسترسی به دوربین داده نشده است'
                    : 'دوربین در دسترس نیست',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                denied
                    ? 'لطفاً از تنظیمات گوشی اجازهٔ دسترسی به دوربین را فعال کنید.\nتا آن زمان می‌توانید بارکد را دستی وارد کنید.'
                    : 'می‌توانید بارکد را به‌صورت دستی وارد کنید.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, height: 1.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManualEntryDialog extends StatefulWidget {
  const _ManualEntryDialog();

  @override
  State<_ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<_ManualEntryDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ورود دستی بارکد'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        textDirection: TextDirection.ltr,
        decoration: const InputDecoration(
          hintText: 'مثلاً ۶۲۶۰۱۰۰۵۰۰۰۱۸',
          prefixIcon: Icon(Icons.qr_code_rounded),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('انصراف'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
          onPressed: _submit,
          child: const Text('جستجو'),
        ),
      ],
    );
  }
}
