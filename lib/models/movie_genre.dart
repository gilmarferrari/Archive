class MovieGenre {
  int id;
  String description;

  MovieGenre({
    required this.id,
    required this.description,
  });

  @override
  String toString() {
    return description;
  }
}
