// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../../core/constants/app_constants.dart';

// class LocalProviders extends GetxService {
//   late SharedPreferences _sharedPreferences;
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

//   // Initialize method - call this in main.dart
//   Future<LocalRepository> init() async {
//     _sharedPreferences = await SharedPreferences.getInstance();
//     return this;
//   }

//   // ========== SHARED PREFERENCES METHODS ==========

//   // Boolean operations
//   Future<bool> setBool(String key, bool value) async {
//     return await _sharedPreferences.setBool(key, value);
//   }

//   bool getBool(String key, {bool defaultValue = false}) {
//     return _sharedPreferences.getBool(key) ?? defaultValue;
//   }

//   // String operations
//   Future<bool> setString(String key, String value) async {
//     return await _sharedPreferences.setString(key, value);
//   }

//   String? getString(String key) {
//     return _sharedPreferences.getString(key);
//   }

//   // Int operations
//   Future<bool> setInt(String key, int value) async {
//     return await _sharedPreferences.setInt(key, value);
//   }

//   int? getInt(String key) {
//     return _sharedPreferences.getInt(key);
//   }

//   // Double operations
//   Future<bool> setDouble(String key, double value) async {
//     return await _sharedPreferences.setDouble(key, value);
//   }

//   double? getDouble(String key) {
//     return _sharedPreferences.getDouble(key);
//   }

//   // String List operations
//   Future<bool> setStringList(String key, List<String> value) async {
//     return await _sharedPreferences.setStringList(key, value);
//   }

//   List<String>? getStringList(String key) {
//     return _sharedPreferences.getStringList(key);
//   }

//   // Object operations (using JSON)
//   Future<bool> setObject(String key, Map<String, dynamic> value) async {
//     return await _sharedPreferences.setString(key, json.encode(value));
//   }

//   Map<String, dynamic>? getObject(String key) {
//     final String? data = _sharedPreferences.getString(key);
//     if (data != null) {
//       return json.decode(data);
//     }
//     return null;
//   }

//   // Remove data
//   Future<bool> remove(String key) async {
//     return await _sharedPreferences.remove(key);
//   }

//   // Clear all data
//   Future<bool> clear() async {
//     return await _sharedPreferences.clear();
//   }

//   // Check if key exists
//   bool containsKey(String key) {
//     return _sharedPreferences.containsKey(key);
//   }

//   // ========== SECURE STORAGE METHODS ==========

//   // Save secure data (encrypted)
//   Future<void> setSecureData(String key, String value) async {
//     await _secureStorage.write(key: key, value: value);
//   }

//   // Get secure data
//   Future<String?> getSecureData(String key) async {
//     return await _secureStorage.read(key: key);
//   }

//   // Delete secure data
//   Future<void> deleteSecureData(String key) async {
//     await _secureStorage.delete(key: key);
//   }

//   // Delete all secure data
//   Future<void> deleteAllSecureData() async {
//     await _secureStorage.deleteAll();
//   }

//   // Check if secure key exists
//   Future<bool> containsSecureKey(String key) async {
//     final data = await _secureStorage.read(key: key);
//     return data != null;
//   }

//   // Get all secure keys
//   Future<List<String>> getAllSecureKeys() async {
//     return await _secureStorage.readAll().then((map) => map.keys.toList());
//   }

//   // ========== APP SPECIFIC METHODS ==========

//   // Onboarding
//   Future<void> setOnboarded(bool value) async {
//     await setBool(AppConstants.onboardedKey, value);
//   }

//   bool isOnboarded() {
//     return getBool(AppConstants.onboardedKey, defaultValue: false);
//   }

//   // Theme Mode
//   Future<void> setThemeMode(ThemeMode mode) async {
//     await setString('theme_mode', mode.toString());
//   }

//   ThemeMode getThemeMode() {
//     final String? mode = getString('theme_mode');
//     if (mode != null) {
//       if (mode == 'ThemeMode.dark') {
//         return ThemeMode.dark;
//       } else if (mode == 'ThemeMode.light') {
//         return ThemeMode.light;
//       }
//     }
//     return ThemeMode.system;
//   }

//   // Language
//   Future<void> setLanguage(String languageCode) async {
//     await setString('language', languageCode);
//   }

