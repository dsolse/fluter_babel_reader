import 'package:flutter/material.dart';

class CardAddWord extends StatelessWidget {
  const CardAddWord({
    Key? key,
    required this.sentence,
    required this.word,
    required this.changeSelectedWords,
  }) : super(key: key);
  final String word;
  final String sentence;
  final Function changeSelectedWords;

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
                      child: Text(sentence),
                    ),
                  ),
                )),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Center(
                        child: Text.rich(TextSpan(children: [
                          const TextSpan(
                            text: "Translation: ",
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          TextSpan(text: word)
                        ])),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                    width: double.infinity - 50,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {},
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
