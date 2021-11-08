import 'package:flutter/material.dart';

import 'drop_down_translation.dart';
import 'font_settings.dart';

class FontColorMenu extends StatelessWidget {
  const FontColorMenu(
      {Key? key,
      required this.callbackColor,
      required this.callbackFont,
      required this.originalLanguage,
      required this.translationLanguage,
      required this.changeOriginalLanguage,
      required this.changeTranslationLanguage,
      required this.value})
      : super(key: key);

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
                          callback: changeColor, color: Colors.black45),
                      ColorChanger(
                          callback: changeColor, color: Colors.black87),
                      ColorChanger(
                          callback: changeColor, color: Colors.black45),
                      ColorChanger(
                          callback: changeColor, color: Colors.black87),
                    ],
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
