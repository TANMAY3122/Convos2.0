import 'package:flutter/material.dart';

class MyComment extends StatelessWidget {
  final String text;
  final String user;
  final String time;
  const MyComment(
      {Key? key, required this.text, required this.user, required this.time})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
      margin: EdgeInsets.only(bottom: 5),
      padding: EdgeInsets.all(15.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(text),
        Row(
          children: [
            Text(user),
            Text("."),
            Text(time),
          ],
        )
      ]),
    );
  }
}
