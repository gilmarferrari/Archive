import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/movie_category.dart';
import '../models/movie_genre.dart';
import '../services/local_database_service.dart';
import 'custom_button.dart';
import 'custom_checkbox.dart';
import 'custom_chip_list.dart';
import 'custom_form_field.dart';
import 'custom_multi_select_chip_list.dart';

class EditMovieBottomSheet extends StatefulWidget {
  final Movie? movie;
  final void Function(Movie) onConfirm;

  const EditMovieBottomSheet({
    required this.onConfirm,
    this.movie,
  });

  @override
  State<EditMovieBottomSheet> createState() => _EditMovieBottomSheetState();
}

class _EditMovieBottomSheetState extends State<EditMovieBottomSheet> {
  late Future<List<List<dynamic>>> _future;
  late final LocalDatabaseService _localDatabaseService =
      LocalDatabaseService();
  late final TextEditingController _titleController = TextEditingController(
    text: widget.movie?.title,
  );
  late final TextEditingController _yearController = TextEditingController(
    text: widget.movie?.year.toString(),
  );
  late MovieCategory? _movieCategory = widget.movie?.category;
  late List<MovieGenre> _movieGenres = widget.movie?.genres ?? [];
  late bool _watched = widget.movie?.watched ?? false;

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
                  CustomFormField(
                    label: 'Title',
                    controller: _titleController,
                    displayFloatingLabel: true,
                    icon: Icons.edit_note,
                  ),
                  CustomFormField(
                    label: 'Release year',
                    controller: _yearController,
                    displayFloatingLabel: true,
                    keyboardType: TextInputType.number,
                    icon: Icons.calendar_month,
                  ),
                  CustomChipList<MovieCategory>(
                    label: 'Category',
                    items: movieCategories,
                    initiallySelectedItem: movieCategories
                        .where((c) => _movieCategory?.id == c.id)
                        .firstOrNull,
                    onSelect: (movieCategory) async {
                      setState(() => _movieCategory = movieCategory);
                    },
                  ),
                  IntrinsicHeight(
                    child: CustomMultiSelectChipList<MovieGenre>(
                      label: 'Genres',
                      availableItems: movieGenres,
                      initiallySelectedItems: movieGenres
                          .where((g) =>
                              _movieGenres.map((x) => x.id).contains(g.id))
                          .toList(),
                      onSelect: (selectedItems) async {
                        setState(() => _movieGenres = selectedItems.toList());
                      },
                    ),
                  ),
                  CustomCheckbox(
                    label: 'Watched',
                    checked: _watched,
                    onChecked: (bool? checked) {
                      setState(
                        () => _watched = (checked ?? false),
                      );
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: CustomButton(
                      label: 'Save',
                      onSubmit: () => save(context),
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

  save(BuildContext context) {
    var title = _titleController.value.text;
    var year = int.tryParse(_yearController.value.text);

    if (title.isEmpty ||
        year == null ||
        _movieCategory == null ||
        _movieGenres.isEmpty) {
      return;
    }

    Navigator.pop(context);

    if (widget.movie != null) {
      var editedAccount = widget.movie!
        ..update(
          title: title,
          year: year,
          category: _movieCategory!,
          genres: _movieGenres,
          watched: _watched,
        );

      widget.onConfirm(editedAccount);
    } else {
      widget.onConfirm(
        Movie.create(
          title: title,
          year: year,
          category: _movieCategory!,
          genres: _movieGenres,
          watched: _watched,
        ),
      );
    }
  }
}
