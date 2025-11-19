// modules/community/screens/community_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../community_provider.dart';
import '../widgets/post_card_widget.dart';
import 'create_post_screen.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({Key? key}) : super(key: key);

  void _openCreatePost(BuildContext context) {
    // Użyj ModalRoute aby zachować BottomNavBar
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 👈 WAŻNE - pozwala na pełną wysokość
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const CreatePostScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Społeczność'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<CommunityProvider>(
        builder: (context, provider, _) {
          if (provider.loading && provider.feed.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.feed.isEmpty) {
            return const Center(
              child: Text('Brak postów. Bądź pierwszy!'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshFeed(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.feed.length,
              itemBuilder: (context, index) {
                final post = provider.feed[index];
                return PostCardWidget(post: post);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreatePost(context), // 👈 UŻYJ POPRAWNEJ METODY
        child: const Icon(Icons.add),
      ),
    );
  }
}