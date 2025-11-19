class UserModel {
  final String id;
  final String displayName;
  final String? avatarUrl;


  UserModel({required this.id, required this.displayName, this.avatarUrl});


  factory UserModel.fromMap(String id, Map<String, dynamic> m) => UserModel(
    id: id,
    displayName: m['displayName'] ?? '',
    avatarUrl: m['avatarUrl'],
  );


  Map<String, dynamic> toMap() => {'displayName': displayName, 'avatarUrl': avatarUrl};
}