import 'package:flutter/material.dart';
import '../services/place_repository.dart';
import '../theme/app_theme.dart';
import 'discover_screen.dart';
import 'saved_screen.dart';
import 'feedback_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  final PlaceRepository repository;

  const MainShell({super.key, required this.repository});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  String? _preselectedFeedbackPlaceId;

  void _navigateToFeedbackForPlace(String placeId) {
    setState(() {
      _preselectedFeedbackPlaceId = placeId;
      _currentIndex = 2; // Switch to Add Review tab
    });
  }

  void _switchTab(int index) {
    setState(() {
      if (index != 2) {
        _preselectedFeedbackPlaceId = null;
      }
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DiscoverScreen(
        repository: widget.repository,
        onNavigateToFeedbackForPlace: _navigateToFeedbackForPlace,
      ),
      SavedScreen(
        repository: widget.repository,
        onExplorePlaces: () => _switchTab(0),
      ),
      FeedbackScreen(
        key: ValueKey(_preselectedFeedbackPlaceId ?? 'feedback_default'),
        repository: widget.repository,
        initialPlaceId: _preselectedFeedbackPlaceId,
      ),
      ProfileScreen(
        repository: widget.repository,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.borderLight, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _switchTab,
          selectedItemColor: AppTheme.primaryTeal,
          unselectedItemColor: AppTheme.textMuted,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore_rounded),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline_rounded),
              activeIcon: Icon(Icons.bookmark_rounded),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.rate_review_outlined),
              activeIcon: Icon(Icons.rate_review_rounded),
              label: 'Add Review',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
