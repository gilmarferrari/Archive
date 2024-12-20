import 'movie_category.dart';
import 'movie_genre.dart';

class Movie {
  int id;
  String title;
  int year;
  MovieCategory category;
  List<MovieGenre> genres;
  bool watched;

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.category,
    required this.genres,
    required this.watched,
  });

  static Movie create({
    required String title,
    required int year,
    required MovieCategory category,
    required List<MovieGenre> genres,
    required bool watched,
  }) {
    return Movie(
      id: 0,
      title: title,
      year: year,
      category: category,
      genres: genres,
      watched: watched,
    );
  }

  update({
    required String title,
    required int year,
    required MovieCategory category,
    required List<MovieGenre> genres,
    required bool watched,
  }) {
    this.title = title;
    this.year = year;
    this.category = category;
    this.genres = genres;
    this.watched = watched;
  }

  @override
  String toString() {
    return title;
  }
}
