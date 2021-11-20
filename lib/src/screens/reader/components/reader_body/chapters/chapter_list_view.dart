import 'dart:typed_data';
import 'package:epubx/epubx.dart';
import 'package:final_babel_reader_app/src/screens/reader/selection/material_selection.dart';
import 'package:final_babel_reader_app/src/screens/reader/utils/card_definition_view.dart';
import 'package:final_babel_reader_app/src/utils/ebook_controller.dart';
import 'package:final_babel_reader_app/src/utils/page_route.dart';
import 'package:final_babel_reader_app/src/utils/providers/book_data_provider.dart';
import 'package:final_babel_reader_app/src/utils/providers/text_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter/src/widgets/image.dart' as image_import;
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ReaderChapter extends StatefulWidget {
  const ReaderChapter({
    Key? key,
    required this.controller,
    required this.index,
    required this.doc,
    required this.isLastChapter,
  }) : super(key: key);

  final String doc;
  final int index;
  final EbookController controller;
  final bool isLastChapter;

  @override
  State<ReaderChapter> createState() => _ReaderChapterState();
}

class _ReaderChapterState extends State<ReaderChapter> {
  Map<String, Style> styleCss = {};

  List<dom.Element> paragraghs = [];

  List<dom.Element> getElements(List<dom.Element> elements) {
    List<dom.Element> paragraghsB = [];

    for (final nodes in elements) {
      late dom.Element node;
      if (nodes.localName == "a") {
        node = dom.Element.html("<div>${nodes.innerHtml}</div>");
      } else {
        node = nodes;
      }
      final paragraghsIn = node.getElementsByTagName("p");
      final paraAchie =
          paragraghsIn.where((p) => p.text.split(" ").length < 10);
      final bool percentOfSpace =
          (paraAchie.length / paragraghsIn.length) < 0.5;
      if (paragraghsIn.length > 2 && percentOfSpace) {
        paragraghsB.addAll(getElements(node.children));
      } else {
        paragraghsB.add(node);
      }
    }

    return paragraghsB;
  }

  dom.Element getElementIfContains(
      RegExp match, List<String> selectedWords, dom.Element paragraghElement) {
    final String paragragh = paragraghElement.outerHtml;
    List<String> splitSentence = [];

    if (paragragh.contains(match)) {
      int offset = 0;
      Iterable matches = match.allMatches(paragragh);
      int item = 0;
      for (final result in matches) {
        // ? Before sentence matching
        if (result.start > offset && result.start < paragragh.length) {
          splitSentence.add(
            paragragh.substring(offset, result.start),
          );
        } else {
          splitSentence.add(
            paragragh.substring(offset, result.start),
          );
        }
        // ? Sentence matching
        splitSentence.add(
          '<a href="word-added"><span style = "color:blue; font-weight: bold;">${paragragh.substring(result.start, result.end)}</span></a>',
        );
        // ? After all words of sentence matching
        offset = result.end;
        if (item == matches.length - 1) {
          splitSentence.add(
            paragragh.substring(result.end),
          );
        }
        item++;
      }
    } else {
      // ? Sentence without match
      splitSentence.add(
        paragragh,
      );
    }
    return dom.Element.html(splitSentence.join(""));
  }

  void value(String? href, RenderContext rContext, Map<String, String> values,
      dom.Element? element) {
    if (href == "word-added") {
      showDialog<CardTranslation>(
        context: context,
        builder: (context) => CardTranslation(
          word: element?.text ?? "",
        ),
      );
    }
  }

