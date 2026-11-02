import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/local_store.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc(this.store) : super(const ThemeState(false)) {
    on<ThemeLoaded>((event, emit) async {
      emit(ThemeState(await store.readDarkMode()));
    });
    on<ThemeChanged>((event, emit) async {
      emit(ThemeState(event.enabled));
      await store.saveDarkMode(event.enabled);
    });
  }

  final LocalStore store;
}
