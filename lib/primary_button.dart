import 'package:flutter/material.dart';


class PrimaryButton extends StatelessWidget {
  PrimaryButton({required this.key, required this.text, required this.height, required this.onPressed}) : super(key: key);
  Key? key;
  String text;
  double height;
  VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
      constraints: BoxConstraints.expand(height: height),
      child: new ElevatedButton(
          child: new Text(text, style: new TextStyle(color: Colors.white, fontSize: 20.0)),
//          shape: new RoundedRectangleBorder(
  //            borderRadius: BorderRadius.all(Radius.circular(height / 2))),
 //         color: Colors.blue,
  //        textColor: Colors.black87,
          onPressed: onPressed),
    );
  }
}
