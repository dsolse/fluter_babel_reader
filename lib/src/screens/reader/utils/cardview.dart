import 'package:final_babel_reader_app/src/utils/data_classes.dart';
import 'package:final_babel_reader_app/src/utils/page_route.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

import 'card_change_text.dart';

class CardAddWord extends StatefulWidget {
  const CardAddWord({
    Key? key,
    required this.dataWord,
    required this.word,
  }) : super(key: key);
  final String word;
  final DataWord dataWord;

  @override
  State<CardAddWord> createState() => _CardAddWordState();
}

class _CardAddWordState extends State<CardAddWord> {
  late String translation;
  late String word;
  @override
  void initState() {
    word = widget.word;
    super.initState();
  }

  Future<String> translate(String translate, String lang, String toLang) async {
    late String textResult;
    try {
      var translator = GoogleTranslator();

      Translation translationResult =
          await translator.translate(translate, from: lang, to: toLang);
      textResult = translationResult.text;
    } catch (e) {
      try {
        var translator = GoogleTranslator(client: ClientType.extensionGT);

        Translation translationResult =
            await translator.translate(translate, from: lang);
        textResult = translationResult.text;
      } catch (e) {
        textResult = "Check your conecction";
      }
    }
    translation = textResult;

    return textResult;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: ClipRect(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            HeroPageView(
                              builder: (context) => CardChangeText(
                                changeText: (String text) {
                                  setState(() {
                                    word = text;
                                  });
                                },
                                text: widget.word,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text.rich(TextSpan(children: [
                            const TextSpan(
                              text: "Word: ",
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                            TextSpan(text: word)
                          ])),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Center(
                      child:
                          Text(widget.dataWord.paragraph.replaceAll("\n", " ")),
                    ),
                  ),
                )),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Center(
                        child: FutureBuilder<String>(
                            future: translate(word, widget.dataWord.fromLang,
                                widget.dataWord.toLang),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return const LinearProgressIndicator();
                                default:
                                  if (snapshot.hasError) {
                                    return const Text.rich(TextSpan(children: [
                                      TextSpan(
                                        text: "Translation: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900),
                                      ),
                                      TextSpan(text: "There was a problem")
                                    ]));
                                  } else {
                                    return Text.rich(TextSpan(children: [
                                      const TextSpan(
                                        text: "Translation: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900),
                                      ),
                                      TextSpan(text: snapshot.data)
                                    ]));
                                  }
                              }
                            }),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                    width: double.infinity - 50,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.dataWord.changeListWord != null) {
                            if (translation != "Check your conecction") {
                              widget.dataWord.changeListWord!(widget.word,
                                  translation, widget.dataWord.paragraph);
                            }
                          }
                        },
                        child: const Text("Save word"),
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
