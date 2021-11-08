import 'package:flutter/material.dart';

class HeroPageView<T> extends PageRoute<T> {
  HeroPageView(
      {required Widget Function(BuildContext) builder,
      RouteSettings? settings,
      bool fullscreenDialog = false})
      : _builder = builder,
        super(fullscreenDialog: fullscreenDialog, settings: settings);

  final WidgetBuilder _builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Color? get barrierColor => Colors.black54;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return _builder(context);
  }

  @override
  bool get maintainState => true;

  @override
  String? get barrierLabel => "Pop up";
}
