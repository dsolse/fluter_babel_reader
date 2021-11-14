import 'package:final_babel_reader_app/src/screens/reader/utils/card_change_text.dart';
import 'package:final_babel_reader_app/src/utils/db_helper.dart';
import 'package:final_babel_reader_app/src/utils/page_route.dart';
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5.00),
                                  child: Center(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            HeroPageView(
                                                builder: (context) =>
                                                    const CardChangeText()));
                                      },
                                      child: Text.rich(TextSpan(children: [
                                        const TextSpan(
                                            text: "Translation: ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300)),
                                        TextSpan(
                                            text:
                                                snapshot.data?["Translation"] ??
                                                    ""),
                                      ])),
                                    ),
                                  ),
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
    );
  }
}

//  return LimitedBox(
//       child: Column(
//         mainAxisSize: MainAxisSize.max,
//         children: [
//           SizedBox(
//             height: 60,
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Material(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5)),
//               child: Column(
//                 children: [
//                   Center(
//                     child: Text(word,
//                         style: const TextStyle(
//                             fontSize: 30, fontWeight: FontWeight.w400)),
//                   ),
//                   FutureBuilder<Map?>(
//                       future: getWord(word),
//                       builder: (context, snapshot) {
//                         switch (snapshot.connectionState) {
//                           case ConnectionState.waiting:
//                             return const Center(
//                               child: Text("Loading"),
//                             );
//                           default:
//                             if (snapshot.hasError) {
//                               return const Center(
//                                 child: Text("There was an error"),
//                               );
//                             } else {
//                               return Column(
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.all(5.0),
//                                     child: Center(
//                                       child: Text.rich(TextSpan(children: [
//                                         const TextSpan(
//                                             text: "Translation: ",
//                                             style: TextStyle(
//                                                 fontWeight: FontWeight.w300)),
//                                         TextSpan(
//                                             text:
//                                                 snapshot.data?["Translation"] ??
//                                                     ""),
//                                       ])),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text(snapshot.data?["Notes"] ?? ""),
//                                   )
//                                 ],
//                               );
//                               // return Text(
//                               //     (snapshot.data ?? "No data").toString());
//                             }
//                         }
//                       })
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
