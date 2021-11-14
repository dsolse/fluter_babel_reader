import 'package:flutter/material.dart';

class ChangeFont extends StatefulWidget {
  const ChangeFont(
      {Key? key, required this.fontFamily, required this.changeFontFamily})
      : super(key: key);
  final String fontFamily;
  final Function changeFontFamily;

  @override
  _ChangeFontState createState() => _ChangeFontState();
}

class _ChangeFontState extends State<ChangeFont> {
  late String fontFamily;
  @override
  void initState() {
    fontFamily = widget.fontFamily;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: DropdownButton<String>(
        value: fontFamily,
        onChanged: (font) {
          if (font != null) {
            setState(() {
              fontFamily = font;
            });
            widget.changeFontFamily(font);
          }
        },
        items: <String>["Book-Book", "Bookerly", "PatrickHand", "Spectral"]
            .map<DropdownMenuItem<String>>((font) {
          return DropdownMenuItem<String>(
            value: font,
            child: Text(font),
          );
        }).toList(),
      ),
    );
  }
}
