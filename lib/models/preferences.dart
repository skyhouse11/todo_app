import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'preferences.freezed.dart';
part 'preferences.g.dart';

@freezed
sealed class Preferences with _$Preferences {
  const factory Preferences({
    required Brightness brightness,
    required bool toShowNotifications,
  }) = _Preferences;

  factory Preferences.fromJson(Map<String, dynamic> json) =>
      _$PreferencesFromJson(json);
}
