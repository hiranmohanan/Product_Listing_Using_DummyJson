part of 'scanner_bloc.dart';

class ScannerState {
  const ScannerState({
    this.checking = true,
    this.allowed = false,
    this.manual = false,
    this.verifying = false,
    this.input = '',
    this.error = '',
    this.result,
  });
  final bool checking;
  final bool allowed;
  final bool manual;
  final bool verifying;
  final String input;
  final String error;
  final int? result;

  ScannerState copyWith({
    bool? checking,
    bool? allowed,
    bool? manual,
    bool? verifying,
    String? input,
    String? error,
    int? result,
  }) => ScannerState(
    checking: checking ?? this.checking,
    allowed: allowed ?? this.allowed,
    manual: manual ?? this.manual,
    verifying: verifying ?? this.verifying,
    input: input ?? this.input,
    error: error ?? this.error,
    result: result ?? this.result,
  );
}
