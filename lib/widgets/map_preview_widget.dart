import 'package:flutter/material.dart';
import '../models/place.dart';
import '../theme/app_theme.dart';
import 'accessibility_badge.dart';
import 'facility_indicator_chip.dart';

class MapPreviewWidget extends StatefulWidget {
  final List<Place> places;
  final ValueChanged<Place> onSelectPlace;
  final Place? selectedPlace;

  const MapPreviewWidget({
    super.key,
    required this.places,
    required this.onSelectPlace,
    this.selectedPlace,
  });

  @override
  State<MapPreviewWidget> createState() => _MapPreviewWidgetState();
}

class _MapPreviewWidgetState extends State<MapPreviewWidget> {
  Place? _activePlace;

  @override
  void initState() {
    super.initState();
    _activePlace = widget.selectedPlace ?? (widget.places.isNotEmpty ? widget.places.first : null);
  }

  @override
  void didUpdateWidget(covariant MapPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPlace != null && widget.selectedPlace != _activePlace) {
      _activePlace = widget.selectedPlace;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map Canvas
        Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFE8EEF5), // Map water/land tone
          child: CustomPaint(
            painter: _CityMapPainter(),
          ),
        ),

        // Map Pins Layer
        ...widget.places.asMap().entries.map((entry) {
          final index = entry.key;
          final place = entry.value;
          final isSelected = _activePlace?.id == place.id;

          // Deterministic coordinate projection for map demonstration
          final pinOffsets = [
            const Offset(0.25, 0.35),
            const Offset(0.55, 0.25),
            const Offset(0.75, 0.45),
            const Offset(0.35, 0.65),
            const Offset(0.60, 0.70),
            const Offset(0.80, 0.80),
            const Offset(0.18, 0.80),
            const Offset(0.40, 0.18),
            const Offset(0.70, 0.15),
          ];

          final offsetRatio = pinOffsets[index % pinOffsets.length];

          return LayoutBuilder(
            builder: (context, constraints) {
              final x = constraints.maxWidth * offsetRatio.dx;
              final y = constraints.maxHeight * offsetRatio.dy;

              final scoreResult = place.scoreResult;
              final pinColor = scoreResult.statusColor;

              return Positioned(
                left: x - 22,
                top: y - 44,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _activePlace = place;
                    });
                  },
                  child: Semantics(
                    label: '${place.name}, Accessibility: ${place.shortStatus}',
                    button: true,
                    child: AnimatedScale(
                      scale: isSelected ? 1.25 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: pinColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white,
                                width: isSelected ? 2.5 : 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getCategoryIcon(place.category),
                                  size: 13,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  scoreResult.hasSufficientData
                                      ? '${scoreResult.roundedScore}'
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CustomPaint(
                            size: const Size(10, 8),
                            painter: _PinTrianglePainter(color: pinColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),

        // "You Are Here" Marker
        LayoutBuilder(
          builder: (context, constraints) {
            return Positioned(
              left: constraints.maxWidth * 0.48 - 14,
              top: constraints.maxHeight * 0.50 - 14,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.secondaryBlue.withOpacity(0.2),
                ),
                child: Center(
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.secondaryBlue,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Map Compass / Attribution Badge
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.explore_outlined, size: 14, color: AppTheme.primaryTeal),
                SizedBox(width: 4),
                Text(
                  'AccessPath Vector Map',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDarkNavy,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Floating Bottom Preview Card when place is selected
        if (_activePlace != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _buildBottomPreviewCard(_activePlace!),
          ),
      ],
    );
  }

  Widget _buildBottomPreviewCard(Place place) {
    final scoreResult = place.scoreResult;

    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondaryBlue,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDarkNavy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        place.locality,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                AccessibilityBadge(
                  scoreResult: scoreResult,
                  compact: true,
                  showCoverage: false,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: [
                FacilityIndicatorChip(
                  label: 'Step-Free',
                  status: place.stepFreeEntry,
                  facilityIcon: Icons.accessible_rounded,
                  compact: true,
                ),
                FacilityIndicatorChip(
                  label: 'Lift',
                  status: place.workingLift,
                  facilityIcon: Icons.elevator_rounded,
                  compact: true,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: () => widget.onSelectPlace(place),
                icon: const Icon(Icons.description_outlined, size: 16),
                label: const Text('Open Accessibility Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'hospitals':
        return Icons.local_hospital_rounded;
      case 'colleges':
        return Icons.school_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'transport':
        return Icons.directions_subway_rounded;
      case 'public offices':
        return Icons.account_balance_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }
}

class _PinTrianglePainter extends CustomPainter {
  final Color color;
  _PinTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CityMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    final minorStreetPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final parkPaint = Paint()
      ..color = const Color(0xFFDCFCE7).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Draw green parks
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.1, size.width * 0.25, size.height * 0.18),
        const Radius.circular(16),
      ),
      parkPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.65, size.height * 0.55, size.width * 0.3, size.height * 0.25),
        const Radius.circular(20),
      ),
      parkPaint,
    );

    // Minor streets
    for (double i = 0.1; i < 1.0; i += 0.15) {
      canvas.drawLine(
        Offset(0, size.height * i),
        Offset(size.width, size.height * i),
        minorStreetPaint,
      );
      canvas.drawLine(
        Offset(size.width * i, 0),
        Offset(size.width * i, size.height),
        minorStreetPaint,
      );
    }

    // Major Avenues
    final majorPath = Path()
      ..moveTo(0, size.height * 0.45)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.4,
        size.width * 0.7,
        size.height * 0.6,
        size.width,
        size.height * 0.5,
      );
    canvas.drawPath(majorPath, streetPaint);

    final crossPath = Path()
      ..moveTo(size.width * 0.48, 0)
      ..lineTo(size.width * 0.48, size.height);
    canvas.drawPath(crossPath, streetPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
