class UserProfile {
  final String name;
  final String university;
  final int completedTopicsCount;
  final int totalTopicsCount;
  final List<String> favoriteRegions;
  final List<String> achievements;

  UserProfile({
    required this.name,
    required this.university,
    required this.completedTopicsCount,
    required this.totalTopicsCount,
    required this.favoriteRegions,
    required this.achievements,
  });

  double get progressPercentage {
    if (totalTopicsCount == 0) return 0.0;
    return (completedTopicsCount / totalTopicsCount) * 100.0;
  }
}
