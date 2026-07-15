import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// SpringButton adds premium micro-interactions to any widget it wraps.
/// It uses a fluid scale animation and light haptic feedback on press down
/// to provide a satisfying, tactile, and highly responsive user experience.
class SpringButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  
  /// The scale factor when the button is fully pressed down.
  final double pressScale;
  
  /// The duration of the spring animation.
  final Duration animationDuration;

  const SpringButton({
    super.key,
    required this.child,
    this.onTap,
    this.pressScale = 0.95,
    this.animationDuration = const Duration(milliseconds: 100),
  });

  @override
  State<SpringButton> createState() => _SpringButtonState();
}

class _SpringButtonState extends State<SpringButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      reverseDuration: widget.animationDuration,
    );
    
    // Using easeOutCubic to ensure the pop-back feels snappy and fluid
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.pressScale).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      // Trigger a subtle tactile response immediately upon touch
      HapticFeedback.lightImpact();
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            alignment: Alignment.center,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}