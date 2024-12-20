import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/account.dart';
import '../models/movie.dart';
import '../models/movie_category.dart';
import '../models/movie_genre.dart';
import '../models/note.dart';
import '../view_models/sql_table.dart';

class LocalDatabaseService {
  Future<Database> _startConnection() async {
    var databasePath = await getDatabasesPath();

    var context = await openDatabase('${databasePath}archive.db', version: 1,
        onCreate: (db, version) async {
      switch (version) {
        case 1:
          await db.execute('PRAGMA foreign_keys = ON');

          await db.execute('''CREATE TABLE IF NOT EXISTS Accounts
            (ID INTEGER PRIMARY KEY, Title TEXT NOT NULL,
            Login TEXT NOT NULL, Password TEXT NOT NULL);''');

          await db.execute('''CREATE TABLE IF NOT EXISTS Notes
            (ID INTEGER PRIMARY KEY, Title TEXT NOT NULL,
            Description TEXT NOT NULL, Tags TEXT, CreatedAt TEXT NOT NULL,
            LastUpdatedAt TEXT, IsArchived INTEGER NOT NULL);''');

          await db.execute('''CREATE TABLE IF NOT EXISTS MovieGenres
            (ID INTEGER PRIMARY KEY, Description TEXT NOT NULL);''');

          await db.execute('''CREATE TABLE IF NOT EXISTS MovieCategories
            (ID INTEGER PRIMARY KEY, Description TEXT NOT NULL);''');

          await db.execute('''CREATE TABLE IF NOT EXISTS Watchlist
            (ID INTEGER PRIMARY KEY, Title TEXT NOT NULL, Year INTEGER NOT NULL,
            MovieCategoryID INTEGER NOT NULL, Watched INTEGER NOT NULL,
            FOREIGN KEY (MovieCategoryID) REFERENCES MovieCategories(ID));''');

          await db.execute('''CREATE TABLE IF NOT EXISTS WatchlistMovieGenres
            (MovieID INTEGER, MovieGenreID INTEGER,
            PRIMARY KEY (MovieID, MovieGenreID),
            FOREIGN KEY (MovieID) REFERENCES Watchlist(ID),
            FOREIGN KEY (MovieGenreID) REFERENCES MovieGenres(ID));''');

          await db.execute('''
            INSERT INTO MovieCategories (Description)
            VALUES
              ('Documentary'),
              ('Movie'),
              ('Play'),
              ('TV Show')
            ''');

          await db.execute('''
            INSERT INTO MovieGenres (Description)
            VALUES
              ('Action'),
              ('Adventure'),
              ('Animation'),
              ('Biography'),
              ('Comedy'),
              ('Crime'),
              ('Drama'),
              ('Fantasy'),
              ('Historical'),
              ('Horror'),
              ('Musical'),
              ('Mystery'),
              ('Romance'),
              ('Sci-Fi'),
              ('Thriller'),
              ('War'),
              ('Western')
            ''');
      }
    });

    return context;
  }

  Future<void> _closeConnection(Database context) async {
    await context.close();
  }

  Future<List<Account>> getAccounts() async {
    var context = await _startConnection();

    var accounts = await context.rawQuery('SELECT * FROM Accounts');

    await _closeConnection(context);

    return accounts
        .map((Map<String, dynamic> a) => Account(
              id: a['ID'],
              title: a['Title'],
              login: a['Login'],
              password: a['Password'],
            ))
        .toList();
  }

