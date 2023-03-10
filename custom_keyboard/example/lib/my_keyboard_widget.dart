import 'package:custom_flutter_keyboard/custom_flutter_keyboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum FunctionButtonType { delete, hidden, sure, custom }

class MyKeyboardWidget extends StatefulWidget {
  const MyKeyboardWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final CustomKeyboardController controller;

  static const CustomTextInputType keyboardType =
      CustomTextInputType(name: 'myKeyboardType');

  static double getHeight(BuildContext context) {
    if (safeAreaBottom == 0) {
      safeAreaBottom = MediaQuery.of(context).padding.bottom;
    }
    if (screenWidth == 0) {
      screenWidth = MediaQuery.of(context).size.width;
    }
    return screenWidth / ratio + safeAreaBottom;
  }

  static double ratio = 1.5;
  static double safeAreaBottom = 0;
  static double screenWidth = 0;

  @override
  State<MyKeyboardWidget> createState() => _MyKeyboardWidgetState();
}

class _MyKeyboardWidgetState extends State<MyKeyboardWidget> {
  final double lineWidth = 0.5;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: buildNumberWidget(context));
  }

  Widget buildNumberWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
            height: MyKeyboardWidget.screenWidth / MyKeyboardWidget.ratio,
            child: Column(
              children: <Widget>[
                Divider(
                    height: lineWidth,
                    color: const Color.fromRGBO(166, 166, 166, 1)),
                Container(
                  color: const Color.fromRGBO(166, 166, 166, 1),
                  width: MyKeyboardWidget.screenWidth,
                  height:
                      MyKeyboardWidget.screenWidth / MyKeyboardWidget.ratio -
                          lineWidth,
                  child: GridView.count(
                      childAspectRatio: MyKeyboardWidget.ratio,
                      mainAxisSpacing: lineWidth,
                      crossAxisSpacing: lineWidth,
                      padding: const EdgeInsets.all(0.0),
                      crossAxisCount: 4,
                      physics: const NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        buildButton('0'),
                        buildButton('1'),
                        buildButton('2'),
                        buildButton('3'),
                        buildButton('4'),
                        buildButton('5'),
                        buildButton('6'),
                        buildButton('7'),
                        buildButton('8'),
                        buildButton('9'),
                        buildButton('.'),
                        buildButton('00'),
                        buildFunctionButton(FunctionButtonType.hidden),
                        buildFunctionButton(FunctionButtonType.delete),
                        buildFunctionButton(FunctionButtonType.sure),
                        buildFunctionButton(FunctionButtonType.custom),
                      ]),
                ),
              ],
            )),
        Container(
          height: MyKeyboardWidget.safeAreaBottom,
          color: const Color.fromRGBO(255, 255, 255, 1),
        )
      ],
    );
  }

  Widget buildButton(String title, {String? value}) {
    return CupertinoButton(
        color: const Color.fromRGBO(255, 255, 255, 1),
        padding: EdgeInsets.zero,
        borderRadius: const BorderRadius.all(Radius.circular(0)),
        pressedOpacity: 0.8,
        child: Text(
          title,
          style:
              const TextStyle(color: Color.fromRGBO(0, 0, 0, 1), fontSize: 23),
        ),
        onPressed: () {
          widget.controller.addText(value ?? title);
        });
  }

  Widget buildFunctionButton(FunctionButtonType buttonType) {
    String title = '';
    if (buttonType == FunctionButtonType.sure) {
      title = 'Sure';
    } else if (buttonType == FunctionButtonType.delete) {
      title = 'Delete';
    } else if (buttonType == FunctionButtonType.hidden) {
      title = 'Hide';
    } else if (buttonType == FunctionButtonType.custom) {
      title = 'Custom';
    }
    return CupertinoButton(
        color: const Color.fromRGBO(255, 255, 255, 1),
        padding: EdgeInsets.zero,
        borderRadius: const BorderRadius.all(Radius.circular(0)),
        pressedOpacity: 0.8,
        child: Text(
          title,
          style:
              const TextStyle(color: Color.fromRGBO(0, 0, 0, 1), fontSize: 23),
        ),
        onPressed: () {
          if (buttonType == FunctionButtonType.delete) {
            widget.controller.deleteText();
          } else if (buttonType == FunctionButtonType.hidden) {
            FocusManager.instance.primaryFocus?.unfocus();
          } else if (buttonType == FunctionButtonType.sure) {
            widget.controller.sendPerformAction(TextInputAction.done);
          } else if (buttonType == FunctionButtonType.custom) {
            widget.controller.handleResponseValueChange('custom any value');
          }
        });
  }
}
