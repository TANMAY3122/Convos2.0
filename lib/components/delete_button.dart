import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  final void Function()? onTap;
  const DeleteButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Icon(
          Icons.cancel,
          color: Colors.grey,
        ));
  }
}
