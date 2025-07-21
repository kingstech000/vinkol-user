abstract class LocalCache {
  ///Retrieves access token for authorizing requests
  String? getToken();

  ///Saves access token for authorizing requests
  Future<void> saveToken(String tokenId);

  ///Deletes cached access token
  Future<void> deleteToken();

  ///Saves user data
  Future<void> saveUserData(Map<String, dynamic> json);

  ///Retrieves user data
  Map<String, dynamic>? getUserData();
// ONBOARDING
  Future<void> onBoarded();
  Future<bool> isOnBoarded();

  Future<void> toggleBalanceVisibility();
  bool isBalanceVisible();

  ///Saves `value` to cache using `key`
  Future<void> saveToLocalCache({
    required String key,
    required dynamic value,
  });

  ///Retrieves a cached value stored with `key`
  Object? getFromLocalCache(String key);

  ///Removes cached value stored with `key` from cache
  Future<void> removeFromLocalCache(String key);

  ///Clears cache
  Future<void> clearCache();
}
