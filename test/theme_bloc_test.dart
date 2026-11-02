import 'package:flutter_test/flutter_test.dart';
import 'package:product_list_auth_app/core/local_store.dart';
import 'package:product_list_auth_app/features/settings/theme_bloc/theme_bloc.dart';

class FakeThemeStore implements LocalStore {
  bool darkMode = false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<bool> readDarkMode() async => darkMode;

  @override
  Future<void> saveDarkMode(bool enabled) async {
    darkMode = enabled;
  }
}

void main() {
  test('dark mode setting loads and persists', () async {
    final store = FakeThemeStore();
    final bloc = ThemeBloc(store)..add(ThemeChanged(true));
    await bloc.stream.firstWhere((state) => state.darkMode);
    await bloc.close();
    expect(store.darkMode, isTrue);

    final restored = ThemeBloc(store)..add(ThemeLoaded());
    expect((await restored.stream.first).darkMode, isTrue);
    await restored.close();
  });
}
