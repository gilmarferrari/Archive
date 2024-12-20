import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import 'accounts_page.dart';
import 'data_page.dart';
import 'notes_page.dart';
import 'watchlist_page.dart';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavigationBar(
          onTap: (int index) => onTap(index),
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Colors.black87,
          selectedItemColor: AppConstants.primaryColor,
          currentIndex: _currentPageIndex,
          showUnselectedLabels: false,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Notes',
              tooltip: 'Notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              activeIcon: Icon(Icons.account_circle),
              label: 'Accounts',
              tooltip: 'Accounts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library_outlined),
              activeIcon: Icon(Icons.video_library),
              label: 'Watchlist',
              tooltip: 'Watchlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.import_export),
              activeIcon: Icon(Icons.import_export),
              label: 'Data',
              tooltip: 'Data',
            ),
          ]),
      body: [
        const NotesPage(),
        const AccountsPage(),
        const WatchlistPage(),
        const DataPage(),
      ][_currentPageIndex],
    );
  }

  void onTap(int index) {
    setState(() => _currentPageIndex = index);
  }
}
