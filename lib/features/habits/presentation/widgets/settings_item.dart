import 'package:flutter/material.dart';

class SettingsItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
