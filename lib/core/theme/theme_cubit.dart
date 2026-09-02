import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../storage/local_storage.dart';

/// App-wide [ThemeMode] holder, persisted via [LocalStorage]. Registered as a
/// lazy singleton and provided above `MaterialApp`.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._storage) : super(ThemeMode.system) {
    _restore();
  }

  final LocalStorage _storage;

  void _restore() {
    final saved = _storage.getString(StorageKeys.themeMode);
    emit(switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    });
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    await _storage.setString(StorageKeys.themeMode, mode.name);
  }

  Future<void> toggle() =>
      setThemeMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}
