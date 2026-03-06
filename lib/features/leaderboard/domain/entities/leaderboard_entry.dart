import 'package:equatable/equatable.dart';

enum LeaderboardMode { story, endless, daily, weekly }

class LeaderboardEntry extends Equatable {
  final String id;
  final String uid;
  final String displayName;
  final String? photoUrl;
  final int score;
  final int highestTile;
  final LeaderboardMode mode;
  final DateTime submittedAt;

  const LeaderboardEntry({
    required this.id,
    required this.uid,
    required this.displayName,
    this.photoUrl,
    required this.score,
    required this.highestTile,
    required this.mode,
    required this.submittedAt,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'score': score,
        'highestTile': highestTile,
        'mode': mode.name,
        'submittedAt': submittedAt.toIso8601String(),
      };

  factory LeaderboardEntry.fromJson(String id, Map<String, dynamic> json) =>
      LeaderboardEntry(
        id: id,
        uid: json['uid'] as String,
        displayName: json['displayName'] as String? ?? 'Player',
        photoUrl: json['photoUrl'] as String?,
        score: (json['score'] as num).toInt(),
        highestTile: (json['highestTile'] as num?)?.toInt() ?? 0,
        mode: LeaderboardMode.values.byName(json['mode'] as String),
        submittedAt: DateTime.parse(json['submittedAt'] as String),
      );

  @override
  List<Object?> get props => [id, uid, score, mode];
}
