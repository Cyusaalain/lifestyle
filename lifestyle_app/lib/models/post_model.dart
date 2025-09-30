import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String text;
  final String? imageUrl;
  final int likes;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.authorId,
    required this.text,
    this.imageUrl,
    this.likes = 0,
    required this.createdAt,
  });

  factory PostModel.fromMap(String id, Map<String, dynamic> data) {
    return PostModel(
      id: id,
      authorId: data['authorId'] ?? '',
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      likes: data['likes'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'text': text,
      'imageUrl': imageUrl,
      'likes': likes,
      'createdAt': createdAt,
    };
  }
}
