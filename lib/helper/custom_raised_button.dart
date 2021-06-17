import 'package:flutter/material.dart';

class CustomRaisedButton extends StatelessWidget {
  CustomRaisedButton({
    this.child,
    this.color,
    this.borderRadius: 40.0,
    this.height: 50.0,
    this.onPressed,
  }) : assert(borderRadius != null);

  final Widget child;
  final Color color;
  final double borderRadius;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        child: Padding(
          padding:  EdgeInsets.only(bottom: 2.0),
          child: child,
        ),
        //color: color,
        style: ElevatedButton.styleFrom(
          primary: color,
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0),
            )
          ),
        onPressed: onPressed,
        ),
    );
  }
}
