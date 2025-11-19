import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseCommunityService {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // STRUMIENIE I POBIRANIE POSTÓW

  Stream<List<DocumentSnapshot>> postsStream() {
    return _fs.collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Stream<DocumentSnapshot> postStream(String postId) {
    return _fs.collection('posts').doc(postId).snapshots();
  }

  Future<List<DocumentSnapshot>> getPosts() async {
    final snapshot = await _fs.collection('posts')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }

  Future<DocumentSnapshot> getPost(String postId) async {
    return await _fs.collection('posts').doc(postId).get();
  }

  // ZARZĄDZANIE POSTAMI

  Future<void> createPost({
    required String activityType,
    required String summary,
    required String description,
    String? imageUrl,
  }) async {
    final user = _auth.currentUser!;
    final userDoc = await _fs.collection('users').doc(user.uid).get();
    final authorName = userDoc.data()?['displayName'] ?? user.displayName ?? 'Użytkownik';
    final authorAvatar = userDoc.data()?['avatarUrl'] ?? user.photoURL;

    await _fs.collection('posts').add({
      'authorId': user.uid,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'activityType': activityType,
      'summary': summary,
      'imageUrl': imageUrl,
      'description': description,
      'likesCount': 0,
      'commentsCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePost({
    required String postId,
    required String activityType,
    required String summary,
    required String description,
    String? imageUrl,
  }) async {
    final user = _auth.currentUser!;
    final postDoc = await _fs.collection('posts').doc(postId).get();

    if (postDoc.exists && postDoc.data()?['authorId'] == user.uid) {
      await _fs.collection('posts').doc(postId).update({
        'activityType': activityType,
        'summary': summary,
        'description': description,
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      throw Exception('Nie masz uprawnień do edycji tego posta');
    }
  }

  Future<void> deletePost(String postId) async {
    final user = _auth.currentUser!;
    final postDoc = await _fs.collection('posts').doc(postId).get();

    if (postDoc.exists && postDoc.data()?['authorId'] == user.uid) {
      await _fs.collection('posts').doc(postId).delete();
    } else {
      throw Exception('Nie masz uprawnień do usunięcia tego posta');
    }
  }

  // POLUBIENIA

  Future<void> toggleLike(String postId) async {
    final user = _auth.currentUser!;
    final likeRef = _fs.collection('posts').doc(postId).collection('likes').doc(user.uid);
    final postRef = _fs.collection('posts').doc(postId);

    return _fs.runTransaction((tx) async {
      final postSnap = await tx.get(postRef);
      if (!postSnap.exists) throw Exception('Post nie istnieje');
      final likeSnap = await tx.get(likeRef);
      int likes = (postSnap.data()?['likesCount'] ?? 0) as int;
      if (likeSnap.exists) {
        tx.delete(likeRef);
        tx.update(postRef, {'likesCount': likes - 1});
      } else {
        tx.set(likeRef, {'createdAt': FieldValue.serverTimestamp()});
        tx.update(postRef, {'likesCount': likes + 1});
      }
    });
  }

  Stream<DocumentSnapshot> likeStatusStream(String postId) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _fs.collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(user.uid)
        .snapshots();
  }

  Future<bool> isLiked(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final likeDoc = await _fs.collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(user.uid)
        .get();
    return likeDoc.exists;
  }

  Future<int> getLikeCount(String postId) async {
    final snapshot = await _fs.collection('posts')
        .doc(postId)
        .collection('likes')
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  // KOMENTARZE

  Stream<List<DocumentSnapshot>> commentsStream(String postId) {
    return _fs.collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs);
  }

  Future<void> addComment(String postId, String text) async {
    final user = _auth.currentUser!;
    final userDoc = await _fs.collection('users').doc(user.uid).get();
    final authorName = userDoc.data()?['displayName'] ?? user.displayName ?? 'Użytkownik';
    final authorAvatar = userDoc.data()?['avatarUrl'] ?? user.photoURL;

    await _fs.collection('posts').doc(postId).collection('comments').add({
      'authorId': user.uid,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'text': text,
      'createdAt': FieldValue.serverTimestamp()
    });
    await _fs.collection('posts').doc(postId).update({
      'commentsCount': FieldValue.increment(1)
    });
  }

  Future<void> deleteComment(String postId, String commentId) async {
    final user = _auth.currentUser!;
    final commentDoc = await _fs.collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .get();

    if (commentDoc.exists && commentDoc.data()?['authorId'] == user.uid) {
      await _fs.collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
      await _fs.collection('posts').doc(postId).update({
        'commentsCount': FieldValue.increment(-1)
      });
    } else {
      throw Exception('Nie masz uprawnień do usunięcia tego komentarza');
    }
  }

  Future<int> getCommentCount(String postId) async {
    final snapshot = await _fs.collection('posts')
        .doc(postId)
        .collection('comments')
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  // OBSERWACJE

  Future<void> followUser(String targetUserId) async {
    final user = _auth.currentUser!;
    await _fs.collection('users').doc(user.uid).collection('following').doc(targetUserId).set({
      'createdAt': FieldValue.serverTimestamp()
    });
    await _fs.collection('users').doc(targetUserId).collection('followers').doc(user.uid).set({
      'createdAt': FieldValue.serverTimestamp()
    });
  }

  Future<void> unfollowUser(String targetUserId) async {
    final user = _auth.currentUser!;
    await _fs.collection('users').doc(user.uid).collection('following').doc(targetUserId).delete();
    await _fs.collection('users').doc(targetUserId).collection('followers').doc(user.uid).delete();
  }

  Stream<DocumentSnapshot> followStatusStream(String targetUserId) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _fs.collection('users')
        .doc(user.uid)
        .collection('following')
        .doc(targetUserId)
        .snapshots();
  }

  Future<bool> isFollowing(String targetUserId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final followDoc = await _fs.collection('users')
        .doc(user.uid)
        .collection('following')
        .doc(targetUserId)
        .get();
    return followDoc.exists;
  }

  // ZARZĄDZANIE ZDJĘCIAMI

  Future<String> uploadImage(Reference ref) async {
    final imageUrl = await ref.getDownloadURL();
    return imageUrl;
  }

  // METODY POMOCNICZE

  Stream<List<DocumentSnapshot>> userPostsStream(String userId) {
    return _fs.collection('posts')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<List<DocumentSnapshot>> getUserPosts(String userId) async {
    final snapshot = await _fs.collection('posts')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }

  Future<DocumentSnapshot> getUserData(String userId) async {
    return await _fs.collection('users').doc(userId).get();
  }

  Future<void> updateUserProfile({
    required String displayName,
    String? avatarUrl,
  }) async {
    final user = _auth.currentUser!;
    await _fs.collection('users').doc(user.uid).set({
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // STATYSTYKI

  Future<int> getUserPostCount(String userId) async {
    final snapshot = await _fs.collection('posts')
        .where('authorId', isEqualTo: userId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<int> getUserFollowerCount(String userId) async {
    final snapshot = await _fs.collection('users')
        .doc(userId)
        .collection('followers')
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<int> getUserFollowingCount(String userId) async {
    final snapshot = await _fs.collection('users')
        .doc(userId)
        .collection('following')
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}