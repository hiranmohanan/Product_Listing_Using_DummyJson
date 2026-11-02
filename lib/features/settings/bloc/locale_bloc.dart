import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/local_store.dart';

part 'locale_event.dart';
part 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc(this.store) : super(const LocaleState('en')) {
    on<LocaleLoaded>((event, emit) async {
      final language = await store.readLanguage();
      emit(LocaleState(language == 'ar' ? 'ar' : 'en'));
    });
    on<LocaleChanged>((event, emit) async {
      emit(LocaleState(event.language));
      await store.saveLanguage(event.language);
    });
  }
  final LocalStore store;
}
