class MovieCategory {
  int id;
  String description;

  MovieCategory({
    required this.id,
    required this.description,
  });

  @override
  String toString() {
    return description;
  }
}
