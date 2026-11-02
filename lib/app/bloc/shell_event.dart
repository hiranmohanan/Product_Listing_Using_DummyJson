part of 'shell_bloc.dart';

sealed class ShellEvent {}

class ShellTabSelected extends ShellEvent {
  ShellTabSelected(this.index);
  final int index;
}
