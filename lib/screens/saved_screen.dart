import 'package:flutter/material.dart';
import '../services/place_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/place_card.dart';
import 'place_details_screen.dart';

class SavedScreen extends StatelessWidget {
  final PlaceRepository repository;
  final VoidCallback? onExplorePlaces;

  const SavedScreen({
    super.key,
    required this.repository,
    this.onExplorePlaces,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final savedPlaces = repository.savedPlaces;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Saved Places'),
            actions: [
              if (savedPlaces.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTealLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${savedPlaces.length} saved',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryTealDark,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: savedPlaces.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryTealLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bookmark_border_rounded,
                            size: 48,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No saved places yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDarkNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bookmark accessible places in the Discover tab to quickly review accessibility reports before traveling.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: onExplorePlaces,
                          icon: const Icon(Icons.explore_outlined, size: 18),
                          label: const Text('Discover Public Places'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: savedPlaces.length,
                  itemBuilder: (context, index) {
                    final place = savedPlaces[index];
                    return PlaceCard(
                      place: place,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaceDetailsScreen(
                              placeId: place.id,
                              repository: repository,
                            ),
                          ),
                        );
                      },
                      onToggleBookmark: () => repository.toggleBookmark(place.id),
                    );
                  },
                ),
        );
      },
    );
  }
}
