import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 3D Card widget with tilt and depth effect
class Card3D extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool enableTilt;
  
  const Card3D({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.borderRadius,
    this.onTap,
    this.enableTilt = true,
  });

  @override
  State<Card3D> createState() => _Card3DState();
}

class _Card3DState extends State<Card3D> with SingleTickerProviderStateMixin {
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  bool _isHovering = false;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateRotation(Offset localPosition) {
    if (!widget.enableTilt) return;
    
    final double centerX = widget.width / 2;
    final double centerY = widget.height / 2;
    
    final double deltaX = localPosition.dx - centerX;
    final double deltaY = localPosition.dy - centerY;
    
    setState(() {
      _rotationY = (deltaX / centerX) * 0.2;
      _rotationX = -(deltaY / centerY) * 0.2;
    });
  }

  void _resetRotation() {
    if (!widget.enableTilt) return;
    
    setState(() {
      _rotationX = 0.0;
      _rotationY = 0.0;
      _isHovering = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: (details) {
        _updateRotation(details.localPosition);
      },
      onPanEnd: (_) => _resetRotation(),
      onTapDown: (details) {
        setState(() => _isHovering = true);
        _animationController.forward();
        _updateRotation(details.localPosition);
      },
      onTapUp: (_) => _resetRotation(),
      onTapCancel: () => _resetRotation(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(_rotationX)
                ..rotateY(_rotationY),
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: _isHovering ? 0.4 : 0.2),
                      blurRadius: _isHovering ? 30 : 20,
                      offset: Offset(0, _isHovering ? 15 : 10),
                      spreadRadius: _isHovering ? 5 : 0,
                    ),
                  ],
                ),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Animated gradient background
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  
  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF8B5CF6),
                  const Color(0xFF3B82F6),
                  math.sin(_controller.value * 2 * math.pi) * 0.5 + 0.5,
                )!,
                const Color(0xFF6366F1),
                Color.lerp(
                  const Color(0xFF3B82F6),
                  const Color(0xFFEC4899),
                  math.cos(_controller.value * 2 * math.pi) * 0.5 + 0.5,
                )!,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
