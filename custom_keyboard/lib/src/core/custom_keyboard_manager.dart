import 'dart:async';
import 'dart:ui' as ui;
import 'package:custom_flutter_keyboard/src/core/custom_text_input.dart';
import 'package:custom_flutter_keyboard/src/widget/custom_keyboard_app.dart';
import 'package:custom_flutter_keyboard/src/tool/custom_keyboard_binary_messenger.dart';
import 'package:custom_flutter_keyboard/src/tool/custom_keyboard_binding.dart';
import 'package:custom_flutter_keyboard/src/core/custom_keyboard_controller.dart';
import 'package:custom_flutter_keyboard/src/widget/custom_keyboard_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef GetKeyboardHeight = double Function(BuildContext context);

typedef KeyboardBuilder = Widget Function(
  BuildContext context,
  CustomKeyboardController controller,
  String? param,
);

class KeyboardConfig {
  const KeyboardConfig({
    required this.builder,
    required this.getHeight,
  });

  /// keyboard widget build function
  final KeyboardBuilder builder;

  /// keyboard height buid function
  final GetKeyboardHeight getHeight;
}

class CustomKeyboardManager {
  static const JSONMethodCodec _codec = JSONMethodCodec();
  static KeyboardConfig? _currentKeyboard;
  static final Map<CustomTextInputType, KeyboardConfig> _keyboards =
      <CustomTextInputType, KeyboardConfig>{};
  static CustomKeyboardAppState? _customKeyboardAppState;
  static BuildContext? _buildContext;
  static CustomKeyboardController? _keyboardController;
  static bool _hasInterceptor = false;
  static Timer? clearTask;
  static String? _keyboardParam;
  static GlobalKey<CustomKeyboardWidgetState>? _pageKey;
  static ValueNotifier<double> keyboardHeightNotifier = ValueNotifier<double>(0)
    ..addListener(_updateKeyboardHeight);
  static ValueChanged<dynamic>? onResponseValueChange;

  static void init(CustomKeyboardAppState root, BuildContext context) {
    _customKeyboardAppState = root;
    _buildContext = context;
    if (_hasInterceptor || ServicesBinding.instance is! CustomKeyboardBinding) {
      return;
    }
    final CustomKeyboardBinding mockBinding =
        ServicesBinding.instance as CustomKeyboardBinding;
    final CustomKeyboardBinaryMessenger mockBinaryMessenger =
        mockBinding.defaultBinaryMessenger as CustomKeyboardBinaryMessenger;
    mockBinaryMessenger.setMockMessageHandler(
      'flutter/textinput',
      _textInputHanlde,
    );
    _hasInterceptor = true;
  }

  static void register(
    CustomTextInputType inputType,
    KeyboardBuilder builder,
    GetKeyboardHeight getHeight,
  ) {
    final KeyboardConfig config = KeyboardConfig(
      builder: builder,
      getHeight: getHeight,
    );
    _keyboards[inputType] = config;
  }

  static void openKeyboard() {
    final double keyboardHeight = _currentKeyboard!.getHeight(_buildContext!);
    keyboardHeightNotifier.value = keyboardHeight;
    if (_customKeyboardAppState!.hasKeyboard && _pageKey != null) {
      return;
    }
    _pageKey = GlobalKey<CustomKeyboardWidgetState>();

    final GlobalKey<CustomKeyboardWidgetState>? tempKey = _pageKey;
    bool isUpdate = false;
    _customKeyboardAppState!.setKeyboard((BuildContext ctx) {
      if (_currentKeyboard != null && keyboardHeightNotifier.value != 0) {
        if (!isUpdate) {
          isUpdate = true;
        }
        return CustomKeyboardWidget(
            key: tempKey,
            builder: (BuildContext ctx) {
              return _currentKeyboard?.builder(
                  ctx, _keyboardController!, _keyboardParam);
            },
            height: keyboardHeightNotifier.value);
      } else {
        return Container();
      }
    });
  }

