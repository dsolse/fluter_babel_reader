import 'package:final_babel_reader_app/src/utils/db_helper.dart';
import 'package:flutter/material.dart';

class CardTranslation extends StatelessWidget {
  const CardTranslation({Key? key, required this.word}) : super(key: key);
  final String word;

  Future<Map?> getWord(String wordS) async {
    final db = DBHelper();
    final word = await db.getWord(wordS);
    return word;
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
                Center(
                  child: Text(word,
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.w400)),
                ),
                FutureBuilder<Map?>(
                    future: getWord(word),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const Center(
                            child: Text("Loading"),
                          );
                        default:
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text("There was an error"),
                            );
                          } else {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Center(
                                    child: Text.rich(TextSpan(children: [
                                      const TextSpan(
                                          text: "Translation: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w300)),
                                      TextSpan(
                                          text: snapshot.data?["Translation"] ??
                                              ""),
                                    ])),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(snapshot.data?["Notes"] ?? ""),
                                )
                              ],
                            );
                            // return Text(
                            //     (snapshot.data ?? "No data").toString());
                          }
                      }
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
