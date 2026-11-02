import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/product_repository.dart';
import '../../core/strings.dart';
import 'bloc/scanner_bloc.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        ScannerBloc(context.read<ProductRepository>())..add(ScannerStarted()),
    child: const _ScannerView(),
  );
}

class _ScannerView extends StatelessWidget {
  const _ScannerView();

  @override
  Widget build(BuildContext context) => BlocConsumer<ScannerBloc, ScannerState>(
    listenWhen: (previous, current) => previous.result != current.result,
    listener: (context, state) {
      if (state.result != null) {
        Navigator.of(context).pop(state.result);
      }
    },
    builder: (context, state) => Scaffold(
      appBar: AppBar(title: Text(tr(context, 'scanner'))),
      body: SafeArea(
        child: Column(
          children: [
            if (!state.manual && state.error.isNotEmpty)
              MaterialBanner(
                leading: const Icon(Icons.info_outline),
                content: Text(tr(context, state.error)),
                actions: [
                  if (state.error == 'loadError' ||
                      state.error == 'offlineProduct')
                    TextButton(
                      onPressed: () => context.read<ScannerBloc>().add(
                        ScannerRetryLastCode(),
                      ),
                      child: Text(tr(context, 'retry')),
                    ),
                  TextButton(
                    onPressed: () => context.read<ScannerBloc>().add(
                      ScannerErrorDismissed(),
                    ),
                    child: Text(tr(context, 'dismiss')),
                  ),
                ],
              ),
            Expanded(
              child: state.manual
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              autofocus: true,
                              autocorrect: false,
                              onChanged: (value) => context
                                  .read<ScannerBloc>()
                                  .add(ScannerManualChanged(value)),
                              decoration: InputDecoration(
                                hintText: tr(context, 'codeHint'),
                                errorText: state.error.isEmpty
                                    ? null
                                    : tr(context, state.error),
                              ),
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: state.verifying
                                  ? null
                                  : () => context.read<ScannerBloc>().add(
                                      ScannerManualSubmitted(),
                                    ),
                              child: state.verifying
                                  ? Text(tr(context, 'checkingCode'))
                                  : Text(tr(context, 'openProduct')),
                            ),
                          ],
                        ),
                      ),
                    )
                  : state.checking
                  ? const Center(child: CircularProgressIndicator())
                  : state.allowed
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        MobileScanner(
                          onDetect: (capture) {
                            for (final barcode in capture.barcodes) {
                              final value = barcode.rawValue;
                              if (value != null) {
                                context.read<ScannerBloc>().add(
                                  ScannerCodeDetected(value),
                                );
                                break;
                              }
                            }
                          },
                        ),
                        if (state.verifying)
                          ColoredBox(
                            color: Colors.black54,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 16),
                                  Text(
                                    tr(context, 'checkingCode'),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.no_photography_outlined, size: 60),
                            const SizedBox(height: 16),
                            Text(
                              tr(context, 'cameraDenied'),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: openAppSettings,
                              icon: const Icon(Icons.settings_outlined),
                              label: Text(tr(context, 'openSettings')),
                            ),
                            TextButton(
                              onPressed: () => context.read<ScannerBloc>().add(
                                ScannerPermissionRetried(),
                              ),
                              child: Text(tr(context, 'retry')),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            if (!state.manual)
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.read<ScannerBloc>().add(ScannerManualOpened()),
                    icon: const Icon(Icons.keyboard_outlined),
                    label: Text(tr(context, 'typeCode')),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
