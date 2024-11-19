import 'package:flutter/material.dart';

class MonitorMessageNotifier<T> {
  ValueNotifier<List<T>>? _notifier;

  ValueNotifier<List<T>>? get notifier => _notifier;

  static const int MAX_COUNT = 20;

  List<T>? _message;

  List<T>? get message => _message;

  void add(T message, {bool limit = true}) {
    try {
      if (_message == null) {
        _message = [];
        _notifier = ValueNotifier(_message!);
      }
      if (_message!.length >= MAX_COUNT && limit) {
        _message!.removeLast();
      }
      _message!.insert(0, message);
      _notifier!.value = <T>[]..addAll(_message!);
    } catch (e) {
      print(e);
    }
  }

  void clear() {
    _message?.clear();
    _notifier!.value = [];
  }
}
