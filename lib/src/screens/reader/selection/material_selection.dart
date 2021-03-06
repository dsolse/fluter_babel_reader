import 'package:final_babel_reader_app/src/screens/reader/selection/toolbar.dart';
import 'package:final_babel_reader_app/src/screens/reader/selection/translation_view.dart';
import 'package:final_babel_reader_app/src/screens/reader/utils/cardview.dart';
import 'package:final_babel_reader_app/src/utils/data_classes.dart';
import 'package:final_babel_reader_app/src/utils/db_helper.dart';
import 'package:final_babel_reader_app/src/utils/page_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:translator/translator.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(8.00),
            content: DefinitionView(
              delegate: delegate,
              lang: lang,
              toLang: toLang,
            ),
          );
        });
  }

  String getLanguageToReverso(String language) {
    switch (language) {
      case "ru":
        return 'rus';
      case "en":
        return 'eng';
      case "de":
        return 'ger';
      case "es":
        return 'spa';
      case "fr":
        return 'fra';
      default:
        return 'ita';
    }
  }

  void showViewSearchnWord(BuildContext context, String link) {
    late WebViewController _controller;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            elevation: 5.0,
            contentPadding: const EdgeInsets.all(0.00),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: Theme.of(context).colorScheme.primary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () => _controller.goBack(),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              )),
                          IconButton(
                              onPressed: () => _controller.goForward(),
                              icon: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              )),
                        ],
                      ),
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          )),
                    ],
                  ),
                ),
                AspectRatio(
                  aspectRatio: 2 / 3,
                  child: WebView(
                    initialUrl: link,
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (controller) {
                      _controller = controller;
                    },
                  ),
                )
              ],
            ),
          );
        });
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
      goFunctionReverso: () {
        final String word = delegate.textEditingValue.text.substring(
            delegate.textEditingValue.selection.start,
            delegate.textEditingValue.selection.end);

        String link =
            "https://www.reverso.net/text-translation#sl=${getLanguageToReverso(langFrom)}&tl=${getLanguageToReverso(langTo)}&text=${word.replaceAll(" ", "%20")}";

        showViewSearchnWord(context, link);
      },
      goFunctionWiki: () {
        final String word = delegate.textEditingValue.text.substring(
            delegate.textEditingValue.selection.start,
            delegate.textEditingValue.selection.end);
        if (!word.contains(" ")) {
          showViewSearchnWord(context, "https://en.wiktionary.org/wiki/$word");
        }
      },
      addWord: () => goToMenuAddWord(context, delegate),
      translation: () {
        showTranslationOverlay(context, delegate, langFrom, langTo);
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
