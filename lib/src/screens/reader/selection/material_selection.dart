import 'package:final_babel_reader_app/src/screens/reader/selection/toolbar.dart';
import 'package:final_babel_reader_app/src/screens/reader/utils/cardview.dart';
import 'package:final_babel_reader_app/src/utils/data_classes.dart';
import 'package:final_babel_reader_app/src/utils/db_helper.dart';
import 'package:final_babel_reader_app/src/utils/page_route.dart';
import 'package:final_babel_reader_app/src/utils/providers/text_data_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
// import 'package:html/dom.dart';
import 'package:translator/translator.dart';

class MyMaterialTextSelectionControls extends MaterialTextSelectionControls {
  MyMaterialTextSelectionControls(
      {required this.langFrom,
      required this.tileBook,
      required this.langTo,
      required this.changeSelectedWords,
      required this.changeTitle,
      required this.paragraph});

  final Function changeSelectedWords;
  final String tileBook;
  final String paragraph;
  final String langTo;
  final Function changeTitle;
  final String langFrom;
  static const double _kToolbarContentDistanceBelow = 20.0;
  static const double _kToolbarContentDistance = 8.0;

  Future<String> getTranslation(
      TextSelectionDelegate delegate, String lang, String toLang) async {
    String? textResult;
    final String translate = delegate.textEditingValue.text.substring(
        delegate.textEditingValue.selection.start,
        delegate.textEditingValue.selection.end);

    try {
      var translator = GoogleTranslator();

      Translation translationResult =
          await translator.translate(translate, from: lang, to: toLang);
      textResult = translationResult.text;
    } catch (e) {
      var translator = GoogleTranslator(client: ClientType.extensionGT);

      Translation translationResult =
          await translator.translate(translate, from: lang);
      textResult = translationResult.text;
    }
    delegate.hideToolbar();
    return textResult;
  }

  Future<void> translate(
      TextSelectionDelegate delegate, String lang, String toLang) async {
    String? textResult;
    final String translate = delegate.textEditingValue.text.substring(
        delegate.textEditingValue.selection.start,
        delegate.textEditingValue.selection.end);

    try {
      var translator = GoogleTranslator();

      Translation translationResult =
          await translator.translate(translate, from: lang, to: toLang);
      textResult = translationResult.text;
    } catch (e) {
      var translator = GoogleTranslator(client: ClientType.extensionGT);

      Translation translationResult =
          await translator.translate(translate, from: lang);
      textResult = translationResult.text;
    }
    delegate.hideToolbar();

    changeTitle(textResult);
  }

  void addWord(String selected, String translation, String note) async {
    final db = DBHelper();
    if (tileBook.isNotEmpty) {
      changeSelectedWords(selected);
      db.addWord(selected, translation, note, tileBook, langFrom);
    } else {}
  }

  goToMenuAddWord(BuildContext context, TextSelectionDelegate delegate) {
    final String wordSelected = delegate.textEditingValue.text.substring(
        delegate.textEditingValue.selection.start,
        delegate.textEditingValue.selection.end);
    if (!wordSelected.contains(" ")) {
      Navigator.of(context).push(
        HeroPageView(
          builder: (context) {
            return CardAddWord(
              word: wordSelected,
              dataWord: DataWord(
                  langTo,
                  langFrom,
                  tileBook,
                  paragraph
                      .split(".")
                      .where((element) => element.contains(wordSelected))
                      .first,
                  changeListWord: addWord),
            );
          },
        ),
      );
    }
  }

  showTranslationOverlay(BuildContext context, TextSelectionDelegate delegate,
      String lang, String toLang) {
    showDialog(
        context: context,
        barrierColor: Colors.black12,
        builder: (context) => Center(
              child: Padding(
                padding: const EdgeInsets.all(10.00),
                child: Card(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close)),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: FutureBuilder<String>(
                            future: getTranslation(delegate, lang, toLang),
                            builder: (context, snap) {
                              if (snap.connectionState ==
                                  ConnectionState.done) {
                                if (snap.hasError) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(snap.error.toString()),
                                      ),
                                    ],
                                  );
                                  ;
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8.00),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(snap.data ?? "None translation"),
                                      ],
                                    ),
                                  );
                                }
                              } else {
                                return ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.7),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: LinearProgressIndicator(),
                                    ));
                              }
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ClipboardStatusNotifier clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    final TextSelectionPoint startTextSelectionPoint = endpoints[0];
    final TextSelectionPoint endTextSelectionPoint =
        endpoints.length > 1 ? endpoints[1] : endpoints[0];
    final Offset anchorAbove = Offset(
        globalEditableRegion.left + selectionMidpoint.dx,
        globalEditableRegion.top +
            startTextSelectionPoint.point.dy -
            textLineHeight -
            _kToolbarContentDistance);
    final Offset anchorBelow = Offset(
      globalEditableRegion.left + selectionMidpoint.dx,
      globalEditableRegion.top +
          endTextSelectionPoint.point.dy +
          _kToolbarContentDistanceBelow,
    );

    return MyTextSelectionToolbar(
      goFunction: (String parameter) {
        // if (parameter == "Reverso") {
        //   Navigator.push(context, MaterialPageRoute(builder: (context) => ))
        // } else if (parameter == "WikiDict") {}
      },
      addWord: () => goToMenuAddWord(context, delegate),
      translation: () {
        showTranslationOverlay(context, delegate, langFrom, langTo);
        // translate(delegate, langFrom, langTo);
      },
      anchorAbove: anchorAbove,
      anchorBelow: anchorBelow,
      clipboardStatus: clipboardStatus,
      handleCopy: canCopy(delegate)
          ? () => handleCopy(delegate, clipboardStatus)
          : () {},
      handleCut: canCut(delegate) ? () => handleCut(delegate) : () {},
      handlePaste: canPaste(delegate) ? () => handlePaste(delegate) : () {},
      handleSelectAll:
          canSelectAll(delegate) ? () => handleSelectAll(delegate) : () {},
    );
  }
}
