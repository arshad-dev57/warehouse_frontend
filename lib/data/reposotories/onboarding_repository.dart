import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_app/core/contants/image_constants.dart';
import 'package:warehouse_management_app/data/models/onboarding_models.dart';

class OnboardingRepository extends GetxService {
  List<OnboardingItem> getOnboardingData() {
    return [
      OnboardingItem(
        image: ImageConstants.onboarding1,
        title: 'Manage Your Warehouse',
        description: 'Efficiently manage your inventory, track stock levels, and organize products with ease',
        color: const Color(0xFF4A90E2),
        icon: Icons.inventory_2_outlined,
      ),
      OnboardingItem(
        image: ImageConstants.onboarding2,
        title: 'Real-time Tracking',
        description: 'Track your inventory in real-time with barcode scanning and automated updates',
        color: const Color(0xFF50C878),
        icon: Icons.timeline_outlined,
      ),
      OnboardingItem(
        image: ImageConstants.onboarding3,
        title: 'Analytics & Reports',
        description: 'Get detailed insights with advanced analytics and customizable reports',
        color: const Color(0xFFFF6B6B),
        icon: Icons.analytics_outlined,
      ),
      OnboardingItem(
        image: ImageConstants.onboarding4,
        title: 'Team Collaboration',
        description: 'Work together with your team, assign tasks, and streamline operations',
        color: const Color(0xFFFFB347),
        icon: Icons.groups_outlined,
      ),
    ];
  }
}