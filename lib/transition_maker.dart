import 'package:flutter/material.dart';

/// Builds a basic animated route transition
class TransitionMaker {
  final destinationPageCall;
  dynamic transitionBuilder;

  /// Use slide animation
  TransitionMaker.slideTransition({
    this.destinationPageCall,
    Offset beginOffset,
    Offset endOffset,
  }) {
    beginOffset ??= Offset(1.0, 0.0);
    endOffset ??= Offset(0.0, 0.0);
    this.transitionBuilder =
        (_, Animation<double> animation, __, Widget child) {
      return SlideTransition(
        position: Tween<Offset>(begin: beginOffset, end: endOffset)
            .animate(animation),
        child: child,
      );
    };
  }

  /// Start animation
  void startNoBack(BuildContext context) {
    Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) {
              return this.destinationPageCall();
            },
            transitionsBuilder: this.transitionBuilder,
            transitionDuration: Duration(milliseconds:500)
          ),
        );
  }
}
