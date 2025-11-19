import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String activityType;
  final String summary;
  final String? description; // MOŻE BYĆ NULL
  final String? imageUrl;    // MOŻE BYĆ NULL
  final int likesCount;
  final int commentsCount;   // DODAJ TO POLE
  final Timestamp createdAt;
  final Timestamp updatedAt;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.activityType,
    required this.summary,
    this.description,        // MOŻE BYĆ NULL
    this.imageUrl,          // MOŻE BYĆ NULL
    required this.likesCount,
    required this.commentsCount, // DODANE
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorAvatar: data['authorAvatar'] ?? '',
      activityType: data['activityType'] ?? '',
      summary: data['summary'] ?? '',
      description: data['description'], // MOŻE BYĆ NULL
      imageUrl: data['imageUrl'],       // MOŻE BYĆ NULL
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0, // DODANE
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }
}