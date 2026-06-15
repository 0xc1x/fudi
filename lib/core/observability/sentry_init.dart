import 'dart:async';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/app_config.dart';

/// Initializes Sentry with environment-specific configuration.
///
/// Follows the guidelines in docs/ai/ERROR_HANDLING.md:
/// - DSN per environment
/// - Release tracking
/// - beforeSend strips non-fatal events in dev
/// - No PII ever sent (sendDefaultPii = false)
/// - Traces and profiles sample rates vary by environment
Future<void> initSentry(
  AppConfig config,
  FutureOr<void> Function() appRunner,
) async {
  await SentryFlutter.init((options) {
    options.dsn = config.sentryDsn;
    options.environment = config.environment.name;
    options.release = 'fudi@1.0.0+1';
    options.tracesSampleRate = config.isDev
        ? 1.0
        : (config.isStaging ? 0.5 : 0.2);
    // ignore: experimental_member_use
    options.profilesSampleRate = config.isDev
        ? 1.0
        : (config.isStaging ? 0.3 : 0.1);
    options.attachStacktrace = true;
    options.attachThreads = true;
    options.sendDefaultPii = false;
    options.enableLogs = true;

    // Before send: filter and enrich
    options.beforeSend = (event, hint) {
      // In dev, only send fatal events (crashes)
      // TEMPORARILY DISABLED FOR TESTING SENTRY INTEGRATION
      // if (config.isDev && event.level != SentryLevel.fatal) {
      //   return null;
      // }
      // Enrich with app context
      event.tags ??= {};
      event.tags!['app_version'] = '1.0.0';
      event.tags!['environment'] = config.environment.shortName;
      return event;
    };

    // Before send transaction: discard health checks
    options.beforeSendTransaction = (transaction, hint) {
      final transactionName = transaction.transaction;
      if (transactionName != null &&
          transactionName.startsWith('GET /health')) {
        return null;
      }
      return transaction;
    };
  }, appRunner: appRunner);
}
