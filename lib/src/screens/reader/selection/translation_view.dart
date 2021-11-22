import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class DefinitionView extends StatelessWidget {
  const DefinitionView(
      {Key? key,
      required this.delegate,
      required this.lang,
      required this.toLang})
      : super(key: key);
  final TextSelectionDelegate delegate;
  final String lang;
  final String toLang;

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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close)),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: FutureBuilder<String>(
              future: getTranslation(delegate, lang, toLang),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.done) {
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
                    
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.00),
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
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: LinearProgressIndicator(),
                      ));
                }
              }),
        ),
      ],
    );
  }
}
