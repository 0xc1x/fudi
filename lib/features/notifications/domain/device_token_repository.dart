abstract class DeviceTokenRepository {
  Future<void> upsertToken({
    required String userId,
    required String token,
  });

  Future<void> deactivateToken({required String token});

  Future<void> deactivateAllUserTokens({required String userId});
}
