part of 'theme_bloc.dart';

sealed class ThemeEvent {}

class ThemeLoaded extends ThemeEvent {}

class ThemeChanged extends ThemeEvent {
  ThemeChanged(this.enabled);
  final bool enabled;
}
