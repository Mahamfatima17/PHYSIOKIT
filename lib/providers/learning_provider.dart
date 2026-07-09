import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';
import '../../core/storage/storage_helper.dart';
import '../models/special_test.dart';

class LearningProvider extends ChangeNotifier {
  List<SpecialTest> _allTests = [];
  List<SpecialTest> _searchResult = [];
  List<SpecialTest> _recentHistory = [];
  List<int> _bookmarkedIds = [];
  
  bool _isLoading = false;
  String _searchQuery = '';
  
  // Progress tracking
  int _completedCount = 0;
  
  LearningProvider() {
    _init();
  }

  // Getters
  List<SpecialTest> get allTests => _allTests;
  List<SpecialTest> get searchResult => _searchResult.isEmpty && _searchQuery.isEmpty ? _allTests : _searchResult;
  List<SpecialTest> get recentHistory => _recentHistory;
  List<int> get bookmarkedIds => _bookmarkedIds;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  int get totalTestsCount => _allTests.length;
  int get completedTestsCount => _completedCount;
  double get learningProgressPercentage {
    if (totalTestsCount == 0) return 0.0;
    return (_completedCount / totalTestsCount) * 100.0;
  }

  // Initialize data
  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    
    await refreshAll();
    
    _isLoading = false;
    notifyListeners();
  }

  // Refresh everything
  Future<void> refreshAll() async {
    await fetchAllTests();
    await fetchHistory();
    loadBookmarks();
    _loadProgress();
  }

  // Load bookmarks from Hive
  void loadBookmarks() {
    _bookmarkedIds = StorageHelper.getBookmarkedIds();
    notifyListeners();
  }

  // Load progress
  void _loadProgress() {
    // We count a test as "completed" if it has been viewed at least once in history
    final viewedIds = _recentHistory.map((e) => e.id).toSet();
    _completedCount = viewedIds.length;
    notifyListeners();
  }

  // Fetch all tests from SQLite
  Future<void> fetchAllTests() async {
    final list = await DbHelper.instance.fetchAllTests();
    _allTests = list.map((e) => SpecialTest.fromMap(e)).toList();
    notifyListeners();
  }

  // Fetch tests by region
  List<SpecialTest> getTestsByRegion(String region) {
    return _allTests.where((t) => t.region.toLowerCase() == region.toLowerCase()).toList();
  }

  // Fetch tests by major anatomical region (Upper Limb, Lower Limb, Spine, Neurology)
  List<SpecialTest> getTestsByAnatomicalRegion(String anatomicalRegion) {
    if (anatomicalRegion.toLowerCase() == 'upper limb') {
      return _allTests.where((t) => 
        t.region.toLowerCase() == 'shoulder' || 
        t.region.toLowerCase() == 'elbow' || 
        t.region.toLowerCase() == 'wrist and hand'
      ).toList();
    } else if (anatomicalRegion.toLowerCase() == 'lower limb') {
      return _allTests.where((t) => 
        t.region.toLowerCase() == 'hip' || 
        t.region.toLowerCase() == 'knee' || 
        t.region.toLowerCase() == 'ankle and foot' ||
        t.region.toLowerCase() == 'pelvis'
      ).toList();
    } else if (anatomicalRegion.toLowerCase() == 'spine') {
      return _allTests.where((t) => 
        t.region.toLowerCase() == 'cervical spine' || 
        t.region.toLowerCase() == 'pelvis' // Pelvis contains SIJ tests
      ).toList();
    } else if (anatomicalRegion.toLowerCase() == 'neurology') {
      return _allTests.where((t) => t.category.toLowerCase() == 'neurological' || t.category.toLowerCase() == 'neurodynamic').toList();
    }
    return [];
  }

  // Fetch tests by category (Musculoskeletal, Neurodynamic, Neurological)
  List<SpecialTest> getTestsByCategory(String category) {
    return _allTests.where((t) => t.category.toLowerCase() == category.toLowerCase()).toList();
  }

  // Fetch bookmarked tests
  List<SpecialTest> getBookmarkedTests() {
    return _allTests.where((t) => _bookmarkedIds.contains(t.id)).toList();
  }

  // Toggle Bookmark
  Future<void> toggleBookmark(int id) async {
    await StorageHelper.toggleBookmark(id);
    loadBookmarks();
  }

  bool isBookmarked(int id) {
    return _bookmarkedIds.contains(id);
  }

  // Search tests
  Future<void> search(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResult = [];
    } else {
      final list = await DbHelper.instance.searchTests(query);
      _searchResult = list.map((e) => SpecialTest.fromMap(e)).toList();
    }
    notifyListeners();
  }

  // View test (Record history and reload)
  Future<void> viewTest(int testId) async {
    await DbHelper.instance.addHistory(testId);
    await fetchHistory();
    _loadProgress();
  }

  // Fetch history
  Future<void> fetchHistory() async {
    final list = await DbHelper.instance.fetchHistory();
    _recentHistory = list.map((e) => SpecialTest.fromMap(e)).toList();
    notifyListeners();
  }

  // Clear history
  Future<void> clearHistory() async {
    await DbHelper.instance.clearHistory();
    await fetchHistory();
    _loadProgress();
  }

  // Check progress per region
  double getRegionProgress(String region) {
    final regionTests = getTestsByRegion(region);
    if (regionTests.isEmpty) return 0.0;
    
    final viewedIds = _recentHistory.map((e) => e.id).toSet();
    final completedRegionTests = regionTests.where((t) => viewedIds.contains(t.id)).length;
    
    return (completedRegionTests / regionTests.length) * 100.0;
  }

  // Check progress per anatomical region
  double getAnatomicalRegionProgress(String anatomicalRegion) {
    final regionTests = getTestsByAnatomicalRegion(anatomicalRegion);
    if (regionTests.isEmpty) return 0.0;
    
    final viewedIds = _recentHistory.map((e) => e.id).toSet();
    final completedRegionTests = regionTests.where((t) => viewedIds.contains(t.id)).length;
    
    return (completedRegionTests / regionTests.length) * 100.0;
  }
}
