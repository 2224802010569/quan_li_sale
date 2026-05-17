import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

typedef ErrorReporterCallback =
    Future<void> Function(Object error, StackTrace? stackTrace, String source);

typedef ErrorRecoveryCallback = void Function(GlobalErrorInfo info);

class GlobalErrorInfo {
  const GlobalErrorInfo({
    required this.error,
    required this.source,
    this.stackTrace,
  });

  final Object error;
  final StackTrace? stackTrace;
  final String source;
}

class GlobalErrorReporterConfig {
  const GlobalErrorReporterConfig({
    this.recipientEmail = '2224802010569@student.tdmu.edu.vn',
    this.senderEmail = '2224802010569@student.tdmu.edu.vn',
    this.senderPassword = 'jkpzkigyzjycfayq',
    this.senderName = 'Sale App',
    this.appName = 'Quan Li Sale',
    this.environment = 'production',
    this.enableInDebug = true,
    this.maxStackTraceLength = 6000,
    this.customReporter,
    this.recoveryCallback,
  });

  final String recipientEmail;
  final String senderEmail;
  final String senderPassword;
  final String senderName;
  final String appName;
  final String environment;
  final bool enableInDebug;
  final int maxStackTraceLength;
  final ErrorReporterCallback? customReporter;
  final ErrorRecoveryCallback? recoveryCallback;

  bool get canSendEmail =>
      recipientEmail.trim().isNotEmpty &&
      senderEmail.trim().isNotEmpty &&
      senderPassword.trim().isNotEmpty;
}

class GlobalErrorReporter {
  static GlobalErrorReporterConfig _config = const GlobalErrorReporterConfig();
  static bool _isInstalled = false;
  static FlutterExceptionHandler? _previousFlutterErrorHandler;
  static ErrorCallback? _previousPlatformErrorHandler;

  static Future<void> runGuarded(
    FutureOr<void> Function() appMain, {
    GlobalErrorReporterConfig config = const GlobalErrorReporterConfig(),
  }) async {
    _config = config;

    await runZonedGuarded(
      () async {
        _installFlutterHandlers();
        await appMain();
      },
      (error, stackTrace) {
        unawaited(_report(error, stackTrace, 'runZonedGuarded'));
      },
    );
  }

  static Future<void> report(
    Object error, {
    StackTrace? stackTrace,
    String source = 'manual',
  }) {
    return _report(error, stackTrace, source);
  }

  static void _installFlutterHandlers() {
    if (_isInstalled) return;
    _isInstalled = true;

    _previousFlutterErrorHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      if (_previousFlutterErrorHandler != null) {
        _previousFlutterErrorHandler!(details);
      } else {
        FlutterError.presentError(details);
      }

      unawaited(
        _report(details.exception, details.stack, 'FlutterError.onError'),
      );
    };

    _previousPlatformErrorHandler = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      unawaited(_report(error, stackTrace, 'PlatformDispatcher.onError'));
      return _previousPlatformErrorHandler?.call(error, stackTrace) ?? false;
    };
  }

  static Future<void> _report(
    Object error,
    StackTrace? stackTrace,
    String source,
  ) async {
    if (kDebugMode && !_config.enableInDebug) return;

    _config.recoveryCallback?.call(
      GlobalErrorInfo(error: error, stackTrace: stackTrace, source: source),
    );

    try {
      final customReporter = _config.customReporter;
      if (customReporter != null) {
        await customReporter(error, stackTrace, source);
        return;
      }

      if (!_config.canSendEmail) return;

      final smtpServer = gmail(_config.senderEmail, _config.senderPassword);
      final message = Message()
        ..from = Address(_config.senderEmail, _config.senderName)
        ..recipients.add(_config.recipientEmail)
        ..subject = '[${_config.appName}] Global error detected'
        ..text = _buildBody(error, stackTrace, source);

      await send(message, smtpServer);
    } catch (reportError, reportStackTrace) {
      debugPrint('GlobalErrorReporter failed: $reportError');
      debugPrint('$reportStackTrace');
    }
  }

  static String _buildBody(
    Object error,
    StackTrace? stackTrace,
    String source,
  ) {
    final now = DateTime.now().toIso8601String();
    final stack = stackTrace?.toString() ?? 'No stack trace';
    final trimmedStack = stack.length > _config.maxStackTraceLength
        ? '${stack.substring(0, _config.maxStackTraceLength)}\n...'
        : stack;

    return '''
App: ${_config.appName}
Environment: ${_config.environment}
Source: $source
Time: $now

Error:
$error

Stack trace:
$trimmedStack
''';
  }
}
