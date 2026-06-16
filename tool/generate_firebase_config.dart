import 'dart:convert';
import 'dart:io';

final envVarMap = {
  'apiKey': 'FIREBASE_API_KEY',
  'projectId': 'FIREBASE_PROJECT_ID',
  'messagingSenderId': 'FIREBASE_MESSAGING_SENDER_ID',
  'appId': 'FIREBASE_APP_ID',
};

void main(List<String> args) {
  final env = args.isNotEmpty ? args.first : 'prod';
  final envFile = '.env.$env';

  if (!File(envFile).existsSync()) {
    stderr.writeln('ERROR: $envFile not found');
    exitCode = 1;
    return;
  }

  final lines = File(envFile).readAsLinesSync();
  final config = <String, String>{};

  for (final entry in envVarMap.entries) {
    final key = entry.value;
    final value = _findValue(lines, key);
    if (value == null || value.isEmpty) {
      stderr.writeln('ERROR: $key not set in $envFile');
      exitCode = 1;
      return;
    }
    config[entry.key] = value;
  }

  final js = '''
self.FIREBASE_CONFIG = ${jsonEncode(config)};
'''.trim();

  File('web/firebase-config.js').writeAsStringSync(js);
  print('Generated web/firebase-config.js from $envFile');
}

String? _findValue(List<String> lines, String key) {
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('$key=')) {
      final value = trimmed.substring('$key='.length);
      if (value.isNotEmpty && !value.startsWith('#')) return value;
    }
  }
  return null;
}
