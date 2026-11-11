import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';

/// Enforces Rule 2 & Rule 4:
/// - Custom interactive cards or buttons scale down subtly (`0.97`) and dim opacity (`0.7`)
///   on `onTapDown`, snapping back smoothly via `SpringSimulation` on `onTapUp` / `onTapCancel`.
/// - Only animates GPU-composited properties (`ScaleTransition`, `FadeTransition`).
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
    this.pressedOpacity = 0.7,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final double pressedOpacity;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  static const SpringDescription _iosSpring = SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 25.0,
  );

  late final AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: 0.0,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _bindTweens();
  }

  void _bindTweens() {
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(_controller);
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedOpacity,
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant PressableScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pressedScale != widget.pressedScale ||
        oldWidget.pressedOpacity != widget.pressedOpacity) {
      _bindTweens();
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    final simulation = SpringSimulation(
      _iosSpring,
      _controller.value,
      1.0,
      0.0,
    );
    _controller.animateWith(simulation);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    _snapBack();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    _snapBack();
  }

  void _snapBack() {
    final simulation = SpringSimulation(
      _iosSpring,
      _controller.value,
      0.0,
      0.0,
    );
    _controller.animateWith(simulation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: RepaintBoundary(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
