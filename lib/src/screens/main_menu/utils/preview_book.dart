import 'dart:io';
import 'dart:typed_data';
import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/image.dart' as image;
import 'package:image/image.dart' as imageCover;

class PreviewBook extends StatefulWidget {
  const PreviewBook({Key? key, required this.bookLocation}) : super(key: key);
  final String bookLocation;

  @override
  PreviewBookState createState() => PreviewBookState();
}

class PreviewBookState extends State<PreviewBook> {
  Future<EpubBookRef> getBook() async {
    final EpubBookRef book =
        await EpubReader.openBook(File(widget.bookLocation).readAsBytes());
    return book;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<EpubBookRef>(
                  future: getBook(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const CircularProgressIndicator();
                      default:
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                                "There was an error reading the book: ${snapshot.error}"),
                          );
                        } else {
                          return Column(
                            children: [
                              Expanded(
                                child: (snapshot.data != null)
                                    ? FutureBuilder<imageCover.Image?>(
                                        future: snapshot.data!.readCover(),
                                        builder: (context, snapshotImage) {
                                          return Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: (snapshotImage.data != null)
                                                ? image.Image.memory(
                                                    Uint8List.fromList(
                                                        imageCover.encodePng(
                                                            snapshotImage
                                                                .data!)),
                                                  )
                                                : const SizedBox(),
                                          );
                                        })
                                    : const SizedBox(),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    DropdownButton(
                                        items: <String>[
                                      "en",
                                      "es",
                                      "de",
                                      "fr",
                                      "ru",
                                      "it"
                                    ].map<DropdownMenuItem<String>>((lang) {
                                      if (lang == "en") {
                                        return DropdownMenuItem<String>(
                                          value: lang,
                                          child: const Text("English"),
                                        );
                                      } else if (lang == "es") {
                                        return DropdownMenuItem<String>(
                                          value: lang,
                                          child: const Text("Spanish"),
                                        );
                                      } else if (lang == "de") {
                                        return DropdownMenuItem<String>(
                                          value: lang,
                                          child: const Text("Deutsch"),
                                        );
                                      } else if (lang == "fr") {
                                        return DropdownMenuItem<String>(
                                          value: lang,
                                          child: const Text("French"),
                                        );
                                      } else if (lang == "it") {
                                        return DropdownMenuItem<String>(
                                          value: lang,
                                          child: const Text("Italian"),
                                        );
                                      } else {
                                        return DropdownMenuItem<String>(
                                          value: lang,
                                          child: const Text("Russian"),
                                        );
                                      }
                                    }).toList()),
                                    Text(snapshot.data?.Title ?? ""),
                                    Text(snapshot.data?.Author ?? ""),
                                  ],
                                ),
                              )
                            ],
                          );
                        }
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
