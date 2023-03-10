import 'package:custom_flutter_keyboard/src/tool/custom_keyboard_binary_messenger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomKeyboardBinding extends WidgetsFlutterBinding {
  CustomKeyboardBinaryMessenger? _binaryMessenger;

  @override
  void initInstances() {
    _binaryMessenger = CustomKeyboardBinaryMessenger(this);
    super.initInstances();
  }

  @override
  BinaryMessenger get defaultBinaryMessenger {
    return _binaryMessenger != null
        ? _binaryMessenger!
        : super.defaultBinaryMessenger;
  }

  BinaryMessenger get superDefaultBinaryMessenger {
    return super.defaultBinaryMessenger;
  }
}
