import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';

final pushEnabledProvider = Provider<bool>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final session = supabase.auth.currentSession;
  return session != null;
});
