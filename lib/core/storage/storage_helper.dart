import 'package:hive_flutter/hive_flutter.dart';

class StorageHelper {
  static const String settingsBoxName = 'settings';
  static const String bookmarksBoxName = 'bookmarks';
  static const String profileBoxName = 'profile';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Open boxes
    await Hive.openBox(settingsBoxName);
    await Hive.openBox(bookmarksBoxName);
    await Hive.openBox(profileBoxName);
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
