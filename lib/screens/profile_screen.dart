import 'package:flutter/material.dart';
import '../services/place_repository.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final PlaceRepository repository;

  const ProfileScreen({super.key, required this.repository});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<String> _presets = [
    'Wheelchair User',
    'Senior / Mobility Aid',
    'Low Vision / Blind',
    'Caregiver / Parent',
    'General Accessibility',
  ];

  void _onPresetChanged(String preset) {
    bool stepFree = true;
    bool lift = true;
    bool washroom = true;
    bool seating = false;
    bool wayfinding = false;

    if (preset == 'Senior / Mobility Aid') {
      stepFree = true;
      lift = true;
      washroom = true;
      seating = true;
      wayfinding = false;
    } else if (preset == 'Low Vision / Blind') {
      stepFree = false;
      lift = true;
      washroom = false;
      seating = false;
      wayfinding = true;
    } else if (preset == 'Caregiver / Parent') {
      stepFree = true;
      lift = true;
      washroom = true;
      seating = true;
      wayfinding = false;
    } else if (preset == 'General Accessibility') {
      stepFree = false;
      lift = false;
      washroom = false;
      seating = false;
      wayfinding = false;
    }

    final updated = widget.repository.userProfile.copyWith(
      personaPreset: preset,
      preferredStepFree: stepFree,
      preferredLift: lift,
      preferredWashroom: washroom,
      preferredSeating: seating,
      preferredWayfinding: wayfinding,
    );
    widget.repository.updateUserProfile(updated);
  }

  void _confirmResetData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Demo Data?'),
        content: const Text(
          'This will restore the original sample places and reset your locally submitted reviews back to initial hackathon demo state.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusRed),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              await widget.repository.resetToDemoData();
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Demo data has been reset to defaults.')),
                );
              }
            },
            child: const Text('Reset to Default'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        final profile = widget.repository.userProfile;
        final savedCount = widget.repository.savedPlaces.length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile & Preferences'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              // User Identity Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppTheme.borderLight),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppTheme.primaryTeal,
                            child: const Icon(
                              Icons.person_rounded,
                              size: 34,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDarkNavy,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  profile.role,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppTheme.statusGreen,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Offline Local Sync Active',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: AppTheme.borderLight),
                      const SizedBox(height: 16),

                      // User Contribution Stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              '${profile.reviewsSubmittedCount}',
                              'Reviews Added',
                              Icons.rate_review_outlined,
                            ),
                          ),
                          Container(width: 1, height: 36, color: AppTheme.borderLight),
                          Expanded(
                            child: _buildStatItem(
                              '$savedCount',
                              'Saved Places',
                              Icons.bookmark_outline_rounded,
                            ),
                          ),
                          Container(width: 1, height: 36, color: AppTheme.borderLight),
                          Expanded(
                            child: _buildStatItem(
                              'Active',
                              'Scout Status',
                              Icons.verified_outlined,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Accessibility Persona Preset Selection
              const Text(
                'Accessibility Persona Preset',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDarkNavy,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Customize default accessibility checks tailored to your mobility needs:',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.borderLight),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: _presets.map((preset) {
                      final isSelected = profile.personaPreset == preset;
                      return RadioListTile<String>(
                        value: preset,
                        groupValue: profile.personaPreset,
                        activeColor: AppTheme.primaryTeal,
                        title: Text(
                          preset,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: AppTheme.textDarkNavy,
                          ),
                        ),
                        onChanged: (val) {
                          if (val != null) _onPresetChanged(val);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Preferred Requirements Toggles
              const Text(
                'Default Requirements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDarkNavy,
                ),
              ),
              const SizedBox(height: 10),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.borderLight),
                ),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      'Step-Free Entrance Preferred',
                      Icons.accessible_rounded,
                      profile.preferredStepFree,
                      (val) => widget.repository.updateUserProfile(
                        profile.copyWith(preferredStepFree: val),
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSwitchTile(
                      'Working Elevator Preferred',
                      Icons.elevator_rounded,
                      profile.preferredLift,
                      (val) => widget.repository.updateUserProfile(
                        profile.copyWith(preferredLift: val),
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSwitchTile(
                      'Accessible Washroom Preferred',
                      Icons.wc_rounded,
                      profile.preferredWashroom,
                      (val) => widget.repository.updateUserProfile(
                        profile.copyWith(preferredWashroom: val),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Demo Management & Data Reset
              const Text(
                'Demo & Data Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDarkNavy,
                ),
              ),
              const SizedBox(height: 10),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.borderLight),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.restart_alt_rounded, color: AppTheme.statusRed),
                      title: const Text(
                        'Reset Sample Demo Data',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.statusRed,
                        ),
                      ),
                      subtitle: const Text(
                        'Restore 9 sample places and original community feedback',
                        style: TextStyle(fontSize: 12),
                      ),
                      onTap: _confirmResetData,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded, color: AppTheme.primaryTeal),
                      title: const Text(
                        'About AccessPath',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Hackathon MVP v1.0.0 • Every place. More accessible.',
                        style: TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'AccessPath',
                          applicationVersion: '1.0.0',
                          applicationLegalese: '© 2026 AccessPath Team. Crowdsourced accessibility insights for public places.',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryTeal),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDarkNavy,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile.adaptive(
      value: value,
      activeColor: AppTheme.primaryTeal,
      secondary: Icon(icon, color: value ? AppTheme.primaryTeal : AppTheme.textMuted),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: value ? FontWeight.w700 : FontWeight.w500,
          color: AppTheme.textDarkNavy,
        ),
      ),
      onChanged: onChanged,
    );
  }
}
