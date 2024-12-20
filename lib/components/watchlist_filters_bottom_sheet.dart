import 'package:flutter/material.dart';
import '../models/movie_category.dart';
import '../models/movie_genre.dart';
import '../services/local_database_service.dart';
import '../view_models/dynamic_record.dart';
import 'custom_button.dart';
import 'custom_multi_select_chip_list.dart';

class WatchlistFiltersBottomSheet extends StatefulWidget {
  final void Function(
    List<int>,
    List<int>,
    List<int>,
    List<bool>,
  ) onConfirm;

  const WatchlistFiltersBottomSheet({
    required this.onConfirm,
  });

  @override
  State<WatchlistFiltersBottomSheet> createState() =>
      _WatchlistFiltersBottomSheetState();
}

class _WatchlistFiltersBottomSheetState
    extends State<WatchlistFiltersBottomSheet> {
  late Future<List<List<dynamic>>> _future;
  late final LocalDatabaseService _localDatabaseService =
      LocalDatabaseService();
  List<MovieCategory> _filteredMovieCategories = [];
  List<MovieGenre> _filteredMovieGenres = [];
  List<DynamicRecord<bool>> _filteredStatus = [];
  List<DynamicRecord<int>> _filteredDecades = [];
  final List<DynamicRecord<bool>> _status = [
    DynamicRecord(description: 'Watched', value: true),
    DynamicRecord(description: 'Unwatched', value: false),
  ];
  final List<DynamicRecord<int>> _decades = [
    for (int i = ((DateTime.now().year ~/ 10) * 10); i >= 1900; i -= 10)
      DynamicRecord(description: '$i', value: i),
  ];

  @override
  void initState() {
    super.initState();
    _future = getData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            List<MovieCategory> movieCategories =
                snapshot.data[0] ?? [].cast<MovieCategory>();
            List<MovieGenre> movieGenres =
                snapshot.data[1] ?? [].cast<MovieGenre>();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: const Text(
                      'Select the filters',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  CustomMultiSelectChipList<MovieCategory>(
                    label: 'Categories',
                    availableItems: movieCategories,
                    initiallySelectedItems: _filteredMovieCategories,
                    onSelect: (List<MovieCategory> selectedMovieCategories) {
                      setState(() {
                        _filteredMovieCategories = selectedMovieCategories;
                      });
                    },
                  ),
                  CustomMultiSelectChipList<MovieGenre>(
                    label: 'Genres',
                    availableItems: movieGenres,
                    initiallySelectedItems: _filteredMovieGenres,
                    onSelect: (List<MovieGenre> selectedMovieGenres) {
                      setState(() {
                        _filteredMovieGenres = selectedMovieGenres;
                      });
                    },
                  ),
                  CustomMultiSelectChipList<DynamicRecord<int>>(
                    label: 'Decades',
                    availableItems: _decades,
                    initiallySelectedItems: _filteredDecades,
                    onSelect: (List<DynamicRecord<int>> decades) {
                      setState(() => _filteredDecades = decades);
                    },
                  ),
                  CustomMultiSelectChipList<DynamicRecord<bool>>(
                    label: 'Status',
                    availableItems: _status,
                    initiallySelectedItems: _filteredStatus,
                    onSelect: (List<DynamicRecord<bool>> status) {
                      setState(() => _filteredStatus = status);
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: CustomButton(
                      label: 'Apply',
                      onSubmit: () {
                        Navigator.pop(context);

                        widget.onConfirm(
                          _filteredMovieCategories.map((c) => c.id).toList(),
                          _filteredMovieGenres.map((g) => g.id).toList(),
                          _filteredDecades.map((s) => s.value).toList(),
                          _filteredStatus.map((s) => s.value).toList(),
                        );
                      },
                      height: 15,
                    ),
                  ),
                ]),
              ),
            );
          } else {
            return const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }

  Future<List<List<dynamic>>> getData() async {
    return [
      await _localDatabaseService.getMovieCategories(),
      await _localDatabaseService.getMovieGenres(),
    ];
  }
}