  Future<bool> createAccount({required Account account}) async {
    var context = await _startConnection();

    try {
      await context.rawInsert(
          'INSERT INTO Accounts (Title, Login, Password) VALUES (?, ?, ?)',
          [account.title, account.login, account.password]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> updateAccount({required Account account}) async {
    var context = await _startConnection();

    try {
      await context.rawUpdate(
          'UPDATE Accounts SET Title = ?, Login = ?, Password = ? WHERE ID = ?',
          [account.title, account.login, account.password, account.id]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> deleteAccount({required int id}) async {
    var context = await _startConnection();

    try {
      await context.rawDelete('DELETE FROM Accounts WHERE ID = ?', [id]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<List<Note>> getNotes({required bool archived}) async {
    var context = await _startConnection();

    var notes = await context
        .rawQuery('SELECT * FROM Notes WHERE IsArchived = $archived');

    await _closeConnection(context);

    return notes
        .map((Map<String, dynamic> n) => Note(
            id: n['ID'],
            title: n['Title'],
            description: n['Description'],
            tags: n['Tags'],
            createdAt: DateTime.parse(n['CreatedAt']),
            lastUpdatedAt: n['LastUpdatedAt'] != null
                ? DateTime.parse(n['LastUpdatedAt'])
                : null,
            isArchived: n['IsArchived'] == 1))
        .toList();
  }

  Future<bool> createNote({required Note note}) async {
    var context = await _startConnection();

    try {
      await context.rawInsert(
          'INSERT INTO Notes (Title, Description, Tags, CreatedAt, IsArchived) VALUES (?, ?, ?, ?, ?)',
          [
            note.title,
            note.description,
            note.tags,
            note.createdAt.toIso8601String(),
            note.isArchived,
          ]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> updateNote({required Note note}) async {
    var context = await _startConnection();

    try {
      await context.rawUpdate(
          'UPDATE Notes SET Title = ?, Description = ?, Tags = ?, LastUpdatedAt = ? WHERE ID = ?',
          [
            note.title,
            note.description,
            note.tags,
            DateTime.now().toIso8601String(),
            note.id
          ]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> archiveNote({required int id}) async {
    var context = await _startConnection();

    try {
      await context.rawUpdate(
        'UPDATE Notes SET IsArchived = 1 WHERE ID = ?',
        [id],
      );
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> restoreNote({required int id}) async {
    var context = await _startConnection();

    try {
      await context.rawUpdate(
        'UPDATE Notes SET IsArchived = 0 WHERE ID = ?',
        [id],
      );
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> deleteNote({required int id}) async {
    var context = await _startConnection();

    try {
      await context.rawDelete('DELETE FROM Notes WHERE ID = ?', [id]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<List<MovieCategory>> getMovieCategories() async {
    var context = await _startConnection();

    var movieCategories =
        await context.rawQuery('SELECT * FROM MovieCategories');

    await _closeConnection(context);

    return movieCategories
        .map((Map<String, dynamic> c) => MovieCategory(
              id: c['ID'],
              description: c['Description'],
            ))
        .toList();
  }

  Future<List<MovieGenre>> getMovieGenres() async {
    var context = await _startConnection();

    var movieGenres = await context.rawQuery('SELECT * FROM MovieGenres');

    await _closeConnection(context);

    return movieGenres
        .map((Map<String, dynamic> g) => MovieGenre(
              id: g['ID'],
              description: g['Description'],
            ))
        .toList();
  }

  Future<List<Movie>> getWatchlist({
    required List<int> filteredMovieCategories,
    required List<int> filteredMovieGenres,
    required List<int> filteredDecades,
    required List<bool> filteredStatus,
  }) async {
    var context = await _startConnection();

    var watchlistMovieGenres = await context.rawQuery(
      '''SELECT * FROM WatchlistMovieGenres WHERE MovieGenreID IN (${(filteredMovieGenres.isNotEmpty ? filteredMovieGenres.join(',') : 'MovieGenreID')})''',
    );

    var movies = await context.rawQuery(
      '''SELECT * FROM Watchlist WHERE ID IN (${watchlistMovieGenres.map((g) => g['MovieID']).join(',')})
        AND MovieCategoryID IN (${(filteredMovieCategories.isNotEmpty ? filteredMovieCategories.join(',') : 'MovieCategoryID')})
        AND (CAST(Year / 10 AS INTEGER) * 10) IN (${(filteredDecades.isNotEmpty ? filteredDecades.join(',') : '(CAST(Year / 10 AS INTEGER) * 10)')})
        AND Watched IN (${(filteredStatus.isNotEmpty ? filteredStatus.join(',') : 'Watched')})''',
    );

    await _closeConnection(context);

    var movieCategories = await getMovieCategories();
    var movieGenres = await getMovieGenres();

    return movies
        .map((Map<String, dynamic> m) => Movie(
              id: m['ID'],
              title: m['Title'],
              year: m['Year'],
              genres: movieGenres
                  .where((g) => watchlistMovieGenres
                      .where((x) => x['MovieID'] == m['ID'])
                      .map((x) => x['MovieGenreID'])
                      .contains(g.id))
                  .toList(),
              category: movieCategories
                  .firstWhere((c) => c.id == m['MovieCategoryID']),
              watched: m['Watched'] == 1,
            ))
        .where((m) => filteredMovieGenres
            .every((g) => m.genres.map((x) => x.id).contains(g)))
        .toList();
  }

  Future<bool> createMovie({required Movie movie}) async {
    var context = await _startConnection();

    try {
      var id = await context.rawInsert(
          'INSERT INTO Watchlist (Title, Year, MovieCategoryID, Watched) VALUES (?, ?, ?, ?)',
          [movie.title, movie.year, movie.category.id, movie.watched]);

      for (var genre in movie.genres) {
        await context.rawInsert(
            'INSERT INTO WatchlistMovieGenres (MovieID, MovieGenreID) VALUES (?, ?)',
            [id, genre.id]);
      }
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> updateMovie({required Movie movie}) async {
    var context = await _startConnection();

    try {
      await context.rawUpdate(
          'UPDATE Watchlist SET Title = ?, Year = ?, MovieCategoryID = ?, Watched = ? WHERE ID = ?',
          [
            movie.title,
            movie.year,
            movie.category.id,
            movie.watched,
            movie.id
          ]);

      await context.rawDelete(
          'DELETE FROM WatchlistMovieGenres WHERE MovieID = ?', [movie.id]);

      for (var genre in movie.genres) {
        await context.rawInsert(
            'INSERT INTO WatchlistMovieGenres (MovieID, MovieGenreID) VALUES (?, ?)',
            [movie.id, genre.id]);
      }
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> deleteMovie({required int id}) async {
    var context = await _startConnection();

    try {
      await context.rawDelete('DELETE FROM Watchlist WHERE ID = ?', [id]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<List<SQLTable>> getTables() async {
    var context = await _startConnection();

    List<Map<String, dynamic>> tables = await context.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE '%metadata'",
    );

    _closeConnection(context);

    List<SQLTable> tableNames =
        tables.map((t) => SQLTable(name: t['name'])).toList();

    return tableNames;
  }

  Future<List<SQLTable>> getFileTables() async {
    var directory = await getTemporaryDirectory();

    await directory.delete(recursive: true);

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    List<SQLTable> tableNames = [];

    if (result != null && result.files.single.path != null) {
      try {
        var json = await File(result.files.single.path!).readAsString();

        Map<String, dynamic> data = jsonDecode(json);

        tableNames = data.entries
            .map((e) => SQLTable(
                  name: e.key,
                  data: List<Map<String, dynamic>>.from(e.value ?? []),
                ))
            .toList();
      } catch (_) {
        return [];
      }
    }

    return tableNames;
  }

  Future<int> exportData(List<SQLTable> tables) async {
    var context = await _startConnection();
    Map<String, List<Map<String, dynamic>>> data = {};

    for (var table in tables) {
      try {
        var tableRecords =
            await context.rawQuery('SELECT * FROM ${table.name}');
        data.addAll({table.name: tableRecords});
      } catch (_) {
        continue;
      }
    }

    await _closeConnection(context);

    try {
      var directoryPath = await FilePicker.platform.getDirectoryPath();

      if (directoryPath == null) {
        return -1;
      }

      String path = '$directoryPath/archive-data.json';

      File file = File(path);
      await file.writeAsString(jsonEncode(data));

      return data.length;
    } catch (_) {
      return -1;
    }
  }

  Future<int> importData(List<SQLTable> tables) async {
    var context = await _startConnection();
    int importedRecords = 0;

    for (var table in tables) {
      try {
        if (table.data != null && table.data!.isNotEmpty) {
          await context.transaction((txn) async {
            for (var record in table.data!) {
              for (var column in record.keys) {
                var id = record['ID'];

                if (column != 'ID') {
                  var updatedRows = await txn.rawUpdate(
                    'UPDATE ${table.name} SET $column = ? WHERE ID = ?',
                    [record[column], id],
                  );

                  if (updatedRows == 0) {
                    await txn.insert(table.name, record);
                  }

                  importedRecords++;
                }
              }
            }
          });
        }
      } catch (_) {
        continue;
      }
    }

    await _closeConnection(context);

    return importedRecords;
  }
}
