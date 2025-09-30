import 'package:cloud_firestore/cloud_firestore.dart';

class HabitModel {
  final String id;
  final String ownerId;
  final String title;
  final String frequency;
  final int streak;
  final DateTime? lastChecked;
  final DateTime createdAt;

  HabitModel({
    required this.id,
    required this.ownerId,
    required this.title,
    this.frequency = 'daily',
    this.streak = 0,
    this.lastChecked,
    required this.createdAt,
  });

  factory HabitModel.fromMap(String id, Map<String, dynamic> data) {
    return HabitModel(
      id: id,
      ownerId: data['ownerId'] ?? '',
      title: data['title'] ?? '',
      frequency: data['frequency'] ?? 'daily',
      streak: data['streak'] ?? 0,
      lastChecked: data['lastChecked'] != null
          ? DateTime.tryParse(data['lastChecked'])
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'frequency': frequency,
      'streak': streak,
      'lastChecked': lastChecked?.toIso8601String(),
      'createdAt': createdAt,
    };
  }
}
