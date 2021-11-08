import 'package:final_babel_reader_app/src/screens/reader/selection/toolbar.dart';
import 'package:final_babel_reader_app/src/screens/reader/utils/cardview.dart';
import 'package:final_babel_reader_app/src/utils/page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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

  goToMenuAddWord(BuildContext context, TextSelectionDelegate delegate) {
    final String wordSelected = delegate.textEditingValue.text.substring(
        delegate.textEditingValue.selection.start,
        delegate.textEditingValue.selection.end);

    Navigator.of(context).push(
      HeroPageView(
        builder: (context) {
          return CardAddWord(
            word: wordSelected,
            sentence: paragraph
                .split(".")
                .where((element) => element.contains(wordSelected))
                .first,
            changeSelectedWords: changeSelectedWords,
          );
        },
      ),
    );
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
      addWord: () => goToMenuAddWord(context, delegate),
      translation: () => translate(delegate, langFrom, langTo),
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