//   String getLanguage() {
//     return getString('language') ?? 'en';
//   }

//   // ========== AUTH METHODS ==========

//   // Save auth token (in secure storage)
//   Future<void> setAuthToken(String token) async {
//     await setSecureData(AppConstants.authTokenKey, token);
//   }

//   Future<String?> getAuthToken() async {
//     return await getSecureData(AppConstants.authTokenKey);
//   }

//   // Save user data
//   Future<void> setUserData(Map<String, dynamic> userData) async {
//     await setObject(AppConstants.userDataKey, userData);
//   }

//   Map<String, dynamic>? getUserData() {
//     return getObject(AppConstants.userDataKey);
//   }

//   // Check if user is logged in
//   Future<bool> isLoggedIn() async {
//     final token = await getAuthToken();
//     return token != null && token.isNotEmpty;
//   }

//   // Clear auth data on logout
//   Future<void> clearAuthData() async {
//     await remove(AppConstants.userDataKey);
//     await deleteSecureData(AppConstants.authTokenKey);
//   }

//   // ========== SESSION MANAGEMENT ==========

//   // Save last login time
//   Future<void> setLastLogin() async {
//     await setString('last_login', DateTime.now().toIso8601String());
//   }

//   DateTime? getLastLogin() {
//     final String? dateStr = getString('last_login');
//     if (dateStr != null) {
//       return DateTime.parse(dateStr);
//     }
//     return null;
//   }

//   // Check if session is expired (e.g., after 7 days)
//   bool isSessionExpired({int days = 7}) {
//     final lastLogin = getLastLogin();
//     if (lastLogin == null) return true;
//     final expiryDate = lastLogin.add(Duration(days: days));
//     return DateTime.now().isAfter(expiryDate);
//   }

//   // ========== CACHE MANAGEMENT ==========

//   // Save cached data with timestamp
//   Future<void> setCachedData(String key, dynamic data) async {
//     final cacheData = {
//       'data': data,
//       'timestamp': DateTime.now().toIso8601String(),
//     };
//     await setObject('cache_$key', cacheData);
//   }

//   // Get cached data if not expired
//   T? getCachedData<T>(String key, {Duration expiry = const Duration(hours: 1)}) {
//     final cache = getObject('cache_$key');
//     if (cache != null) {
//       final timestamp = DateTime.parse(cache['timestamp']);
//       if (DateTime.now().difference(timestamp) < expiry) {
//         return cache['data'] as T;
//       }
//     }
//     return null;
//   }

//   // Clear cache
//   Future<void> clearCache() async {
//     final keys = _sharedPreferences.getKeys();
//     for (String key in keys) {
//       if (key.startsWith('cache_')) {
//         await remove(key);
//       }
//     }
//   }

//   // ========== APP SETTINGS ==========

//   // Save app settings
//   Future<void> setAppSettings(Map<String, dynamic> settings) async {
//     await setObject('app_settings', settings);
//   }

//   Map<String, dynamic>? getAppSettings() {
//     return getObject('app_settings');
//   }

//   // Save notification settings
//   Future<void> setNotificationEnabled(bool enabled) async {
//     await setBool('notifications_enabled', enabled);
//   }

//   bool isNotificationEnabled() {
//     return getBool('notifications_enabled', defaultValue: true);
//   }

//   // ========== UTILITY METHODS ==========

//   // Print all shared preferences (for debugging)
//   void printAllPreferences() {
//     debugPrint('=== Shared Preferences ===');
//     _sharedPreferences.getKeys().forEach((key) {
//       debugPrint('$key: ${_sharedPreferences.get(key)}');
//     });
//   }

//   // Get all preferences as map
//   Map<String, dynamic> getAllPreferences() {
//     final Map<String, dynamic> allData = {};
//     _sharedPreferences.getKeys().forEach((key) {
//       allData[key] = _sharedPreferences.get(key);
//     });
//     return allData;
//   }

//   // Get storage size info
//   Future<int> getStorageSize() async {
//     int totalSize = 0;
//     _sharedPreferences.getKeys().forEach((key) {
//       final value = _sharedPreferences.get(key);
//       if (value != null) {
//         totalSize += value.toString().length;
//       }
//     });
//     return totalSize;
//   }
// }