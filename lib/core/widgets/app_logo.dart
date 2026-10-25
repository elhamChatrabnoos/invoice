import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

const appName = 'اسکن‌یار';
const appTagline = 'اسکن کن، فاکتور بگیر';

/// The Scan-yar mark: a receipt with a barcode inside a camera viewfinder,
/// crossed by a glowing scan beam. [scan] moves the beam (0 = top, 1 = bottom).
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 96,
    this.scan = .5,
    this.shadow = true,
  });

  final double size;
  final double scan;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: shadow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(size * .28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .35),
                  blurRadius: size * .3,
                  offset: Offset(0, size * .12),
                ),
              ],
            )
          : null,
      child: CustomPaint(painter: LogoPainter(scan: scan)),
    );
  }
}

class LogoPainter extends CustomPainter {
  LogoPainter({this.scan = .5, this.rounded = true, this.background = true});

  final double scan;
  final bool rounded;

  /// False paints only the glyph, e.g. for Android adaptive-icon foregrounds.
  final bool background;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final rect = Offset.zero & Size(s, s);

    if (background) _paintBackground(canvas, s, rect);
    _paintGlyph(canvas, s);
  }

  void _paintBackground(Canvas canvas, double s, Rect rect) {
    final bg = Paint()..shader = AppColors.brandGradient.createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rounded ? s * .28 : 0)),
      bg,
    );
    // Soft highlight.
    canvas.drawCircle(
      Offset(s * .78, s * .18),
      s * .42,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.white.withValues(alpha: .28),
                Colors.white.withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromCircle(
                center: Offset(s * .78, s * .18),
                radius: s * .42,
              ),
            ),
    );
  }

  void _paintGlyph(Canvas canvas, double s) {
    // Viewfinder corners.
    final corner = Paint()
      ..color = Colors.white.withValues(alpha: .92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final inset = s * .15, len = s * .15;
    for (final (x, y, dx, dy) in [
      (inset, inset, 1.0, 1.0),
      (s - inset, inset, -1.0, 1.0),
      (inset, s - inset, 1.0, -1.0),
      (s - inset, s - inset, -1.0, -1.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(x, y + dy * len)
          ..lineTo(x, y)
          ..lineTo(x + dx * len, y),
        corner,
      );
    }

    // Receipt with zig-zag bottom edge.
    final left = s * .31, right = s * .69, top = s * .25, bottom = s * .75;
    final receipt = Path()
      ..moveTo(left, top + s * .03)
      ..quadraticBezierTo(left, top, left + s * .03, top)
      ..lineTo(right - s * .03, top)
      ..quadraticBezierTo(right, top, right, top + s * .03)
      ..lineTo(right, bottom);
    const teeth = 5;
    final tw = (right - left) / teeth;
    for (var i = 0; i < teeth; i++) {
      final x = right - i * tw;
      receipt
        ..lineTo(x - tw / 2, bottom - s * .035)
        ..lineTo(x - tw, bottom);
    }
    receipt.close();
    canvas.drawShadow(receipt, const Color(0xFF1E1B3A), s * .03, false);
    canvas.drawPath(receipt, Paint()..color = Colors.white);

    // Barcode bars.
    const pattern = [2, 1, 1, 3, 1, 2, 2, 1, 1, 3, 1, 2, 1];
    final barArea = (right - left) - s * .1;
    final unit = barArea / (pattern.fold<int>(0, (a, b) => a + b) * 1.6);
    final bar = Paint()..color = AppColors.primaryDark;
    var x = left + s * .05;
    for (var i = 0; i < pattern.length; i++) {
      final w = pattern[i] * unit;
      canvas.drawRect(Rect.fromLTWH(x, top + s * .08, w, s * .22), bar);
      x += w + unit * .6 * (i.isEven ? 1.2 : 1.0);
    }

    // "Text" lines under the barcode.
    final line = Paint()
      ..color = const Color(0xFFD6D3EA)
      ..strokeWidth = s * .028
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(left + s * .06, top + s * .37),
      Offset(right - s * .06, top + s * .37),
      line,
    );
    canvas.drawLine(
      Offset(left + s * .06, top + s * .43),
      Offset(right - s * .14, top + s * .43),
      line,
    );

    // Scan beam with glow.
    final beamY = s * (.30 + .40 * scan.clamp(0, 1));
    final beamStart = Offset(s * .22, beamY), beamEnd = Offset(s * .78, beamY);
    canvas.drawLine(
      beamStart,
      beamEnd,
      Paint()
        ..color = AppColors.amber.withValues(alpha: .55)
        ..strokeWidth = s * .07
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * .03),
    );
    canvas.drawLine(
      beamStart,
      beamEnd,
      Paint()
        ..color = AppColors.amber
        ..strokeWidth = s * .03
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      beamEnd,
      s * .018,
      Paint()..color = Colors.white.withValues(alpha: .9),
    );
    canvas.drawCircle(
      beamStart,
      s * .018,
      Paint()..color = Colors.white.withValues(alpha: .9),
    );
  }

  @override
  bool shouldRepaint(LogoPainter old) =>
      old.scan != scan ||
      old.rounded != rounded ||
      old.background != background;
}

/// Rasterises the logo, e.g. for embedding in PDFs or generating app icons.
Future<Uint8List> renderLogoPng({
  double size = 512,
  bool rounded = true,
  bool background = true,
}) async {
  final recorder = ui.PictureRecorder();
  LogoPainter(
    rounded: rounded,
    background: background,
  ).paint(Canvas(recorder), Size.square(size));
  final image = await recorder.endRecording().toImage(
    size.round(),
    size.round(),
  );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return bytes!.buffer.asUint8List();
}

/// Logo whose scan beam sweeps up and down forever.
class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key, this.size = 120});

  final double size;

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, _) => AppLogo(
      size: widget.size,
      scan: (1 - math.cos(_c.value * math.pi)) / 2,
    ),
  );
}
