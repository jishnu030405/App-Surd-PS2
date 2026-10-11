import 'package:flutter/material.dart';

enum AccessibilityCategory {
  stepFreeAccess(
    id: 'step_free',
    title: 'Step-Free Access',
    shortTitle: 'Step-Free',
    weight: 0.30,
    icon: Icons.accessible_rounded,
    description: 'Level ground entry, threshold height, absence of steps, or dedicated zero-step paths.',
  ),
  liftsAndRamps(
    id: 'lifts_ramps',
    title: 'Lifts and Ramps',
    shortTitle: 'Lifts & Ramps',
    weight: 0.20,
    icon: Icons.elevator_rounded,
    description: 'Working elevators, gentle ramp gradients (<= 1:12), handrails, and adequate cabin width.',
  ),
  accessibleWashrooms(
    id: 'accessible_washrooms',
    title: 'Accessible Washrooms',
    shortTitle: 'Washrooms',
    weight: 0.20,
    icon: Icons.wc_rounded,
    description: 'Wide entrance doors, grab rails, low sinks, emergency alarm cords, and clear turning radius.',
  ),
  seatingAvailability(
    id: 'seating',
    title: 'Seating Availability',
    shortTitle: 'Seating',
    weight: 0.15,
    icon: Icons.chair_rounded,
    description: 'Rest areas, benches at reasonable intervals, ergonomic seating, and companion spaces.',
  ),
  signageAndWayfinding(
    id: 'signage_wayfinding',
    title: 'Signage & Wayfinding',
    shortTitle: 'Signage',
    weight: 0.15,
    icon: Icons.signpost_rounded,
    description: 'High-contrast text, clear directional signs, braille/tactile floor indicators, and audio aids.',
  );

  final String id;
  final String title;
  final String shortTitle;
  final double weight;
  final IconData icon;
  final String description;

  const AccessibilityCategory({
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.weight,
    required this.icon,
    required this.description,
  });

  int get weightPercentage => (weight * 100).round();

  static AccessibilityCategory? fromId(String id) {
    for (final category in AccessibilityCategory.values) {
      if (category.id == id) return category;
    }
    return null;
  }
}
