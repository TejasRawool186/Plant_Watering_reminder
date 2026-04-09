import 'dart:convert';
import 'package:flutter/material.dart';

class Plant {
  final String id;
  final String name;
  final int wateringFrequency; // in days
  final DateTime lastWatered;
  final DateTime createdAt;
  final String? imagePath;
  final IconData icon;
  final Color color;

  Plant({
    required this.id,
    required this.name,
    required this.wateringFrequency,
    required this.lastWatered,
    DateTime? createdAt,
    this.imagePath,
    this.icon = Icons.eco,
    this.color = const Color(0xFF52B788),
  }) : createdAt = createdAt ?? DateTime.now();

  DateTime get nextWateringDate =>
      lastWatered.add(Duration(days: wateringFrequency));

  bool get needsWatering =>
      nextWateringDate.isBefore(DateTime.now()) ||
      _isSameDay(nextWateringDate, DateTime.now());

  bool get isOverdue => nextWateringDate.isBefore(
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ),
      );

  bool get isDueToday => _isSameDay(nextWateringDate, DateTime.now());

  int get daysUntilWatering {
    final now = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final next = DateTime(
      nextWateringDate.year,
      nextWateringDate.month,
      nextWateringDate.day,
    );
    return next.difference(now).inDays;
  }

  int get daysOverdue => -daysUntilWatering;

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Plant copyWith({
    String? name,
    int? wateringFrequency,
    DateTime? lastWatered,
    String? imagePath,
    IconData? icon,
    Color? color,
  }) {
    return Plant(
      id: id,
      name: name ?? this.name,
      wateringFrequency: wateringFrequency ?? this.wateringFrequency,
      lastWatered: lastWatered ?? this.lastWatered,
      createdAt: createdAt,
      imagePath: imagePath ?? this.imagePath,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'wateringFrequency': wateringFrequency,
      'lastWatered': lastWatered.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'imagePath': imagePath,
      'iconCodePoint': icon.codePoint,
      'colorValue': color.toARGB32(),
    };
  }

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] as String,
      name: json['name'] as String,
      wateringFrequency: json['wateringFrequency'] as int,
      lastWatered: DateTime.parse(json['lastWatered'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      imagePath: json['imagePath'] as String?,
      icon: json['iconCodePoint'] != null
          ? IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons')
          : Icons.eco,
      color: json['colorValue'] != null
          ? Color(json['colorValue'] as int)
          : const Color(0xFF52B788),
    );
  }

  static String encode(List<Plant> plants) {
    return jsonEncode(plants.map((p) => p.toJson()).toList());
  }

  static List<Plant> decode(String jsonString) {
    final List<dynamic> data = jsonDecode(jsonString);
    return data.map((json) => Plant.fromJson(json as Map<String, dynamic>)).toList();
  }
}
