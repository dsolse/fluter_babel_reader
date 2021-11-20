import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/main_menu/main_menu.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const Color primaryColor = Color(0xff64655d);
  static const Color backgroundColor = Color(0xfff1f4e3);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.brown,
            ),
            textSelectionTheme: const TextSelectionThemeData(
              selectionColor: backgroundColor,
              cursorColor: primaryColor,
            ),
            primaryColor: primaryColor,
            backgroundColor: backgroundColor),
        darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(
                brightness: Brightness.dark,
                primarySwatch: Colors.brown,
                cardColor: Colors.brown,
                accentColor: Colors.brown),
            textSelectionTheme: const TextSelectionThemeData(
              selectionColor: primaryColor,
              cursorColor: primaryColor,
            ),
            primaryColor: primaryColor,
            backgroundColor: backgroundColor),
        home: const MainMenu());
  }
}
