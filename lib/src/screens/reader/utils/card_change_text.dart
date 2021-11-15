import 'package:flutter/material.dart';

class CardChangeText extends StatelessWidget {
  const CardChangeText({Key? key, required this.text, required this.changeText})
      : super(key: key);
  final String text;
  final Function changeText;

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
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFieldEditor(
                  text: text,
                  changeText: changeText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TextFieldEditor extends StatefulWidget {
  const TextFieldEditor(
      {Key? key, required this.text, required this.changeText})
      : super(key: key);
  final String text;
  final Function changeText;

  @override
  _TextFieldEditorState createState() => _TextFieldEditorState();
}

class _TextFieldEditorState extends State<TextFieldEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller =
        TextEditingController.fromValue(TextEditingValue(text: widget.text));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: SizedBox(
            child: TextField(
              maxLines: null,
              controller: _controller,
            ),
          ),
        ),
        const Expanded(
          flex: 1,
          child: SizedBox(),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: ElevatedButton(
                onPressed: () {
                  widget.changeText(_controller.text);
                  Navigator.pop(context);
                },
                child: const Icon(Icons.check)),
          ),
        )
      ],
    );
  }
}
