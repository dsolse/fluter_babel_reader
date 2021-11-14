import 'package:flutter/material.dart';

class CardChangeText extends StatefulWidget {
  const CardChangeText({Key? key}) : super(key: key);

  @override
  _CardChangeTextState createState() => _CardChangeTextState();
}

class _CardChangeTextState extends State<CardChangeText> {
  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
            height: 60,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              child: const TextField(),
            ),
          ),
        ],
      ),
    );
  }
}
