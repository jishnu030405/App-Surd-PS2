import 'package:flutter/material.dart';
import '../models/filter_criteria.dart';
import '../theme/app_theme.dart';

class FilterSheet extends StatefulWidget {
  final FilterCriteria initialCriteria;
  final ValueChanged<FilterCriteria> onApply;

  const FilterSheet({
    super.key,
    required this.initialCriteria,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required FilterCriteria currentCriteria,
    required ValueChanged<FilterCriteria> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterSheet(
        initialCriteria: currentCriteria,
        onApply: onApply,
      ),
    );
  }

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late FilterCriteria _criteria;

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
    _criteria = widget.initialCriteria;
  }

  void _reset() {
    setState(() {
      _criteria = FilterCriteria(
        searchQuery: _criteria.searchQuery, // keep search query
        selectedCategory: 'All',
        stepFreeRequired: false,
        workingLiftRequired: false,
        accessibleWashroomRequired: false,
        seatingRequired: false,
        clearWayfindingRequired: false,
        onlyConfirmedAccessible: false,
        sortOption: SortOption.highestScore,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.tune_rounded, color: AppTheme.primaryTeal),
                const SizedBox(width: 8),
                const Text(
                  'Accessibility Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDarkNavy,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _reset,
                  child: const Text('Reset All'),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderLight),

          // Scrollable Filter Options
          Flexible(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // 1. Category Selection
                const Text(
                  'Place Category',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDarkNavy,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = _criteria.selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryTealLight,
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.primaryTealDark : AppTheme.textDarkNavy,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _criteria = _criteria.copyWith(
                            selectedCategory: selected ? cat : 'All',
                          );
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // 2. Specific Facility Requirements
                const Text(
                  'Required Accessibility Features',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDarkNavy,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Locations must have these confirmed or reported facilities:',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 10),

                _buildCheckboxTile(
                  title: 'Step-Free Entrance Required',
                  subtitle: 'Level ground entry or compliant access ramp',
                  icon: Icons.accessible_rounded,
                  value: _criteria.stepFreeRequired,
                  onChanged: (val) {
                    setState(() {
                      _criteria = _criteria.copyWith(stepFreeRequired: val);
                    });
                  },
                ),
                _buildCheckboxTile(
                  title: 'Working Elevator Required',
                  subtitle: 'Elevator connecting all visitor floors',
                  icon: Icons.elevator_rounded,
                  value: _criteria.workingLiftRequired,
                  onChanged: (val) {
                    setState(() {
                      _criteria = _criteria.copyWith(workingLiftRequired: val);
                    });
                  },
                ),
                _buildCheckboxTile(
                  title: 'Accessible Restroom Required',
                  subtitle: 'Wide doors, grab rails, and clearance radius',
                  icon: Icons.wc_rounded,
                  value: _criteria.accessibleWashroomRequired,
                  onChanged: (val) {
                    setState(() {
                      _criteria = _criteria.copyWith(accessibleWashroomRequired: val);
                    });
                  },
                ),
                _buildCheckboxTile(
                  title: 'Rest Seating Required',
                  subtitle: 'Benches or resting chairs at regular intervals',
                  icon: Icons.chair_rounded,
                  value: _criteria.seatingRequired,
                  onChanged: (val) {
                    setState(() {
                      _criteria = _criteria.copyWith(seatingRequired: val);
                    });
                  },
                ),
                _buildCheckboxTile(
                  title: 'Clear Wayfinding / Tactile Required',
                  subtitle: 'High contrast signs, audio cues, or tactile paths',
                  icon: Icons.signpost_rounded,
                  value: _criteria.clearWayfindingRequired,
                  onChanged: (val) {
                    setState(() {
                      _criteria = _criteria.copyWith(clearWayfindingRequired: val);
                    });
                  },
                ),

                const SizedBox(height: 16),

                // 3. Strict Verification Switch
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSubtle,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: AppTheme.secondaryBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Only Confirmed Accessible',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDarkNavy,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Strict mode: Excludes places with unconfirmed facilities',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _criteria.onlyConfirmedAccessible,
                        activeColor: AppTheme.primaryTeal,
                        onChanged: (val) {
                          setState(() {
                            _criteria = _criteria.copyWith(onlyConfirmedAccessible: val);
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 4. Sort By
                const Text(
                  'Sort Results By',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDarkNavy,
                  ),
                ),
                const SizedBox(height: 10),

                ...SortOption.values.map((option) {
                  return RadioListTile<SortOption>(
                    value: option,
                    groupValue: _criteria.sortOption,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      option.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDarkNavy,
                      ),
                    ),
                    subtitle: Text(
                      option.description,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                    activeColor: AppTheme.primaryTeal,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _criteria = _criteria.copyWith(sortOption: val);
                        });
                      }
                    },
                  );
                }),
              ],
            ),
          ),

          const Divider(height: 1, color: AppTheme.borderLight),

          // Bottom Action Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_criteria);
                  Navigator.pop(context);
                },
                child: Text(
                  _criteria.activeFiltersCount > 0
                      ? 'Apply ${_criteria.activeFiltersCount} Filters'
                      : 'Show All Places',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: value ? AppTheme.primaryTealLight.withOpacity(0.4) : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppTheme.primaryTeal : AppTheme.borderLight,
        ),
      ),
      child: CheckboxListTile(
        value: value,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        secondary: Icon(icon, color: value ? AppTheme.primaryTeal : AppTheme.textMuted),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: value ? AppTheme.primaryTealDark : AppTheme.textDarkNavy,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
        activeColor: AppTheme.primaryTeal,
        onChanged: (val) => onChanged(val ?? false),
      ),
    );
  }
}