  static void hideKeyboard({bool animation = true}) {
    if (clearTask != null) {
      if (clearTask!.isActive) {
        clearTask!.cancel();
      }
      clearTask = null;
    }
    if (_customKeyboardAppState!.hasKeyboard && _pageKey != null) {
      if (animation) {
        _pageKey!.currentState?.exitKeyboard();
        Future<void>.delayed(const Duration(milliseconds: 116)).then((_) {
          _customKeyboardAppState!.clearKeyboard();
        });
      } else {
        _customKeyboardAppState!.clearKeyboard();
      }
    }
    _pageKey = null;
    keyboardHeightNotifier.value = 0;
  }

  static void clearKeyboard() {
    _currentKeyboard = null;
    if (_keyboardController != null) {
      _keyboardController!.dispose();
      _keyboardController = null;
    }
  }

  static void sendPerformAction(TextInputAction action) {
    final MethodCall callbackMethodCall = MethodCall(
        'TextInputClient.performAction',
        <Object>[_keyboardController!.client.connectionId, action.toString()]);
    WidgetsBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/textinput',
        _codec.encodeMethodCall(callbackMethodCall),
        (ByteData? data) {});
  }

  static void handleResponseValueChange(dynamic value) {
    if (_pageKey != null &&
        _pageKey!.currentState != null &&
        clearTask == null) {
      if (onResponseValueChange != null) {
        onResponseValueChange!(value);
      }
    }
  }

  static void _updateKeyboardHeight() {
    if (_pageKey != null &&
        _pageKey!.currentState != null &&
        clearTask == null) {
      _pageKey!.currentState!.updateHeight(keyboardHeightNotifier.value);
    }
  }

  static Future<ByteData?> _textInputHanlde(ByteData? data) async {
    final MethodCall methodCall = _codec.decodeMethodCall(data);
    switch (methodCall.method) {
      case 'TextInput.show':
        if (_currentKeyboard != null) {
          if (clearTask != null) {
            clearTask!.cancel();
            clearTask = null;
          }
          openKeyboard();
          return _codec.encodeSuccessEnvelope(null);
        } else {
          if (data != null) {
            return await _sendPlatformMessage('flutter/textinput', data);
          }
        }
        break;
      case 'TextInput.hide':
        if (_currentKeyboard != null) {
          clearTask ??= Timer(
            const Duration(milliseconds: 0),
            () => hideKeyboard(animation: false),
          );
          return _codec.encodeSuccessEnvelope(null);
        } else {
          if (data != null) {
            return await _sendPlatformMessage('flutter/textinput', data);
          }
        }
        break;
      case 'TextInput.setEditingState':
        final TextEditingValue editingState = TextEditingValue.fromJSON(
          methodCall.arguments as Map<String, dynamic>,
        );
        if (_keyboardController != null) {
          _keyboardController!.value = editingState;
          return _codec.encodeSuccessEnvelope(null);
        }
        break;
      case 'TextInput.clearClient':
        final bool isShow = _currentKeyboard != null;
        clearTask ??= Timer(
          const Duration(milliseconds: 16),
          () => hideKeyboard(animation: true),
        );
        clearKeyboard();
        if (isShow) {
          return _codec.encodeSuccessEnvelope(null);
        }
        break;
      case 'TextInput.setClient':
        final dynamic setInputType = methodCall.arguments[1]['inputType'];
        InputClient? client;
        _keyboards.forEach((
          CustomTextInputType inputType,
          KeyboardConfig keyboardConfig,
        ) {
          if (inputType.name == setInputType['name']) {
            client =
                InputClient.fromJSON(methodCall.arguments as List<dynamic>);

            _keyboardParam =
                (client!.configuration.inputType as CustomTextInputType).params;

            clearKeyboard();
            _currentKeyboard = keyboardConfig;
            _keyboardController = CustomKeyboardController(client: client!)
              ..addListener(_updateEditingState);
            if (_pageKey != null) {
              _pageKey!.currentState?.update();
            }
          }
        });

        if (client != null) {
          await _sendPlatformMessage(
            'flutter/textinput',
            _codec.encodeMethodCall(const MethodCall('TextInput.hide')),
          );
          return _codec.encodeSuccessEnvelope(null);
        } else {
          if (clearTask == null) {
            hideKeyboard(animation: false);
          }
          clearKeyboard();
        }
    }
    if (data != null) {
      final ByteData? response =
          await _sendPlatformMessage('flutter/textinput', data);
      return response;
    }
    return null;
  }

  static Future<ByteData?> _sendPlatformMessage(
    String channel,
    ByteData message,
  ) {
    final Completer<ByteData?> completer = Completer<ByteData?>();
    ui.window.sendPlatformMessage(channel, message, (ByteData? reply) {
      try {
        completer.complete(reply);
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'services library',
          context:
              ErrorDescription('during a platform message response callback'),
        ));
      }
    });
    return completer.future;
  }

  static void _updateEditingState() {
    final MethodCall callbackMethodCall = MethodCall(
        'TextInputClient.updateEditingState', <Object>[
      _keyboardController!.client.connectionId,
      _keyboardController!.value.toJSON()
    ]);
    WidgetsBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/textinput',
        _codec.encodeMethodCall(callbackMethodCall),
        (ByteData? data) {});
  }
}

