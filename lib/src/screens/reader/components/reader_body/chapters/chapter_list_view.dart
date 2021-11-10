import 'dart:typed_data';
import 'package:epubx/epubx.dart';
import 'package:final_babel_reader_app/src/screens/reader/components/reader_body/chapters/slider_chapter.dart';
import 'package:final_babel_reader_app/src/screens/reader/components/reader_body/paragrahps/paragraph_book.dart';
import 'package:final_babel_reader_app/src/utils/ebook_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter/src/widgets/image.dart' as image_import;
import 'package:html/parser.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ReaderChapter extends StatefulWidget {
  const ReaderChapter({
    Key? key,
    required this.controller,
    required this.index,
    required this.doc,
    required this.isLastChapter,
  }) : super(key: key);

  final EpubTextContentFile doc;
  final int index;
  final EbookController controller;
  final bool isLastChapter;

  @override
  State<ReaderChapter> createState() => _ReaderChapterState();
}

class _ReaderChapterState extends State<ReaderChapter> {
  List<dom.Element> getElements(List<dom.Element> elements) {
    List<dom.Element> paragraghsB = [];

    for (final node in elements) {
      if (node.getElementsByTagName("p").length > 2) {
        paragraghsB.addAll(getElements(node.children));
      } else {
        paragraghsB.add(node);
      }
    }

    return paragraghsB;
  }

  Widget? settingTheElement(dom.Element element) {
    // ? Display images if exists
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
      } else if (element.getElementsByTagName("h1").isNotEmpty ||
          element.getElementsByTagName("h2").isNotEmpty ||
          element.getElementsByTagName("h3").isNotEmpty) {
        // ? Display h1 or h2 if there h
        return Html(data: element.outerHtml);
      } else if (element.getElementsByTagName("li").isNotEmpty) {
        return Html(data: element.outerHtml);
      } else {
        // ? Display selectable text
        final finalParagraph = element.text;
        if (finalParagraph.isNotEmpty) {
          if (element.outerHtml.contains("<br")) {
            return HtmlPragragh(
              paragragh: finalParagraph,
            );
          } else {
            return HtmlPragragh(
              paragragh: finalParagraph.replaceAll("\n", " "),
            );
          }
        }
      }
    } else if (element.getElementsByTagName("table").isNotEmpty) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Html(
          data: element.outerHtml,
        ),
      );
    } else if (element.localName == "image" ||
        element.getElementsByTagName("image").isNotEmpty) {
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
    } else if (element.localName == "p") {
      final finalParagraph = element.text;
      if (finalParagraph.isNotEmpty) {
        if (element.outerHtml.contains("<br")) {
          return HtmlPragragh(
            paragragh: finalParagraph,
          );
        }
        return HtmlPragragh(
          paragragh: finalParagraph.replaceAll("\n", " "),
        );
      }
    } else {
      return Html(
        data: element.outerHtml,
      );
    }
  }

  List<dom.Element> paragraghs = [];

  @override
  void initState() {
    dom.Element? contentBody =
        parse(widget.doc.Content, encoding: 'text/html').body;
    paragraghs.addAll(getElements(contentBody!.children));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

    final ItemPositionsListener itemPositionsListener =
        ItemPositionsListener.create();
    final ItemScrollController scroll = ItemScrollController();
    // itemPositionsListener.itemPositions.addListener(() {
    //   print(itemPositionsListener.itemPositions.value);
    // });

    return Column(
      children: [
        Expanded(
          flex: 40,
          child: ScrollablePositionedList.builder(
              initialAlignment:
                  widget.isLastChapter ? widget.controller.lastAlineo : 0.0,
              initialScrollIndex: widget.isLastChapter
                  ? widget.controller.lastChapterScroll
                  : 0,
              itemCount: paragraghs.length,
              itemBuilder: (context, index) =>
                  settingTheElement(paragraghs.elementAt(index)) ??
                  const SizedBox(),
              itemPositionsListener: itemPositionsListener,
              itemScrollController: scroll),
        ),
        if (paragraghs.length > 1)
          Expanded(
            flex: 4,
            child: SliderChapter(
                min: 0,
                controller: widget.controller,
                max: (paragraghs.length - 1).toDouble(),
                setValueScroll: (value) {
                  scroll.jumpTo(
                    index: value.toInt(),
                  );
                },
                listener: itemPositionsListener),
          )
      ],
    );
  }
}
