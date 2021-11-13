import 'package:final_babel_reader_app/src/utils/data_classes.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class CardAddWord extends StatelessWidget {
  CardAddWord({
    Key? key,
    required this.dataWord,
    required this.word,
  }) : super(key: key);
  final String word;
  final DataWord dataWord;
  late String translation;

  Future<String> translate(String translate, String lang, String toLang) async {
    late String textResult;
    print(toLang);
    print(lang);

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
                    child: Text.rich(TextSpan(children: [
                      const TextSpan(
                        text: "Word: ",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      TextSpan(text: word)
                    ])),
                  ),
                ),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Center(
                      child: Text(dataWord.paragraph.replaceAll("\n", " ")),
                    ),
                  ),
                )),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Center(
                        child: FutureBuilder<String>(
                            future: translate(
                                word, dataWord.fromLang, dataWord.toLang),
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
                          if (dataWord.changeListWord != null) {
                            if (translation != "Check your conecction") {
                              dataWord.changeListWord!(
                                  word, translation, dataWord.paragraph);
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
