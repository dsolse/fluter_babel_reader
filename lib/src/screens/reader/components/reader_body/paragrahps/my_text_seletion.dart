import 'package:flutter/material.dart';

class CustomSelectableText extends SelectableText {
  const CustomSelectableText.rich(Key key,
      {required TextSpan textSpan,
      required TextSelectionControls selectionControls})
      : super.rich(textSpan, selectionControls: selectionControls, key: key);

  @override
  bool get wantKeepAlive => false;
}
