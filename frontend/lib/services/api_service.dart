import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://example.com/api';

  static Future<List<Map<String, dynamic>>> fetchPosts() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        'user': 'Bartek',
        'content': 'Mój pierwszy post!',
        'imageUrl': 'https://picsum.photos/400/300?random=1'
      },
      {
        'user': 'Ania',
        'content': 'Dzisiaj trening nóg 💪',
        'imageUrl': 'https://picsum.photos/400/300?random=2'
      },
      {
        'user': 'Marek',
        'content': 'Nowy rekord w wyciskaniu! 🏋️',
        'imageUrl': null
      },
    ];
  }

  static Future<void> createPost(String user, String content, {String? imageUrl}) async {
    try {
      print('Creating post: user=$user, content=$content, imageUrl=$imageUrl');
      await Future.delayed(const Duration(seconds: 1));
      print('Post stworzony: $user - $content');
    } catch (e) {
      throw Exception('Error creating post: $e');
    }
  }

  static Future<List<Map<String, String>>> fetchChallenges() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {'title': '100 pompek dziennie', 'level': 'Średni'},
      {'title': '5 km biegu', 'level': 'Łatwy'},
      {'title': '30 dni jogi', 'level': 'Łatwy'},
      {'title': 'Maraton', 'level': 'Trudny'},
    ];
  }
}