import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../database/db_helper.dart';

class StorageHelper {
  static const String settingsBoxName = 'settings';
  static const String bookmarksBoxName = 'bookmarks';
  static const String profileBoxName = 'profile';

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      await Hive.openBox(settingsBoxName);
      await Hive.openBox(bookmarksBoxName);
      await Hive.openBox(profileBoxName);
    } catch (e) {
      debugPrint("Hive initialization failure, resetting storage boxes: $e");
      try {
        await Hive.deleteBoxFromDisk(settingsBoxName);
        await Hive.deleteBoxFromDisk(bookmarksBoxName);
        await Hive.deleteBoxFromDisk(profileBoxName);
        
        await Hive.openBox(settingsBoxName);
        await Hive.openBox(bookmarksBoxName);
        await Hive.openBox(profileBoxName);
      } catch (e2) {
        debugPrint("Hive critical recovery failed: $e2");
      }
    }
  }

  // Clear all caches in the app to optimize performance and reset
  static Future<void> clearAllCache() async {
    try {
      // 1. Clear Hive data stores
      await settingsBox.clear();
      await bookmarksBox.clear();
      await profileBox.clear();

      // 2. Clear SQLite Viewed History
      await DbHelper.instance.clearHistory();

      // 3. Clear Flutter Engine Image Cache to free memory instantly
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      
      debugPrint("Cleared all cached app data successfully!");
    } catch (e) {
      debugPrint("Error performing cache sweep: $e");
    }
  }


  // settings helpers
  static Box get settingsBox => Hive.box(settingsBoxName);
  
  static bool get isDarkMode => settingsBox.get('darkMode', defaultValue: false);
  static set isDarkMode(bool value) => settingsBox.put('darkMode', value);

  static double get textSize => settingsBox.get('textSize', defaultValue: 14.0);
  static set textSize(double value) => settingsBox.put('textSize', value);

  static String get language => settingsBox.get('language', defaultValue: 'en');
  static set language(String value) => settingsBox.put('language', value);

  // bookmarks helpers
  static Box get bookmarksBox => Hive.box(bookmarksBoxName);

  static List<int> getBookmarkedIds() {
    final list = bookmarksBox.get('ids', defaultValue: <int>[]);
    return List<int>.from(list);
  }

  static Future<void> toggleBookmark(int id) async {
    final ids = getBookmarkedIds();
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await bookmarksBox.put('ids', ids);
  }

  static bool isBookmarked(int id) {
    return getBookmarkedIds().contains(id);
  }

  // profile helpers
  static Box get profileBox => Hive.box(profileBoxName);

  static String get userName => profileBox.get('name', defaultValue: 'Future Physiotherapist');
  static set userName(String value) => profileBox.put('name', value);

  static String get userUniversity => profileBox.get('university', defaultValue: 'UET Taxila - DPT Program');
  static set userUniversity(String value) => profileBox.put('university', value);

  static Future<void> saveProfile(String name, String university) async {
    await profileBox.put('name', name);
    await profileBox.put('university', university);
  }

  static List<String> getCompletedRegions() {
    final list = profileBox.get('completedRegions', defaultValue: <String>[]);
    return List<String>.from(list);
  }

  static Future<void> markRegionCompleted(String region) async {
    final regions = getCompletedRegions();
    if (!regions.contains(region)) {
      regions.add(region);
      await profileBox.put('completedRegions', regions);
    }
  }

  static Future<void> removeCompletedRegion(String region) async {
    final regions = getCompletedRegions();
    if (regions.contains(region)) {
      regions.remove(region);
      await profileBox.put('completedRegions', regions);
    }
  }
}
