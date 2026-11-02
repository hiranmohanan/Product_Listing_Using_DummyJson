part of 'scanner_bloc.dart';

sealed class ScannerEvent {}

class ScannerStarted extends ScannerEvent {}

class ScannerPermissionRetried extends ScannerEvent {}

class ScannerManualOpened extends ScannerEvent {}

class ScannerManualChanged extends ScannerEvent {
  ScannerManualChanged(this.value);
  final String value;
}

class ScannerManualSubmitted extends ScannerEvent {}

class ScannerCodeDetected extends ScannerEvent {
  ScannerCodeDetected(this.value);
  final String value;
}

class ScannerRetryLastCode extends ScannerEvent {}

class ScannerErrorDismissed extends ScannerEvent {}
