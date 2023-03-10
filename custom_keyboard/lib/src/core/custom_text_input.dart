import 'package:flutter/material.dart';

class CustomTextInputType extends TextInputType {
  const CustomTextInputType({
    required this.name,
    bool? signed,
    bool? decimal,
    this.params,
  }) : super.numberWithOptions(signed: signed, decimal: decimal);

  factory CustomTextInputType.fromJSON(Map<String, dynamic> encoded) {
    return CustomTextInputType(
      name: encoded['name'] as String,
      signed: encoded['signed'] as bool?,
      decimal: encoded['decimal'] as bool?,
      params: encoded['params'] as String?,
    );
  }

  /// keep it unique
  final String name;

  final String? params;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'signed': signed,
      'decimal': decimal,
      'params': params,
    };
  }

  @override
  String toString() {
    return '$runtimeType('
        'name: $name, '
        'signed: $signed, '
        'decimal: $decimal)';
  }

  @override
  // ignore: avoid_renaming_method_parameters
  bool operator ==(Object target) {
    if (target is CustomTextInputType) {
      if (name == target.toString()) {
        return true;
      }
    }
    return false;
  }

  @override
  int get hashCode => toString().hashCode;
}
