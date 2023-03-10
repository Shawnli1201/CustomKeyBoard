import 'package:custom_flutter_keyboard/custom_flutter_keyboard.dart';
import 'package:flutter/material.dart';

class CustomKeyboardApp extends StatefulWidget {
  const CustomKeyboardApp(
      {Key? key, required this.child, this.textDirection = TextDirection.ltr})
      : super(key: key);
  final Widget child;
  final TextDirection textDirection;

  @override
  State<CustomKeyboardApp> createState() => CustomKeyboardAppState();
}

class CustomKeyboardAppState extends State<CustomKeyboardApp> {
  WidgetBuilder? _keyboardbuilder;
  bool get hasKeyboard => _keyboardbuilder != null;

  /// set new keyboard build
  void setKeyboard(WidgetBuilder keyboardbuilder) {
    _keyboardbuilder = keyboardbuilder;
    setState(() {});
  }

  /// remove keyboard
  void clearKeyboard() {
    if (_keyboardbuilder != null) {
      _keyboardbuilder = null;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomKeyboardMediaQueryWidget(
        child: Builder(builder: (BuildContext context) {
      CustomKeyboardManager.init(this, context);
      final List<Widget> children = <Widget>[widget.child];
      if (_keyboardbuilder != null) {
        children.add(Builder(
          builder: _keyboardbuilder!,
        ));
      }
      return Directionality(
          textDirection: widget.textDirection,
          child: Stack(
            children: children,
          ));
    }));
  }
}
