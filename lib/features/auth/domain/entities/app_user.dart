import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String uid;
  final String username;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final bool isPremium;
  final bool isGamesServicesConnected;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.username,
    this.displayName,
    this.email,
    this.photoUrl,
    this.isPremium = false,
    this.isGamesServicesConnected = false,
    required this.createdAt,
  });

  AppUser copyWith({
    String? username,
    String? displayName,
    String? email,
    String? photoUrl,
    bool? isPremium,
    bool? isGamesServicesConnected,
  }) {
    return AppUser(
      uid: uid,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isPremium: isPremium ?? this.isPremium,
      isGamesServicesConnected:
          isGamesServicesConnected ?? this.isGamesServicesConnected,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'username': username,
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'isPremium': isPremium,
        'isGamesServicesConnected': isGamesServicesConnected,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        uid: json['uid'] as String,
        username: json['username'] as String? ?? 'Player',
        displayName: json['displayName'] as String?,
        email: json['email'] as String?,
        photoUrl: json['photoUrl'] as String?,
        isPremium: json['isPremium'] as bool? ?? false,
        isGamesServicesConnected:
            json['isGamesServicesConnected'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  @override
  List<Object?> get props =>
      [uid, username, displayName, email, isPremium, isGamesServicesConnected];
}
