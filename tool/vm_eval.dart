import 'dart:async';
import 'dart:io';

import 'package:vm_service/vm_service_io.dart';

/// Development helper: evaluates an expression in the running debug app.
///
/// Usage: `dart run tool/vm_eval.dart <vm-service-http-url> <library-uri> [expr]`
Future<void> main(List<String> args) async {
  if (args.length < 2) {
    stderr.writeln(
      'Usage: dart run tool/vm_eval.dart <vm-url> <library-uri> [expression]',
    );
    exitCode = 64;
    return;
  }

  final base = args[0];
  final libraryUri = args[1];
  final expression = args.length > 2
      ? args[2]
      : "(() async { Element? scope; void visit(Element e) { "
          "if (scope != null) return; "
          "if (e.widget is UncontrolledProviderScope) { scope = e; return; } "
          "e.visitChildren(visit); } "
          "visit(WidgetsBinding.instance.rootElement!); "
          "final c = (scope!.widget as UncontrolledProviderScope).container; "
          "final s = c.read(settingsProvider); "
          "await c.read(settingsProvider.notifier).completeOnboarding("
          "locale: s.locale, theme: s.theme, currencyCode: s.currencyCode, "
          "lockEnabled: s.lockEnabled); "
          "c.read(routerProvider).go('/dashboard'); })()";

  final wsUrl = base.replaceFirst('http://', 'ws://').replaceFirst(
        RegExp(r'/$'),
        '/ws',
      );
  final service = await vmServiceConnectUri(wsUrl);
  try {
    final vm = await service.getVM();
    for (final ref in vm.isolates ?? const []) {
      final isolate = await service.getIsolate(ref.id!);
      for (final library in isolate.libraries ?? const []) {
        if (library.uri != libraryUri) {
          continue;
        }
        final result = await service.evaluate(
          ref.id!,
          library.id!,
          expression,
          disableBreakpoints: true,
        );
        if (result.json?['type'] == 'Error') {
          stderr.writeln('Error: ${result.json?['message']}');
          stderr.writeln(result.json?['exception']?.toString());
          exitCode = 1;
        } else {
          stdout.writeln('OK: ${result.json}');
        }
        return;
      }
    }
    stderr.writeln('Library $libraryUri not found.');
    exitCode = 1;
  } finally {
    await service.dispose();
  }
}
