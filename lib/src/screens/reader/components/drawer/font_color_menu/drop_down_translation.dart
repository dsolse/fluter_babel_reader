import 'package:flutter/material.dart';

class SelectTranslation extends StatefulWidget {
  const SelectTranslation({
    Key? key,
    required this.originalLanguage,
    required this.translationLanguage,
    required this.changeOriginalLanguage,
    required this.changeTranslationLanguage,
  }) : super(key: key);

  final String originalLanguage;
  final Function changeTranslationLanguage;
  final Function changeOriginalLanguage;
  final String translationLanguage;

  @override
  _SelectTranslationState createState() => _SelectTranslationState();
}

class _SelectTranslationState extends State<SelectTranslation> {
  late String valueTranslation;
  late String valueSource;
  @override
  void initState() {
    valueTranslation = (widget.translationLanguage == "None")
        ? "en"
        : widget.translationLanguage;
    valueSource =
        (widget.originalLanguage == "None") ? "en" : widget.originalLanguage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        DropdownButton<String>(
          value: valueSource,
          onChanged: (nVal) {
            if (nVal != null) {
              setState(() {
                valueSource = nVal;
              });
              widget.changeOriginalLanguage(nVal);
            }
          },
          items: <String>["en", "es", "de", "fr", "ru", "it"]
              .map<DropdownMenuItem<String>>((lang) {
            if (lang == "en") {
              return DropdownMenuItem<String>(
                value: lang,
                child: const Text("English"),
              );
            } else if (lang == "es") {
              return DropdownMenuItem<String>(
                value: lang,
                child: const Text("Spanish"),
              );
            } else if (lang == "de") {
              return DropdownMenuItem<String>(
                value: lang,
                child: const Text("Deutsch"),
              );
            } else if (lang == "fr") {
              return DropdownMenuItem<String>(
                value: lang,
                child: const Text("French"),
              );
            } else if (lang == "it") {
              return DropdownMenuItem<String>(
                value: lang,
                child: const Text("Italian"),
              );
            } else {
              return DropdownMenuItem<String>(
                value: lang,
                child: const Text("Russian"),
              );
            }
          }).toList(),
        ),
        const Icon(Icons.arrow_forward),
        DropdownButton<String>(
          value: valueTranslation,
          onChanged: (nVal) {
            if (nVal != null) {
              setState(() {
                valueTranslation = nVal;
              });
              widget.changeTranslationLanguage(nVal);
            }
          },
          items: <String>["es", "en", "de", "fr", "ru", "it"]
              .map<DropdownMenuItem<String>>((lang) {
            if (lang == "en") {
              return DropdownMenuItem<String>(
                value: lang,
                child: const Text("English"),
              );
            } else if (lang == "de") {
              return DropdownMenuItem<String>(
                value: lang,
                child: const Text("Deutsch"),
              );
            } else if (lang == "es") {
              return DropdownMenuItem<String>(
                value: lang,
                child: const Text("Spanish"),
              );
            } else if (lang == "fr") {
              return DropdownMenuItem<String>(
                value: lang,
                child: const Text("French"),
              );
            } else if (lang == "it") {
              return DropdownMenuItem<String>(
                value: lang,
                child: const Text("Italian"),
              );
            } else {
              return DropdownMenuItem<String>(
                value: lang,
                child: const Text("Russian"),
              );
            }
          }).toList(),
        ),
      ],
    );
  }
}
