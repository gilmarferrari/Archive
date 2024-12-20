class SQLTable {
  String name;
  late String description;
  bool isSelected = true;
  List<Map<String, dynamic>>? data;

  SQLTable({
    required this.name,
    this.data,
  }) {
    description = getDescription();
  }

  getDescription() {
    switch (name) {
      case 'Accounts':
        return 'Accounts';
      case 'Notes':
        return 'Notes';
      case 'MovieGenres':
        return 'Movie Genres';
      case 'MovieCategories':
        return 'Movie Categories';
      case 'Watchlists':
        return 'Watchlists';
      case 'WatchlistsMovieGenres':
        return 'Watchlists Movie Genres';
      default:
        return name;
    }
  }

  @override
  String toString() {
    return name;
  }
}
