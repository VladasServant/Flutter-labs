import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MyApp());
}

class CustomButtonStyle {
  final Color backgroundColor;
  final Color hoverColor;
  final Color pressedColor;
  final Color disabledColor;
  final Color textColor;
  final Color disabledTextColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final double elevation;
  final EdgeInsetsGeometry padding;

  const CustomButtonStyle({
    required this.backgroundColor,
    required this.hoverColor,
    required this.pressedColor,
    required this.disabledColor,
    required this.textColor,
    required this.disabledTextColor,
    this.borderColor,
    this.borderWidth = 1.5,
    this.borderRadius = 8.0,
    this.elevation = 3.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  });

  factory CustomButtonStyle.primary() {
    return const CustomButtonStyle(
      backgroundColor: Colors.blue,
      hoverColor: Color(0xFF1E88E5),
      pressedColor: Color(0xFF1565C0),
      disabledColor: Color(0xFFBDBDBD),
      textColor: Colors.white,
      disabledTextColor: Color(0xFF757575),
      elevation: 3.0,
    );
  }

  factory CustomButtonStyle.outlined() {
    return const CustomButtonStyle(
      backgroundColor: Colors.white,
      hoverColor: Color(0xFFE3F2FD),
      pressedColor: Color(0xFFBBDEFB),
      disabledColor: Color(0xFFF5F5F5),
      textColor: Colors.blue,
      disabledTextColor: Color(0xFF90CAF9),
      borderColor: Colors.blue,
      borderWidth: 1.5,
      elevation: 0.0,
    );
  }

  factory CustomButtonStyle.warning() {
    return const CustomButtonStyle(
      backgroundColor: Colors.orange,
      hoverColor: Color(0xFFFB8C00),
      pressedColor: Colors.deepOrange,
      disabledColor: Color(0xFFFFE0B2),
      textColor: Colors.white,
      disabledTextColor: Colors.white70,
      elevation: 3.0,
    );
  }
}

class CustomButtonController extends ChangeNotifier {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get isHovered => _isHovered;
  bool get isPressed => _isPressed;

  void setHovered(bool value) {
    if (_isHovered != value) {
      _isHovered = value;
      notifyListeners();
    }
  }

  void setPressed(bool value) {
    if (_isPressed != value) {
      _isPressed = value;
      notifyListeners();
    }
  }

  Color resolveBackgroundColor(CustomButtonStyle style, bool isEnabled) {
    if (!isEnabled) return style.disabledColor;
    if (_isPressed) return style.pressedColor;
    if (_isHovered) return style.hoverColor;
    return style.backgroundColor;
  }

  double resolveElevation(CustomButtonStyle style, bool isEnabled) {
    if (!isEnabled || style.elevation == 0) return 0.0;
    if (_isPressed) return style.elevation * 0.25;
    if (_isHovered) return style.elevation * 1.3;
    return style.elevation;
  }
}

class CustomButtonPainter extends CustomPainter {
  final Color fillColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final double elevation;

  const CustomButtonPainter({
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.elevation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    if (elevation > 0) {
      final Paint shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.24)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, elevation * 1.2);

      final RRect shadowRRect = rrect.shift(Offset(0, elevation * 0.6));
      canvas.drawRRect(shadowRRect, shadowPaint);
    }

    final Paint backgroundPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, backgroundPaint);

    if (borderColor != null && borderWidth > 0) {
      final Paint borderPaint = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;

      final RRect borderRRect = RRect.fromRectAndRadius(
        rect.deflate(borderWidth / 2),
        Radius.circular(borderRadius),
      );
      canvas.drawRRect(borderRRect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomButtonPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.elevation != elevation;
  }
}

class CustomButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final CustomButtonStyle style;

  CustomButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    CustomButtonStyle? style,
  }) : style = style ?? CustomButtonStyle.primary();

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  late final CustomButtonController _controller;

  bool get _isEnabled => widget.onPressed != null;

  @override
  void initState() {
    super.initState();
    _controller = CustomButtonController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = _isEnabled
        ? widget.style.textColor
        : widget.style.disabledTextColor;

    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.label,
      child: MouseRegion(
        cursor: _isEnabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) => _controller.setHovered(true),
        onExit: (_) {
          _controller.setHovered(false);
          _controller.setPressed(false);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _isEnabled ? (_) => _controller.setPressed(true) : null,
          onTapUp: _isEnabled
              ? (_) {
                  _controller.setPressed(false);
                  widget.onPressed?.call();
                }
              : null,
          onTapCancel: _isEnabled ? () => _controller.setPressed(false) : null,
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, child) {
              final currentBg = _controller.resolveBackgroundColor(
                widget.style,
                _isEnabled,
              );
              final currentElevation = _controller.resolveElevation(
                widget.style,
                _isEnabled,
              );

              return CustomPaint(
                painter: CustomButtonPainter(
                  fillColor: currentBg,
                  borderColor: _isEnabled
                      ? widget.style.borderColor
                      : widget.style.borderColor?.withValues(alpha: 0.4),
                  borderWidth: widget.style.borderWidth,
                  borderRadius: widget.style.borderRadius,
                  elevation: currentElevation,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 90),
                  transform: Matrix4.translationValues(
                    0,
                    _controller.isPressed && _isEnabled ? 1.5 : 0.0,
                    0,
                  ),
                  padding: widget.style.padding,
                  child: child,
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 20, color: effectiveTextColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    color: effectiveTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Button Lab',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  bool _isButtonActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Custom Button'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Натискань: $_counter',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Збільшити',
              icon: Icons.add,
              style: CustomButtonStyle.primary(),
              onPressed: _isButtonActive
                  ? () => setState(() => _counter++)
                  : null,
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Скинути',
              style: CustomButtonStyle.outlined(),
              onPressed: () => setState(() => _counter = 0),
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: _isButtonActive ? 'Вимкнути кнопку' : 'Увімкнути кнопку',
              style: CustomButtonStyle.warning(),
              onPressed: () =>
                  setState(() => _isButtonActive = !_isButtonActive),
            ),
          ],
        ),
      ),
    );
  }
}
