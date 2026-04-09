import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class WateringButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool compact;

  const WateringButton({
    super.key,
    required this.onPressed,
    this.compact = false,
  });

  @override
  State<WateringButton> createState() => _WateringButtonState();
}

class _WateringButtonState extends State<WateringButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _wasPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    setState(() => _wasPressed = true);
    _controller.forward(from: 0.0).then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _wasPressed = false);
      });
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: ElevatedButton.icon(
          onPressed: _handlePress,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _wasPressed ? Icons.check_circle_rounded : Icons.water_drop_rounded,
              key: ValueKey(_wasPressed),
              size: widget.compact ? 18 : 22,
            ),
          ),
          label: Text(
            _wasPressed ? 'Watered!' : 'Water Now',
            style: GoogleFonts.inter(
              fontSize: widget.compact ? 13 : 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _wasPressed ? AppTheme.wateredColor : AppTheme.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 16 : 28,
              vertical: widget.compact ? 10 : 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            elevation: _wasPressed ? 0 : 3,
            shadowColor: AppTheme.primary.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
