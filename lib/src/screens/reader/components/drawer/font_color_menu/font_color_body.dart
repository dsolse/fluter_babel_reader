import 'package:final_babel_reader_app/src/screens/reader/components/drawer/font_color_menu/drop_down_font.dart';
import 'package:flutter/material.dart';

import 'drop_down_translation.dart';
import 'font_settings.dart';

class FontMenu extends StatelessWidget {
  const FontMenu(
      {Key? key,
      required this.callbackColor,
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
  final Function callbackFontFamily;
  final Function callbackColor;
  final String originalLanguage;
  final Function changeTranslationLanguage;
  final Function changeOriginalLanguage;
  final String translationLanguage;
  final double value;
  final Function callbackFont;

  changeColor(Color color) => callbackColor(color);
  changeFontSize(double valueSize) => callbackFont(valueSize);

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
                      changeFontFamily: callbackFontFamily,
                      fontFamily: currentFontFamily,
                    ),
                  ),
                  LimitedBox(
                    child: FontSizeSlider(
                      callback: changeFontSize,
                      value: value,
                    ),
                  ),
                  SizedBox(
                    child: SelectTranslation(
                        originalLanguage: originalLanguage,
                        translationLanguage: translationLanguage,
                        changeOriginalLanguage: changeOriginalLanguage,
                        changeTranslationLanguage: changeTranslationLanguage),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
