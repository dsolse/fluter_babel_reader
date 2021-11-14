import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TextData with ChangeNotifier {
  late double _fontSize;
  late List<String> _selectedWords;
  late Color _textColorLM;
  late Color _textColorDM;
  late String _fontFamily;

  TextData() {
    _selectedWords = [];
    _fontSize = 15.00;
    _textColorLM = Colors.black;
    _textColorDM = Colors.white;
    _fontFamily = "Spectral";
    _initFonts();
  }

  void _initFonts() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final lightFont = pref.getInt("fontColorLight");
    final darkFont = pref.getInt("fontColorDark");
    final size = pref.getDouble("fontSize");
    final family = pref.getString("fontFamily");
    updateFontSize(size ?? 15.00);
    updateFontFamily((family != null) ? family : "Spectral");
    updateTextColorDM((lightFont != null) ? Color(lightFont) : Colors.black);
    updateTextColorDM((darkFont != null) ? Color(darkFont) : Colors.white);
    notifyListeners();
  }

  List<String> get selectedWords => _selectedWords;
  Color get textColorLM => _textColorLM;
  Color get textColorDM => _textColorDM;
  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;

  updateFontFamily(String fontFamily) {
    _fontFamily = fontFamily;
    notifyListeners();
  }

  updateTextColorLM(Color color) {
    _textColorLM = color;
    notifyListeners();
  }

  updateFontSize(double fontSize) {
    _fontSize = fontSize;
    notifyListeners();
  }

  updateTextColorDM(Color color) {
    _textColorDM = color;
    notifyListeners();
  }

  // Just add a word, not the array
  void updateSelectedWords(String word) {
    final _words = selectedWords;
    _words.add(word);
    _selectedWords = _words;
    notifyListeners();
  }

  _saveFontsSize() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setDouble("fontSize", fontSize);
  }

  _saveFontsColor(int color, String mode) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt(mode, color);
    pref.setDouble("fontSize", fontSize);
  }

  _saveFontFamily() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("fontFamily", fontFamily);
  }

  @override
  void dispose() {
    _saveFontsColor(textColorLM.value, "fontColorLight");
    _saveFontsColor(textColorDM.value, "fontColorDark");
    _saveFontsSize();
    _saveFontFamily();

    super.dispose();
  }
}
