import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/place.dart';
import '../models/review.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String _keyCustomPlaces = 'accesspath_custom_places_v1';
  static const String _keyCustomReviews = 'accesspath_custom_reviews_v1';
  static const String _keyBookmarkedIds = 'accesspath_bookmarked_ids_v1';
  static const String _keyUserProfile = 'accesspath_user_profile_v1';

  final SharedPreferences? _prefs;

  StorageService([this._prefs]);

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  Future<void> saveBookmarkedIds(Set<String> ids) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setStringList(_keyBookmarkedIds, ids.toList());
  }

  Set<String> loadBookmarkedIds() {
    final prefs = _prefs;
    if (prefs == null) return {};
    final list = prefs.getStringList(_keyBookmarkedIds);
    return list != null ? list.toSet() : {};
  }

  Future<void> saveCustomPlaces(List<Place> places) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final jsonList = places.map((p) => p.toJson()).toList();
    await prefs.setString(_keyCustomPlaces, jsonEncode(jsonList));
  }

  List<Place>? loadCustomPlaces() {
    final prefs = _prefs;
    if (prefs == null) return null;
    final raw = prefs.getString(_keyCustomPlaces);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => Place.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return null;
    }
  }

  Future<void> saveCustomReviews(List<Review> reviews) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final jsonList = reviews.map((r) => r.toJson()).toList();
    await prefs.setString(_keyCustomReviews, jsonEncode(jsonList));
  }

  List<Review>? loadCustomReviews() {
    final prefs = _prefs;
    if (prefs == null) return null;
    final raw = prefs.getString(_keyCustomReviews);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return null;
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_keyUserProfile, jsonEncode(profile.toJson()));
  }

  UserProfile loadUserProfile() {
    final prefs = _prefs;
    if (prefs == null) return const UserProfile();
    final raw = prefs.getString(_keyUserProfile);
    if (raw == null || raw.isEmpty) return const UserProfile();
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      return const UserProfile();
    }
  }

  Future<void> clearAll() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.remove(_keyCustomPlaces);
    await prefs.remove(_keyCustomReviews);
    await prefs.remove(_keyBookmarkedIds);
    await prefs.remove(_keyUserProfile);
  }
}
