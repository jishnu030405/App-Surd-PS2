import 'package:flutter/material.dart';

import '../models/place.dart';
import '../models/filter_criteria.dart';
import '../services/place_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/place_card.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/map_preview_widget.dart';
import 'place_details_screen.dart';

class DiscoverScreen extends StatefulWidget {
  final PlaceRepository repository;
  final ValueChanged<String>? onNavigateToFeedbackForPlace;

  const DiscoverScreen({
    super.key,
    required this.repository,
    this.onNavigateToFeedbackForPlace,
  });

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late TextEditingController _searchController;
  FilterCriteria _criteria = const FilterCriteria();
  bool _isMapView = false;

  final List<String> _categories = [
    'All',
    'Hospitals',
    'Colleges',
    'Shopping',
    'Transport',
    'Public Offices',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _criteria = _criteria.copyWith(selectedCategory: category);
    });
  }

  void _openFilterSheet() {
    FilterSheet.show(
      context,
      currentCriteria: _criteria,
      onApply: (newCriteria) {
        setState(() {
          _criteria = newCriteria;
        });
      },
    );
  }

  void _openPlaceDetails(Place place) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceDetailsScreen(
          placeId: place.id,
          repository: widget.repository,
          onAddFeedback: widget.onNavigateToFeedbackForPlace,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        if (widget.repository.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryTeal),
            ),
          );
        }

        final allPlaces = widget.repository.places;
        final filteredPlaces = _criteria.applyAndSort(allPlaces);

        return Scaffold(
          appBar: _buildAppBar(),
          body: Column(
            children: [
              // Search & Filter Bar
              _buildSearchAndFilterBar(),

              // Category Filter Horizontal Chips
              _buildCategoryChips(),

              // Active Filters Summary & View Toggle Bar
              _buildActiveFiltersBar(filteredPlaces.length, allPlaces.length),

              // Content Body (List or Map)
              Expanded(
                child: _isMapView
                    ? MapPreviewWidget(
                        places: filteredPlaces,
                        onSelectPlace: _openPlaceDetails,
                      )
                    : _buildPlacesList(filteredPlaces),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.accessible_forward_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'AccessPath',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDarkNavy,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Every place. More accessible.',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Map / List View Toggle Button
        IconButton(
          tooltip: _isMapView ? 'Switch to list view' : 'Switch to map view',
          icon: Icon(
            _isMapView
                ? Icons.format_list_bulleted_rounded
                : Icons.map_outlined,
            color: AppTheme.primaryTeal,
          ),
          onPressed: () {
            setState(() {
              _isMapView = !_isMapView;
            });
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // Search Input Field
          Expanded(
            child: Semantics(
              label:
                  'Search public places, hospitals, colleges, malls, transit',
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _criteria = _criteria.copyWith(searchQuery: val);
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search hospitals, colleges, malls...',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.textMuted,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _criteria = _criteria.copyWith(searchQuery: '');
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.borderLight),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Prominent Accessibility Filter Button with badge
          Semantics(
            label:
                'Open accessibility needs filter panel. ${_criteria.activeFiltersCount} filters currently active.',
            button: true,
            child: Stack(
              children: [
                Material(
                  color: _criteria.hasActiveRequirements
                      ? AppTheme.primaryTeal
                      : AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: _openFilterSheet,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _criteria.hasActiveRequirements
                              ? AppTheme.primaryTeal
                              : AppTheme.borderLight,
                          width: 1.2,
                        ),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: _criteria.hasActiveRequirements
                            ? Colors.white
                            : AppTheme.textDarkNavy,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                if (_criteria.activeFiltersCount > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.statusAmber,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          '${_criteria.activeFiltersCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _criteria.selectedCategory == cat;

          return ChoiceChip(
            label: Text(cat),
            selected: isSelected,
            selectedColor: AppTheme.primaryTealLight,
            backgroundColor: AppTheme.surfaceWhite,
            side: BorderSide(
              color: isSelected ? AppTheme.primaryTeal : AppTheme.borderLight,
              width: 1.2,
            ),
            labelStyle: TextStyle(
              color: isSelected
                  ? AppTheme.primaryTealDark
                  : AppTheme.textDarkNavy,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            onSelected: (_) => _onCategorySelected(cat),
          );
        },
      ),
    );
  }

  Widget _buildActiveFiltersBar(int count, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          Text(
            'Showing $count places',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDarkNavy,
            ),
          ),
          if (_criteria.activeFiltersCount > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryTealLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${_criteria.activeFiltersCount} active filters',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryTealDark,
                ),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                setState(() {
                  _criteria = FilterCriteria(
                    searchQuery: _criteria.searchQuery,
                    selectedCategory: 'All',
                  );
                });
              },
              child: const Text(
                'Reset filters',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryBlue,
                ),
              ),
            ),
          ] else ...[
            const Spacer(),
            Text(
              'Sorted by ${_criteria.sortOption.label}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlacesList(List<Place> places) {
    if (places.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceSubtle,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No matching places found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDarkNavy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try adjusting your search query or loosening accessibility facility requirements.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _criteria = const FilterCriteria();
                  });
                },
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reset All Filters'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return PlaceCard(
          place: place,
          onTap: () => _openPlaceDetails(place),
          onToggleBookmark: () => widget.repository.toggleBookmark(place.id),
        );
      },
    );
  }
}
