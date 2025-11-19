import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/post_model.dart';
import '../community_provider.dart';

class PostCardWidget extends StatelessWidget {
  final PostModel post;
  const PostCardWidget({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommunityProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nagłówek z autorem
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDate(post.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Menu opcji posta
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Typ aktywności
            if (post.activityType.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  post.activityType,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Podsumowanie
            Text(
              post.summary,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            // Opis (POPRAWIONO - sprawdzanie null safety)
            if (post.description != null && post.description!.isNotEmpty)
              Text(
                post.description!, // DODANO ! bo wiemy że nie jest null
                style: const TextStyle(fontSize: 14),
              ),

            const SizedBox(height: 12),

            // Zdjęcie (jeśli istnieje)
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(post.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Akcje (like, komentarz)
            Row(
              children: [
                // Like button
                StreamBuilder<DocumentSnapshot>(
                  stream: provider.service.likeStatusStream(post.id),
                  builder: (context, snapshot) {
                    final isLiked = snapshot.data?.exists ?? false;
                    return TextButton.icon(
                      onPressed: () => provider.toggleLike(post.id),
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      label: Text('${post.likesCount}'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                    );
                  },
                ),

                // Comment button (POPRAWIONO - użyj commentsCount jeśli istnieje, w przeciwnym razie 0)
                TextButton.icon(
                  onPressed: () {
                    // Navigate to comments screen
                  },
                  icon: const Icon(Icons.comment),
                  label: Text('${post.commentsCount ?? 0}'), // DODANO ?? 0
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                ),

                const Spacer(),

                // Share button
                IconButton(
                  onPressed: () {
                    // Share functionality
                  },
                  icon: const Icon(Icons.share),
                  color: Colors.grey[600],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Teraz';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min temu';
    if (difference.inHours < 24) return '${difference.inHours} h temu';
    if (difference.inDays < 7) return '${difference.inDays} dni temu';

    return '${date.day}.${date.month}.${date.year}';
  }
}