part of 'locale_bloc.dart';

sealed class LocaleEvent {}

class LocaleLoaded extends LocaleEvent {}

class LocaleChanged extends LocaleEvent {
  LocaleChanged(this.language);
  final String language;
}
