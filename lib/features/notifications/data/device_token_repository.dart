import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeviceTokenRepository {
  DeviceTokenRepository({required SupabaseClient supabaseClient})
    : _supabase = supabaseClient;

  final SupabaseClient _supabase;

  String get _platform {
    if (kIsWeb) return 'web';
    // ignore: avoid_dynamic_calls
    return defaultTargetPlatform.name == 'iOS' ? 'ios' : 'android';
  }

  Future<void> upsertToken({
    required String userId,
    required String token,
  }) async {
    await _supabase.from('device_tokens').upsert(
      {
        'user_id': userId,
        'token': token,
        'platform': _platform,
        'device_info': {
          'platform': _platform,
          'user_agent': kIsWeb ? 'web' : null,
        },
        'is_active': true,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'token',
      ignoreDuplicates: false,
    );
  }

  Future<void> deactivateToken({required String token}) async {
    await _supabase
        .from('device_tokens')
        .update({
          'is_active': false,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('token', token);
  }

  Future<void> deactivateAllUserTokens({required String userId}) async {
    await _supabase
        .from('device_tokens')
        .update({
          'is_active': false,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('user_id', userId);
  }
}
