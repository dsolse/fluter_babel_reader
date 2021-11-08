import 'package:final_babel_reader_app/src/utils/data_classes.dart';
import 'package:final_babel_reader_app/src/utils/providers/book_data_provider.dart';
import 'package:final_babel_reader_app/src/utils/providers/text_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'prebuild_reader.dart';

class EbookReader extends StatelessWidget {
  const EbookReader({Key? key, required this.ebook}) : super(key: key);
  final MapEbookData ebook;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BookData(),
        ),
        ChangeNotifierProvider(create: (_) => TextData())
      ],
      builder: (context, _) {
        return EbookReaderFuture(epubBook: ebook);
      },
    );
  }
}
