import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime endTime;
  final VoidCallback? onTimerEnd;

  const CountdownTimer({
    super.key,
    required this.endTime,
    this.onTimerEnd,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  Duration _remainingTime = Duration.zero;
  bool _isBlinking = false;
  bool _hasEnded = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void didUpdateWidget(covariant CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // endTime değiştiğinde (ekstra süre eklendiğinde) durumu sıfırla
    if (oldWidget.endTime != widget.endTime) {
      _hasEnded = false;
      _isBlinking = false;
      _animationController.stop();
      _animationController.value = 1.0;
      _updateTime();
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    final difference = widget.endTime.difference(now);

    if (difference.inSeconds <= 0 && !_hasEnded) {
      _hasEnded = true;
      _isBlinking = false;
      _animationController.stop();
      if (widget.onTimerEnd != null) {
        widget.onTimerEnd!();
      }
    } else if (difference.inSeconds <= 60 && difference.inSeconds > 0) {
      if (!_isBlinking) {
        _isBlinking = true;
        _animationController.repeat(reverse: true);
      }
    } else if (difference.inSeconds > 60) {
      if (_isBlinking) {
        _isBlinking = false;
        _animationController.stop();
        _animationController.value = 1.0;
      }
    }

    if (mounted) {
      setState(() {
        _remainingTime = difference;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remainingTime.inSeconds <= 0) {
      return const Text(
        'SÜRE DOLDU!',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.redAccent,
        ),
        textAlign: TextAlign.center,
      );
    }

    final minutes = _remainingTime.inMinutes.toString().padLeft(2, '0');
    final seconds = (_remainingTime.inSeconds % 60).toString().padLeft(2, '0');
    final isCritical = _remainingTime.inSeconds <= 60;

    Widget timeText = Text(
      '$minutes:$seconds',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: isCritical ? Colors.redAccent : Colors.black87,
      ),
      textAlign: TextAlign.center,
    );

    if (isCritical) {
      return FadeTransition(
        opacity: _opacityAnimation,
        child: timeText,
      );
    }

    return timeText;
  }
}
