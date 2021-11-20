import 'package:final_babel_reader_app/src/screens/reader/components/drawer/font_color_menu/drop_down_font.dart';
import 'package:flutter/material.dart';

import 'drop_down_translation.dart';
import 'font_settings.dart';

class FontMenu extends StatefulWidget {
  const FontMenu(
      {Key? key,
      required this.callbackColor,
      required this.currentColor,
      required this.currentFontFamily,
      required this.callbackFontFamily,
      required this.callbackFont,
      required this.originalLanguage,
      required this.translationLanguage,
      required this.changeOriginalLanguage,
      required this.changeTranslationLanguage,
      required this.value})
      : super(key: key);

  final String currentFontFamily;
  final Color currentColor;
  final Function callbackFontFamily;
  final Function callbackColor;
  final String originalLanguage;
  final Function changeTranslationLanguage;
  final Function changeOriginalLanguage;
  final String translationLanguage;
  final double value;
  final Function callbackFont;

  @override
  State<FontMenu> createState() => _FontMenuState();
}

class _FontMenuState extends State<FontMenu> {
  late Color _color;
  late String _fontFamily;
  late double _fontSize;
  @override
  void initState() {
    super.initState();
    _color = widget.currentColor;
    _fontFamily = widget.currentFontFamily;
    _fontSize = widget.value;
  }

  @override
  void dispose() {
    super.dispose();
  }

  changeColor(Color color) {
    setState(() {
      _color = color;
    });
  }

  changeFontFamily(String family) {
    setState(() {
      _fontFamily = family;
    });
  }

  changeFontSize(double valueSize) {
    setState(() {
      _fontSize = valueSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Lorem ipsum sit amet,\nconsectetur adipiscing elit",
                    style: TextStyle(
                        color: _color,
                        fontSize: _fontSize,
                        fontFamily: _fontFamily),
                  ),
                  Wrap(
                    spacing: 15.00,
                    runSpacing: 15.00,
                    children: [
                      ColorChanger(callback: changeColor, color: Colors.white),
                      ColorChanger(
                          callback: changeColor, color: Colors.white12),
                      ColorChanger(
                          callback: changeColor, color: Colors.white24),
                      ColorChanger(
                          callback: changeColor, color: Colors.white38),
                      ColorChanger(
                          callback: changeColor, color: Colors.white54),
                      ColorChanger(
                          callback: changeColor, color: Colors.black12),
                      ColorChanger(
                          callback: changeColor, color: Colors.black26),
                      ColorChanger(
                          callback: changeColor, color: Colors.black38),
                      ColorChanger(
                          callback: changeColor, color: Colors.black45),
                      ColorChanger(
                          callback: changeColor, color: Colors.black54),
                      ColorChanger(
                          callback: changeColor, color: Colors.black87),
                      ColorChanger(callback: changeColor, color: Colors.black),
                    ],
                  ),
                  LimitedBox(
                    child: ChangeFont(
                      changeFontFamily: changeFontFamily,
                      fontFamily: widget.currentFontFamily,
                    ),
                  ),
                  LimitedBox(
                    child: FontSizeSlider(
                      callback: changeFontSize,
                      value: widget.value,
                    ),
                  ),
                  SizedBox(
                    child: SelectTranslation(
                        originalLanguage: widget.originalLanguage,
                        translationLanguage: widget.translationLanguage,
                        changeOriginalLanguage: widget.changeOriginalLanguage,
                        changeTranslationLanguage:
                            widget.changeTranslationLanguage),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        widget.callbackColor(_color);
                        widget.callbackFont(_fontSize);
                        widget.callbackFontFamily(_fontFamily);
                        Navigator.pop(context);
                      },
                      child: const Text("Save settings"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
