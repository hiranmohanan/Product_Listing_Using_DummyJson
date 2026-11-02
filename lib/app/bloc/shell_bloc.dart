import 'package:flutter_bloc/flutter_bloc.dart';
part 'shell_event.dart';
part 'shell_state.dart';

class ShellBloc extends Bloc<ShellEvent, ShellState> {
  ShellBloc() : super(const ShellState(0)) {
    on<ShellTabSelected>((event, emit) => emit(ShellState(event.index)));
  }
}
