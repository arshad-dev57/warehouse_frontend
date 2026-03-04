import 'package:flutter/material.dart';

class OnboardingItem {
  final String image;
  final String title;
  final String description;
  final Color color;
  final IconData icon;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
  });

  // Factory method for creating from JSON
  factory OnboardingItem.fromJson(Map<String, dynamic> json) {
    return OnboardingItem(
      image: json['image'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      color: Color(json['color'] ?? 0xFF4A90E2),
      icon: IconData(json['icon'] ?? Icons.inventory.codePoint,
          fontFamily: 'MaterialIcons'),
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'title': title,
      'description': description,
      'color': color.value,
      'icon': icon.codePoint,
    };
  }
}