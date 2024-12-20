import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../components/custom_dialog.dart';
import '../components/custom_search_field.dart';
import '../components/loading_container.dart';
import '../components/note_card.dart';
import '../models/note.dart';
import '../services/local_database_service.dart';
import '../utils/app_constants.dart';
import 'note_details_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage();

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late Future<List<Note>> _future;
  late final LocalDatabaseService _localDatabaseService =
      LocalDatabaseService();
  bool _archived = false;
  bool _isLoading = false;
  bool _isSearchMode = false;
  String? _searchTerm;

  @override
  void initState() {
    super.initState();
    _future = getNotes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && !_isLoading) {
            List<Note> notes = snapshot.data ?? [].cast<Note>();

            notes = notes
                .where((a) =>
                    (_searchTerm == null ||
                        a.title.toLowerCase().contains(_searchTerm!)) ||
                    (a.tags?.toLowerCase().contains(_searchTerm!) ?? false))
                .toList();

            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                  title: _isSearchMode
                      ? CustomSearchField(
                          initialText: _searchTerm,
                          onChanged: (String searchTerm) {
                            setState(() {
                              _searchTerm = searchTerm.toLowerCase();
                            });
                          })
                      : Text(
                          _archived ? 'Archived Notes' : 'Notes',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _archived = !_archived;
                          _isLoading = true;
                        });

                        _future = getNotes();

                        setState(() => _isLoading = false);
                      },
                      splashRadius: 20,
                      icon: Icon(
                        _archived ? Icons.archive : Icons.bookmark,
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
                onPressed: () => addNote(context),
                child: const Icon(Icons.add, color: Colors.white),
              ),
              body: SizedBox(
                width: double.infinity,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    childAspectRatio: 4 / 5,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: notes.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    var note = notes[index];

                    return NoteCard(
                      note: note,
                      onEdit: () => editNote(context, note),
                      onArchive: () => archiveNote(note),
                      onRestore: () => restoreNote(note),
                      onDelete: () => deleteNote(context, note),
                    );
                  },
                ),
              ),
            );
          } else {
            return const LoadingContainer();
          }
        });
  }

  Future<List<Note>> getNotes() async {
    return await _localDatabaseService.getNotes(archived: _archived);
  }

  addNote(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NoteDetailsPage(onConfirm: (Note note) async {
          setState(() => _isLoading = true);

          var successful = await _localDatabaseService.createNote(note: note);

          if (successful) {
            _future = getNotes();
            Fluttertoast.showToast(msg: 'Note created');
          }

          setState(() => _isLoading = false);
        }),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  editNote(BuildContext context, Note note) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            NoteDetailsPage(
                note: note,
                onConfirm: (Note editedNote) async {
                  setState(() => _isLoading = true);

                  var successful = await _localDatabaseService.updateNote(
                    note: editedNote,
                  );

                  if (successful) {
                    _future = getNotes();
                    Fluttertoast.showToast(msg: 'Note updated');
                  }

                  setState(() => _isLoading = false);
                }),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero);
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  archiveNote(Note note) async {
    setState(() => _isLoading = true);

    var successful = await _localDatabaseService.archiveNote(id: note.id);

    if (successful) {
      _future = getNotes();
      Fluttertoast.showToast(msg: 'Note archived');
    }

    setState(() => _isLoading = false);
  }

  restoreNote(Note note) async {
    setState(() => _isLoading = true);

    var successful = await _localDatabaseService.restoreNote(id: note.id);

    if (successful) {
      _future = getNotes();
      Fluttertoast.showToast(msg: 'Note restored');
    }

    setState(() => _isLoading = false);
  }

  deleteNote(BuildContext context, Note note) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
              title:
                  'Are you sure you want to delete the note named "${note.title}"?',
              description: 'Keep in mind that this action is irreversible.',
              onConfirm: () async {
                setState(() => _isLoading = true);

                var successful =
                    await _localDatabaseService.deleteNote(id: note.id);

                if (successful) {
                  _future = getNotes();
                  Fluttertoast.showToast(msg: 'Note deleted');
                }

                setState(() => _isLoading = false);
              });
        });
  }
}
