import 'dart:typed_data';

import 'package:epubx/epubx.dart' as epub;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as cover;

class PrevieBook extends StatelessWidget {
  const PrevieBook({
    Key? key,
    required this.coverImage,
    required this.changeTitle,
    required this.changeAuthor,
    required this.changeLanguage,
    required this.ebook,
  }) : super(key: key);
  final Function changeTitle;
  final Function changeAuthor;
  final Function changeLanguage;
  final Future<cover.Image?> coverImage;
  final epub.EpubBookRef ebook;

  @override
  Widget build(BuildContext context) {
    changeAuthor(ebook.Author ?? "");
    changeTitle(ebook.Title ?? "");
    return Padding(
      padding: const EdgeInsets.all(9.00),
      child: SingleChildScrollView(
        child: AspectRatio(
          aspectRatio: 1 / 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureBuilder<cover.Image?>(
                      future: coverImage,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if ((snapshot.hasError)) {
                            return Text(snapshot.error.toString());
                          } else {
                            return (snapshot.data != null)
                                ? Image.memory(Uint8List.fromList(
                                    cover.encodePng(snapshot.data!)))
                                : Image.asset('assets/nonImageCover.png');
                          }
                        } else {
                          return const CircularProgressIndicator();
                        }
                      }),
                ),
              ),
              const Expanded(flex: 1, child: Text("Title: ")),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFieldOfBook(
                    text: ebook.Title ?? "",
                    changeText: changeTitle,
                  ),
                ),
              ),
              const Expanded(flex: 1, child: Text("Author: ")),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFieldOfBook(
                    text: ebook.Author ?? "",
                    changeText: changeAuthor,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SelectTranslation(
                    changeLanguage: changeLanguage,
                    originalLanguage: (ebook.Schema?.Package?.Metadata
                                ?.Languages?.isNotEmpty ??
                            false)
                        ? ebook.Schema?.Package?.Metadata?.Languages?.first ??
                            "none"
                        : "none"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TextFieldOfBook extends StatefulWidget {
  const TextFieldOfBook(
      {Key? key, required this.changeText, required this.text})
      : super(key: key);
  final String text;
  final Function changeText;
  @override
  _TextFieldOfBookState createState() => _TextFieldOfBookState();
}

class _TextFieldOfBookState extends State<TextFieldOfBook> {
  late TextEditingController _controller;
  @override
  void initState() {
    _controller =
        TextEditingController.fromValue(TextEditingValue(text: widget.text));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (value) => widget.changeText(value),
    );
  }
}

class SelectTranslation extends StatefulWidget {
  const SelectTranslation({
    Key? key,
    required this.changeLanguage,
    required this.originalLanguage,
  }) : super(key: key);

  final Function changeLanguage;
  final String originalLanguage;

  @override
  _SelectTranslationState createState() => _SelectTranslationState();
}

class _SelectTranslationState extends State<SelectTranslation> {
  late String valueSource;
  List<String> items = ["en", "es", "de", "fr", "ru", "it", "None"];
  @override
  void initState() {
    valueSource = (items.contains(widget.originalLanguage))
        ? widget.originalLanguage
        : "None";
    widget.changeLanguage(valueSource);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: valueSource,
      onChanged: (nVal) {
        if (nVal != null) {
          setState(() {
            valueSource = nVal;
          });
          widget.changeLanguage(nVal);
        }
      },
      items: items.map<DropdownMenuItem<String>>((lang) {
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
        } else if (lang == "ru") {
          return DropdownMenuItem<String>(
            value: lang,
            child: const Text("Russian"),
          );
        } else {
          return DropdownMenuItem<String>(
            value: lang,
            child: const Text("None, select one"),
          );
        }
      }).toList(),
    );
  }
}