class InputClient {
  const InputClient({required this.connectionId, required this.configuration});
  factory InputClient.fromJSON(List<dynamic> encoded) {
    return InputClient(
        connectionId: encoded[0] as int,
        configuration: TextInputConfiguration(
            inputType: CustomTextInputType.fromJSON(
                encoded[1]['inputType'] as Map<String, dynamic>),
            obscureText: encoded[1]['obscureText'] as bool,
            autocorrect: encoded[1]['autocorrect'] as bool,
            actionLabel: encoded[1]['actionLabel'] as String?,
            inputAction:
                _toTextInputAction(encoded[1]['inputAction'] as String),
            textCapitalization: _toTextCapitalization(
                encoded[1]['textCapitalization'] as String),
            keyboardAppearance:
                _toBrightness(encoded[1]['keyboardAppearance'] as String)));
  }
  final int connectionId;
  final TextInputConfiguration configuration;

  static TextInputAction _toTextInputAction(String action) {
    switch (action) {
      case 'TextInputAction.none':
        return TextInputAction.none;
      case 'TextInputAction.unspecified':
        return TextInputAction.unspecified;
      case 'TextInputAction.go':
        return TextInputAction.go;
      case 'TextInputAction.search':
        return TextInputAction.search;
      case 'TextInputAction.send':
        return TextInputAction.send;
      case 'TextInputAction.next':
        return TextInputAction.next;
      case 'TextInputAction.previuos':
        return TextInputAction.previous;
      case 'TextInputAction.continue_action':
        return TextInputAction.continueAction;
      case 'TextInputAction.join':
        return TextInputAction.join;
      case 'TextInputAction.route':
        return TextInputAction.route;
      case 'TextInputAction.emergencyCall':
        return TextInputAction.emergencyCall;
      case 'TextInputAction.done':
        return TextInputAction.done;
      case 'TextInputAction.newline':
        return TextInputAction.newline;
    }
    throw FlutterError('Unknown text input action: $action');
  }

  static TextCapitalization _toTextCapitalization(String capitalization) {
    switch (capitalization) {
      case 'TextCapitalization.none':
        return TextCapitalization.none;
      case 'TextCapitalization.characters':
        return TextCapitalization.characters;
      case 'TextCapitalization.sentences':
        return TextCapitalization.sentences;
      case 'TextCapitalization.words':
        return TextCapitalization.words;
    }

    throw FlutterError('Unknown text capitalization: $capitalization');
  }

  static Brightness _toBrightness(String brightness) {
    switch (brightness) {
      case 'Brightness.dark':
        return Brightness.dark;
      case 'Brightness.light':
        return Brightness.light;
    }

    throw FlutterError('Unknown Brightness: $brightness');
  }
}
