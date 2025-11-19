import 'package:cloud_firestore/cloud_firestore.dart';


class CommentModel {
  final String id;
  final String authorId;
  final String authorName;
  final String text;
  final Timestamp createdAt;


  CommentModel({required this.id, required this.authorId, required this.authorName, required this.text, required this.createdAt});


  factory CommentModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      authorId: d['authorId'] ?? '',
      authorName: d['authorName'] ?? '',
      text: d['text'] ?? '',
      createdAt: d['createdAt'] ?? Timestamp.now(),
    );
  }
}