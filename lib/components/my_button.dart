import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String txt;

  const MyButton({Key? key, required this.onTap, required this.txt})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25.0),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Text(
            txt,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
