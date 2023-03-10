import 'package:flutter/widgets.dart';

class CustomKeyboardWidget extends StatefulWidget {
  const CustomKeyboardWidget({required this.builder, this.height = 0, Key? key})
      : super(key: key);

  final Widget? Function(BuildContext context) builder;

  /// keyboard height
  final double height;

  @override
  State<StatefulWidget> createState() => CustomKeyboardWidgetState();
}

class CustomKeyboardWidgetState extends State<CustomKeyboardWidget> {
  Widget? _lastBuildWidget;
  bool isClose = false;
  double _height = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _height = widget.height;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      left: 0,
      width: MediaQuery.of(context).size.width,
      bottom: _height * (isClose ? -1 : 0),
      height: _height,
      duration: const Duration(milliseconds: 100),
      child: IntrinsicHeight(child: Builder(
        builder: (BuildContext ctx) {
          final Widget? result = widget.builder(ctx);
          if (result != null) {
            _lastBuildWidget = result;
          }
          return ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 0,
              minWidth: 0,
              maxHeight: _height,
              maxWidth: MediaQuery.of(context).size.width,
            ),
            child: _lastBuildWidget,
          );
        },
      )),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void exitKeyboard() {
    isClose = true;
  }

  void update() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void updateHeight(double height) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _height = height;
      if (mounted) {
        setState(() {});
      }
    });
  }
}
