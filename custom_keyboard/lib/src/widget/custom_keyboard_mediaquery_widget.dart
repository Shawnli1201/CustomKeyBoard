import 'package:custom_flutter_keyboard/custom_flutter_keyboard.dart';
import 'package:custom_flutter_keyboard/src/core/custom_keyboard_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class CustomKeyboardMediaQueryWidget extends StatefulWidget {
  const CustomKeyboardMediaQueryWidget(
      {Key? key,
      required this.child,
      this.isCenterModel = false,
      this.fixPadding = 0,
      this.autoHidden = true,
      this.onResponseValueChange})
      : super(key: key);

  final Widget child;

  /// center model,make child widget in center
  final bool isCenterModel;

  /// the gap between keyboard and child widget
  final double fixPadding;

  /// hide keyboard when you click widget
  final bool autoHidden;

  /// receive value from your custom actions
  final ValueChanged<dynamic>? onResponseValueChange;

  @override
  State<CustomKeyboardMediaQueryWidget> createState() =>
      _CustomKeyboardMediaQueryWidgetState();
}

class _CustomKeyboardMediaQueryWidgetState
    extends State<CustomKeyboardMediaQueryWidget> {
  @override
  void initState() {
    super.initState();
    CustomKeyboardManager.keyboardHeightNotifier.addListener(onUpdateHeight);
  }

  @override
  void dispose() {
    super.dispose();
    CustomKeyboardManager.keyboardHeightNotifier.removeListener(onUpdateHeight);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onResponseValueChange != null) {
      CustomKeyboardManager.onResponseValueChange =
          widget.onResponseValueChange;
    }
    MediaQueryData? mediaQueryData = MediaQuery.maybeOf(context);
    mediaQueryData ??=
        MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    final MediaQuery mediaQuery;
    if (!widget.isCenterModel) {
      final double bottom =
          CustomKeyboardManager.keyboardHeightNotifier.value != 0
              ? CustomKeyboardManager.keyboardHeightNotifier.value
              : mediaQueryData.viewInsets.bottom;
      mediaQuery = MediaQuery(
        data: mediaQueryData.copyWith(
          viewInsets: mediaQueryData.viewInsets.copyWith(bottom: bottom),
        ),
        child: widget.child,
      );
    } else {
      final double bottom = CustomKeyboardManager.keyboardHeightNotifier.value;
      mediaQuery = MediaQuery(
        data: mediaQueryData,
        child: Column(
          children: <Widget>[
            const Spacer(),
            widget.child,
            if (bottom == 0)
              const Spacer()
            else
              Container(
                height: bottom + widget.fixPadding,
              ),
          ],
        ),
      );
    }
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (widget.autoHidden) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: mediaQuery);
  }

  void onUpdateHeight() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
      SchedulerBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.handleMetricsChanged();
      });
    });
  }
}
