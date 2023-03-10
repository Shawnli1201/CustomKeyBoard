import 'package:custom_flutter_keyboard/src/core/custom_keyboard_manager.dart';
import 'package:flutter/material.dart';

class CustomKeyboardController extends ValueNotifier<TextEditingValue> {
  CustomKeyboardController({TextEditingValue? value, required this.client})
      : super(value ?? TextEditingValue.empty);
  final InputClient client;

  String get text => value.text;

  set text(String newText) {
    value = value.copyWith(
        text: newText,
        selection: const TextSelection.collapsed(offset: -1),
        composing: TextRange.empty);
  }

  TextSelection get selection => value.selection;

  set selection(TextSelection newSelection) {
    if (newSelection.start > text.length || newSelection.end > text.length) {
      throw FlutterError('invalid text selection: $newSelection');
    }
    value = value.copyWith(selection: newSelection, composing: TextRange.empty);
  }

  @override
  set value(TextEditingValue newValue) {
    newValue = newValue.copyWith(
        composing: TextRange(
            start: newValue.composing.start < 0 ? 0 : newValue.composing.start,
            end: newValue.composing.end < 0 ? 0 : newValue.composing.end),
        selection: newValue.selection.copyWith(
            baseOffset: newValue.selection.baseOffset < 0
                ? 0
                : newValue.selection.baseOffset,
            extentOffset: newValue.selection.extentOffset < 0
                ? 0
                : newValue.selection.extentOffset));

    super.value = newValue;
  }

  void clear() {
    value = TextEditingValue.empty;
  }

  void clearComposing() {
    value = value.copyWith(composing: TextRange.empty);
  }

  void deleteText() {
    if (selection.baseOffset == 0) {
      return;
    }
    String newText = '';
    if (selection.baseOffset != selection.extentOffset) {
      newText = selection.textBefore(text) + selection.textAfter(text);
      value = TextEditingValue(
          text: newText,
          selection: selection.copyWith(
              baseOffset: selection.baseOffset,
              extentOffset: selection.baseOffset));
    } else {
      newText = text.substring(0, selection.baseOffset - 1) +
          selection.textAfter(text);
      value = TextEditingValue(
          text: newText,
          selection: selection.copyWith(
              baseOffset: selection.baseOffset - 1,
              extentOffset: selection.baseOffset - 1));
    }
  }

  void addText(String insertText) {
    final String newText =
        selection.textBefore(text) + insertText + selection.textAfter(text);
    value = TextEditingValue(
        text: newText,
        selection: selection.copyWith(
            baseOffset: selection.baseOffset + insertText.length,
            extentOffset: selection.baseOffset + insertText.length));
  }

  void sendPerformAction(TextInputAction action) {
    CustomKeyboardManager.sendPerformAction(action);
  }

  void handleResponseValueChange(dynamic value) {
    CustomKeyboardManager.handleResponseValueChange(value);
  }
}
