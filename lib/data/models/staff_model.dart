// lib/data/models/staff_model.dart

import 'package:flutter/material.dart';

class StaffModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final bool isActive;
  final String? country;
  final DateTime createdAt;
  final String? createdBy;

  StaffModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.isActive,
    this.country,
    required this.createdAt,
    this.createdBy,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone']?.toString(),
      role: json['role'] ?? 'staff',
      isActive: json['isActive'] ?? true,
      country: json['country']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      createdBy: json['createdBy']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'country': country,
    };
  }

  Color get roleColor {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.blue;
      case 'staff':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String get roleDisplayName {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'manager':
        return 'Manager';
      case 'staff':
        return 'Staff';
      default:
        return role;
    }
  }
}