import 'package:final_babel_reader_app/src/utils/ebook_controller.dart';
import 'package:final_babel_reader_app/src/utils/providers/book_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class SliderChapter extends StatefulWidget {
  const SliderChapter(
      {Key? key,
      required this.controller,
      required this.min,
      required this.max,
      required this.setValueScroll,
      required this.listener})
      : super(key: key);
  final double max;
  final EbookController controller;
  final ItemPositionsListener listener;
  final double min;
  final Function setValueScroll;
  @override
  _SliderChapterState createState() => _SliderChapterState();
}

class _SliderChapterState extends State<SliderChapter> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final dataScrolling = Provider.of<BookData>(context, listen: false);

    widget.listener.itemPositions.addListener(
      () {
        dataScrolling.updateAlignment(
            widget.listener.itemPositions.value.first.itemLeadingEdge);

        if (widget.listener.itemPositions.value.first.index != currentIndex) {
          int lastIndex = widget.listener.itemPositions.value.first.index;
          dataScrolling.updateindexScroll(lastIndex);

          setState(
            () => currentIndex = lastIndex,
          );
        }
      },
    );
    return Slider(
        label: (currentIndex + 1) != 1 ? "Paragragh $currentIndex" : "Title",
        activeColor: Theme.of(context).appBarTheme.backgroundColor,
        value: currentIndex.toDouble(),
        min: widget.min,
        divisions: widget.max.toInt(),
        max: widget.max,
        onChanged: (val) {
          widget.setValueScroll(val);
          dataScrolling.updateindexScroll(val.toInt());
          setState(() => currentIndex = val.toInt());
        });
  }
}
