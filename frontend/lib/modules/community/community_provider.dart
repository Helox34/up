import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/post_model.dart';
import '../../services/firebase_community_service.dart';

class CommunityProvider extends ChangeNotifier {
  final FirebaseCommunityService service = FirebaseCommunityService();
  List<PostModel> feed = [];
  bool loading = false;

  CommunityProvider() {
    _init();
  }

  void _init() {
    service.postsStream().listen((docs) {
      feed = docs.map((d) => PostModel.fromDoc(d)).toList();
      notifyListeners();
    });
  }

  Future<void> createPost({
    required String activityType,
    required String summary,
    String? description,
    dynamic image
  }) async {
    await service.createPost(
      activityType: activityType,
      summary: summary,
      description: description ?? '', // Konwertuj String? na String
      imageUrl: image is String ? image : null, // Upewnij się, że imageUrl jest String?
    );
    notifyListeners(); // Dodaj notyfikację po utworzeniu posta
  }

  Future<void> toggleLike(String postId) async {
    await service.toggleLike(postId);
    notifyListeners(); // Dodaj notyfikację po zmianie like
  }

  Stream<List<DocumentSnapshot>> commentsStream(String postId) => service.commentsStream(postId);

  Future<void> addComment(String postId, String text) async {
    await service.addComment(postId, text);
    notifyListeners(); // Dodaj notyfikację po dodaniu komentarza
  }

  Future<void> followUser(String userId) => service.followUser(userId);

  Future<void> unfollowUser(String userId) => service.unfollowUser(userId);

  // Dodatkowe metody pomocnicze
  Future<void> refreshFeed() async {
    loading = true;
    notifyListeners();

    try {
      final docs = await service.getPosts();
      feed = docs.map((d) => PostModel.fromDoc(d)).toList();
    } catch (e) {
      // Handle error
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> deletePost(String postId) async {
    await service.deletePost(postId);
    notifyListeners();
  }
}