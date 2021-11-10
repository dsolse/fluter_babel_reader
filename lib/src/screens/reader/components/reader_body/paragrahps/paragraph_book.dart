import 'package:final_babel_reader_app/src/screens/reader/selection/material_selection.dart';
import 'package:final_babel_reader_app/src/utils/providers/book_data_provider.dart';
import 'package:final_babel_reader_app/src/utils/providers/text_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HtmlPragragh extends StatefulWidget {
  const HtmlPragragh({
    Key? key,
    required this.paragragh,
  }) : super(key: key);
  final String paragragh;

  @override
  State<HtmlPragragh> createState() => _HtmlPragraghState();
}

class _HtmlPragraghState extends State<HtmlPragragh> {
  List<TextSpan> splitSentence = [];
  @override
  void initState() {
    final dataT = Provider.of<TextData>(context, listen: false);

    List<String> wordsToMach = dataT.selectedWords;
    wordsToMach.add("das");

    var match = RegExp(wordsToMach.join(r'\b|\b'));

    if (widget.paragragh.contains(match) && wordsToMach.isNotEmpty) {
      int offset = 0;
      Iterable matches = match.allMatches(widget.paragragh);
      int item = 0;
      for (final result in matches) {
        // ? Before sentence matching
        if (result.start > offset && result.start < widget.paragragh.length) {
          splitSentence.add(TextSpan(
            text: widget.paragragh.substring(offset, result.start),
          ));
        } else {
          splitSentence.add(TextSpan(
            text: widget.paragragh.substring(offset, result.start),
          ));
        }
        // ? Sentence matching
        splitSentence.add(
          TextSpan(
            text: widget.paragragh.substring(result.start, result.end),
            style: const TextStyle(color: Colors.brown),
            // recognizer: tabSentence(
            //     paragragh,
            //     paragragh.substring(result.start, result.end),
            //     result.start,
            //     result.end),
          ),
        );
        // ? After all words of sentence matching
        offset = result.end;
        if (item == matches.length - 1) {
          splitSentence.add(TextSpan(
            text: widget.paragragh.substring(result.end),
          ));
        }
        item++;
      }
    } else {
      // ? Sentence without match
      splitSentence.add(
        TextSpan(
          text: widget.paragragh,
        ),
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String lastWord = "";
    int beginW = 0;
    int endW = 0;
    final data = Provider.of<BookData>(context, listen: false);
    final dataT = Provider.of<TextData>(context);

    changeListWords(String newWord) {
      dataT.updateSelectedWords(newWord);
    }

    // tabSentence(String sentence, word, int begin, int end) =>
    //     TapGestureRecognizer()
    //       ..onTap = () {
    //         beginW = begin;
    //         lastWord = word;
    //         endW = end;
    //         Navigator.push(
    //           context,
    //           HeroPageView<CardTranslation>(
    //             builder: (context) => CardTranslation(word: word),
    //           ),
    //         );
    //       };

    bool? isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0, top: 0.0),
      child: SelectableText.rich(
        TextSpan(
          style: TextStyle(
            color: isDark ? dataT.textColorDM : dataT.textColorLM,
            fontSize: dataT.fontSize,
          ),
          children: splitSentence,
        ),
        selectionControls: MyMaterialTextSelectionControls(
          changeTitle: (String word) => data.updateTitle(word),
          changeSelectedWords: (String word) => dataT.updateSelectedWords(word),
          langFrom: data.language,
          langTo: data.toTranslate,
          tileBook: data.titleBook,
          paragraph: widget.paragragh,
        ),
      ),
    );
  }
}