  Widget settingTheElement(dom.Element elemento) {
    // ? Display images if exists
    late dom.Element element;

    final data = Provider.of<BookData>(context, listen: false);
    final dataT = Provider.of<TextData>(context);

    Color colorFont =
        (MediaQuery.of(context).platformBrightness != Brightness.dark)
            ? dataT.textColorLM
            : dataT.textColorDM;

    styleCss["a"] = Style(
      color: colorFont,
      textDecoration: TextDecoration.none,
    );
    styleCss["p"] = Style(color: colorFont);
    styleCss["div"] = Style(color: colorFont);
    styleCss["h1"] = Style(alignment: Alignment.center);
    styleCss["h2"] = Style(alignment: Alignment.center);

    styleCss["td"] = Style(
      padding: const EdgeInsets.all(4.00),
      border: Border.all(width: 0.3, color: colorFont),
    );

    styleCss["*"] = Style(
      textAlign: TextAlign.justify,
      fontSize: FontSize(dataT.fontSize),
      fontFamily: dataT.fontFamily,
    );

    List<String> wordsToMach = dataT.selectedWords;
    if (wordsToMach.isNotEmpty) {
      RegExp match = RegExp(r"\b" + wordsToMach.join(r'\b|\b') + r"\b");
      if (elemento.text.contains(match)) {
        element = getElementIfContains(match, dataT.selectedWords, elemento);
      } else {
        element = elemento;
      }
    } else {
      element = elemento;
    }

    final controls = MyMaterialTextSelectionControls(
      changeTitle: (String word) => data.updateTitle(word),
      changeSelectedWords: (String word) {
        dataT.updateSelectedWords(word);
      },
      langFrom: dataT.language,
      langTo: dataT.toTranslate,
      tileBook: data.titleBook,
      paragraph: elemento.text.replaceAll("\n", " "),
    );

    if (element.localName == "div") {
      if (element.getElementsByTagName("img").isNotEmpty) {
        return Html(
          data: element.outerHtml,
          customRender: {
            'img': (RenderContext contextR, Widget child) {
              final local = contextR.tree.element!.attributes['src']!
                  .replaceAll('../', '');
              final image = Uint8List.fromList(
                  widget.controller.document.Content!.Images![local]!.Content!);
              return image_import.Image.memory(image);
            },
          },
        );
      } else if (element.localName == "li" ||
          element.localName == "ol" ||
          element.getElementsByTagName("li").isNotEmpty ||
          element.getElementsByTagName("ol").isNotEmpty) {
        return Html(
          data: element.outerHtml,
          style: styleCss,
          customRender: {
            "p": (contextR, child) {
              return SelectableHtml(
                  style: styleCss,
                  data: contextR.tree.element?.outerHtml ?? '');
            }
          },
        );
      } else if (element.getElementsByTagName("table").isNotEmpty ||
          element.localName == "table") {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Html(
            data: element.outerHtml,
            style: styleCss,
          ),
        );
      } else {
        // ? Display selectable text
        return SelectableHtml(
          data: element.outerHtml,
          selectionControls: controls,
          style: styleCss,
          onLinkTap: value,
        );
      }
    } else if (
        // element.getElementsByTagName("li").isNotEmpty ||
        // element.getElementsByTagName("ol").isNotEmpty ||
        element.localName == "li" || element.localName == "ol") {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Html(
          data: element.outerHtml,
          style: styleCss,
        ),
      );
    } else if (element.getElementsByTagName("table").isNotEmpty ||
        element.localName == "table") {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Html(
          data: element.outerHtml,
          style: styleCss,
        ),
      );
    } else if (element.localName == "img" ||
        element.getElementsByTagName("img").isNotEmpty) {
      return Html(
        data: element.outerHtml,
        customRender: {
          'img': (RenderContext contextR, Widget child) {
            final local =
                contextR.tree.element!.attributes['src']!.replaceAll('../', '');
            final image = Uint8List.fromList(
                widget.controller.document.Content!.Images![local]!.Content!);
            return image_import.Image.memory(image);
          },
        },
      );
    } else {
      return SelectableHtml(
        data: element.outerHtml,
        selectionControls: controls,
        onLinkTap: value,
        style: styleCss,
      );
    }
  }

  @override
  void initState() {
    final contentBody = parse(widget.doc.replaceAll("<title/>", " "));
    paragraghs.addAll(getElements(contentBody.body?.children ?? []));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<BookData>(context, listen: false);

    final ItemPositionsListener itemPositionsListener =
        ItemPositionsListener.create();

    widget.controller.chaptersController.addListener(() {
      if (mounted) {
        if ((widget.controller.chaptersController.page ?? 0.1) % 1 == 0) {
          if ((widget.controller.chaptersController.page ?? widget.index)
                  .toInt() !=
              widget.index) {
            if (mounted) {
              paragraghs.clear();
              setState(() {
                paragraghs = [];
              });
            }
          }
        }
      }
    });

    int currentScroll = 0;
    final ItemScrollController scroll = ItemScrollController();
    itemPositionsListener.itemPositions.addListener(() {
      if (mounted) {
        if (itemPositionsListener.itemPositions.value.isNotEmpty) {
          data.updateAlignment(
              itemPositionsListener.itemPositions.value.first.itemLeadingEdge);
          if (itemPositionsListener.itemPositions.value.first.index !=
              currentScroll) {
            currentScroll =
                itemPositionsListener.itemPositions.value.first.index;
            data.updateindexScroll(
                itemPositionsListener.itemPositions.value.first.index);
          }
        }
      }
    });

    return ScrollablePositionedList.separated(
        separatorBuilder: (context, index) => const SizedBox(),
        initialAlignment:
            widget.isLastChapter ? widget.controller.lastAlineo : 0.0,
        initialScrollIndex:
            widget.isLastChapter ? widget.controller.lastChapterScroll : 0,
        itemCount: paragraghs.length,
        itemBuilder: (context, index) =>
            settingTheElement(paragraghs.elementAt(index)),
        itemPositionsListener: itemPositionsListener,
        itemScrollController: scroll);
  }
}
