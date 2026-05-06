import 'package:flutter/material.dart';

class FeatureItem {
  final String id;
  final String title;
  final IconData iconData;
  final String targetRoute;
  final bool requiresAuth;

  const FeatureItem({
    required this.id,
    required this.title,
    required this.iconData,
    required this.targetRoute,
    this.requiresAuth = false,
  });
}

class FeatureCategory {
  final String id;
  final String title;
  final List<FeatureItem> items;

  const FeatureCategory({
    required this.id,
    required this.title,
    required this.items,
  });
}
