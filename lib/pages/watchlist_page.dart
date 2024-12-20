import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../components/custom_card.dart';
import '../components/custom_dialog.dart';
import '../components/custom_search_field.dart';
import '../components/edit_movie_bottom_sheet.dart';
import '../components/loading_container.dart';
import '../components/watchlist_filters_bottom_sheet.dart';
import '../models/movie.dart';
import '../services/local_database_service.dart';
import '../utils/app_constants.dart';
import '../view_models/bottom_sheet_action.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage();

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  late Future<List<Movie>> _future;
  late final LocalDatabaseService _localDatabaseService =
      LocalDatabaseService();
  bool _isLoading = false;
  bool _isSearchMode = false;
  String? _searchTerm;

  @override
  void initState() {
    super.initState();
    _future = getWatchlist();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting &&
              !_isLoading) {
            List<Movie> movies = snapshot.data ?? [].cast<Movie>();

            movies = movies
                .where((a) =>
                    (_searchTerm == null ||
                        a.title.toLowerCase().contains(_searchTerm!)) ||
                    a.title.toLowerCase().contains(_searchTerm!))
                .toList();

            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                  title: _isSearchMode
                      ? CustomSearchField(
                          initialText: _searchTerm,
                          onChanged: (String searchTerm) {
                            setState(
                                () => _searchTerm = searchTerm.toLowerCase());
                          })
                      : const Text(
                          'Watchlist',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                  actions: [
                    IconButton(
                      constraints: const BoxConstraints(
                        maxWidth: 40,
                        maxHeight: 40,
                      ),
                      onPressed: () => showFilters(context),
                      splashRadius: 20,
                      icon: const Icon(
                        Icons.filter_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => _isSearchMode = !_isSearchMode);

                        if (!_isSearchMode) {
                          setState(() => _searchTerm = null);
                        }
                      },
                      splashRadius: 20,
                      icon: Icon(
                        _isSearchMode ? Icons.close : Icons.search,
                        size: 20,
                        color: Colors.white,
                      ),
                    )
                  ]),
              floatingActionButton: FloatingActionButton(
                backgroundColor: AppConstants.primaryColor,
                onPressed: () => addMovie(context),
                child: const Icon(Icons.add, color: Colors.white),
              ),
              body: Column(
                children: [
                  Flexible(
                    child: ListView.builder(
                        key: PageStorageKey(widget.key),
                        itemCount: movies.length,
                        itemBuilder: (ctx, index) {
                          var movie = movies[index];

                          return CustomCard(
                              label: movie.title,
                              description:
                                  '${movie.category.description} (${movie.year})',
                              icon: Icons.movie,
                              iconColor: Colors.deepOrange,
                              onTap: () => editMovie(context, movie),
                              options: [
                                BottomSheetAction(
                                  label: 'Edit',
                                  icon: Icons.edit,
                                  onPressed: () => editMovie(context, movie),
                                ),
                                BottomSheetAction(
                                  label: 'Delete',
                                  icon: Icons.delete,
                                  onPressed: () => deleteMovie(context, movie),
                                ),
                              ]);
                        }),
                  ),
                ],
              ),
            );
          } else {
            return const LoadingContainer();
          }
        });
  }

  Future<List<Movie>> getWatchlist({
    List<int> filteredMovieCategories = const [],
    List<int> filteredMovieGenres = const [],
    List<int> filteredDecades = const [],
    List<bool> filteredStatus = const [],
  }) async {
    return await _localDatabaseService.getWatchlist(
      filteredMovieCategories: filteredMovieCategories,
      filteredMovieGenres: filteredMovieGenres,
      filteredDecades: filteredDecades,
      filteredStatus: filteredStatus,
    );
  }

  showFilters(BuildContext context) {
    var size = MediaQuery.of(context).size;

    showModalBottomSheet(
        showDragHandle: true,
        isScrollControlled: true,
        constraints: BoxConstraints.tightFor(width: size.width - 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        context: context,
        builder: (builder) {
          return WatchlistFiltersBottomSheet(
            onConfirm: (
              List<int> selectedMovieCategories,
              List<int> selectedMovieGenres,
              List<int> selectedDecades,
              List<bool> selectedStatus,
            ) {
              setState(() => _isLoading = true);

              _future = getWatchlist(
                filteredMovieCategories: selectedMovieCategories,
                filteredMovieGenres: selectedMovieGenres,
                filteredDecades: selectedDecades,
                filteredStatus: selectedStatus,
              );

              setState(() => _isLoading = false);
            },
          );
        });
  }

  addMovie(BuildContext context) {
    var size = MediaQuery.of(context).size;

    showModalBottomSheet(
        showDragHandle: true,
        isScrollControlled: true,
        constraints: BoxConstraints.tightFor(width: size.width - 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        context: context,
        builder: (builder) {
          return EditMovieBottomSheet(onConfirm: (Movie movie) async {
            setState(() => _isLoading = true);

            var successful = await _localDatabaseService.createMovie(
              movie: movie,
            );

            if (successful) {
              _future = getWatchlist();
              Fluttertoast.showToast(msg: '${movie.category.description} created');
            }

            setState(() => _isLoading = false);
          });
        });
  }

  editMovie(BuildContext context, Movie movie) {
    var size = MediaQuery.of(context).size;

    showModalBottomSheet(
        showDragHandle: true,
        isScrollControlled: true,
        constraints: BoxConstraints.tightFor(width: size.width - 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        context: context,
        builder: (builder) {
          return EditMovieBottomSheet(
              movie: movie,
              onConfirm: (Movie editedMovie) async {
                setState(() => _isLoading = true);

                var successful = await _localDatabaseService.updateMovie(
                  movie: editedMovie,
                );

                if (successful) {
                  _future = getWatchlist();
                  Fluttertoast.showToast(msg: '${movie.category.description} updated');
                }

                setState(() => _isLoading = false);
              });
        });
  }

  deleteMovie(BuildContext context, Movie movie) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
              title:
                  'Are you sure you want to delete the ${movie.category.description} named "${movie.title}"?',
              description: 'Keep in mind that this action is irreversible.',
              onConfirm: () async {
                setState(() => _isLoading = true);

                var successful =
                    await _localDatabaseService.deleteMovie(id: movie.id);

                if (successful) {
                  _future = getWatchlist();
                  Fluttertoast.showToast(msg: '${movie.category.description} deleted');
                }

                setState(() => _isLoading = false);
              });
        });
  }
}
