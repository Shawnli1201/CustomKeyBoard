import 'package:custom_flutter_keyboard/src/tool/custom_keyboard_binding.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class CustomKeyboardBinaryMessenger extends BinaryMessenger {
  CustomKeyboardBinaryMessenger(this.mockBinding);
  final CustomKeyboardBinding mockBinding;

  final Map<String, MessageHandler> _inboundHandlers =
      <String, MessageHandler>{};
  final List<Future<ByteData?>> _pendingMessages = <Future<ByteData?>>[];
  int get pendingMessageCount => _pendingMessages.length;
  final Map<String, MessageHandler> _outboundHandlers =
      <String, MessageHandler>{};
  final Map<String, Object> _outboundHandlerIdentities = <String, Object>{};

  @override
  Future<void> handlePlatformMessage(String channel, ByteData? data,
      ui.PlatformMessageResponseCallback? callback) {
    Future<ByteData?>? result;
    if (_inboundHandlers.containsKey(channel)) {
      result = _inboundHandlers[channel]!(data);
    }
    result ??= Future<ByteData?>.value(null);
    if (callback != null) {
      result = result.then((ByteData? result) {
        callback(result);
        return result;
      });
    }
    return result;
  }

  @override
  Future<ByteData?>? send(String channel, ByteData? message) {
    final Future<ByteData?>? resultFuture;
    final MessageHandler? handler = _outboundHandlers[channel];
    if (handler != null) {
      resultFuture = handler(message);
    } else {
      resultFuture =
          mockBinding.superDefaultBinaryMessenger.send(channel, message);
    }
    if (resultFuture != null) {
      _pendingMessages.add(resultFuture);
      resultFuture
          .catchError((Object error) {})
          .whenComplete(() => _pendingMessages.remove(resultFuture));
    }
    return resultFuture;
  }

  @override
  void setMessageHandler(String channel, MessageHandler? handler) {
    if (handler == null) {
      _inboundHandlers.remove(channel);
      mockBinding.superDefaultBinaryMessenger.setMessageHandler(channel, null);
    } else {
      _inboundHandlers[channel] = handler;
      mockBinding.superDefaultBinaryMessenger
          .setMessageHandler(channel, handler);
    }
  }

  Future<void> get platformMessagesFinished {
    return Future.wait<void>(_pendingMessages);
  }

  void setMockMessageHandler(String channel, MessageHandler? handler,
      [Object? identity]) {
    if (handler == null) {
      _outboundHandlers.remove(channel);
      _outboundHandlerIdentities.remove(channel);
    } else {
      identity ??= handler;
      _outboundHandlers[channel] = handler;
      _outboundHandlerIdentities[channel] = identity;
    }
  }

  void setMockDecodedMessageHandler<T>(
      BasicMessageChannel<T> channel, Future<T> Function(T? message)? handler) {
    if (handler == null) {
      setMockMessageHandler(channel.name, null);
      return;
    }
    setMockMessageHandler(channel.name, (ByteData? message) async {
      return channel.codec
          .encodeMessage(await handler(channel.codec.decodeMessage(message)));
    }, handler);
  }

  void setMockMethodCallHandler(MethodChannel channel,
      Future<Object?>? Function(MethodCall message)? handler) {
    if (handler == null) {
      setMockMessageHandler(channel.name, null);
      return;
    }
    setMockMessageHandler(channel.name, (ByteData? message) async {
      final MethodCall call = channel.codec.decodeMethodCall(message);
      try {
        return channel.codec.encodeSuccessEnvelope(await handler(call));
      } on PlatformException catch (error) {
        return channel.codec.encodeErrorEnvelope(
          code: error.code,
          message: error.message,
          details: error.details,
        );
      } on MissingPluginException {
        return null;
      } catch (error) {
        return channel.codec.encodeErrorEnvelope(
            code: 'error', message: '$error', details: null);
      }
    }, handler);
  }

  bool checkMockMessageHandler(String channel, Object? handler) =>
      _outboundHandlerIdentities[channel] == handler;
}
