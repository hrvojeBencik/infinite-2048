import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/leaderboard_entry.dart';

class LeaderboardRemoteDataSource {
  static const _collection = 'leaderboard';

  CollectionReference get _ref =>
      FirebaseFirestore.instance.collection(_collection);

  /// Fetch top scores for a given mode, ordered descending by score.
  Future<List<LeaderboardEntry>> getTopScores({
    required LeaderboardMode mode,
    int limit = 50,
  }) async {
    try {
      final snapshot = await _ref
          .where('mode', isEqualTo: mode.name)
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => LeaderboardEntry.fromJson(
              doc.id, doc.data()! as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Leaderboard fetch failed: $e');
      return [];
    }
  }

  /// Submit or update a score. Keeps only the user's personal best per mode.
  Future<void> submitScore({
    required String uid,
    required String displayName,
    String? photoUrl,
    required int score,
    required int highestTile,
    required LeaderboardMode mode,
  }) async {
    try {
      final docId = '${uid}_${mode.name}';
      final docRef = _ref.doc(docId);
      final existing = await docRef.get();

      if (existing.exists) {
        final data = existing.data() as Map<String, dynamic>;
        final prevScore = (data['score'] as num?)?.toInt() ?? 0;
        if (score <= prevScore) return;
      }

      await docRef.set({
        'uid': uid,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'score': score,
        'highestTile': highestTile,
        'mode': mode.name,
        'submittedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Leaderboard submit failed: $e');
    }
  }

  /// Update displayName on all leaderboard entries for a given user.
  Future<void> updateDisplayName({
    required String uid,
    required String displayName,
  }) async {
    try {
      final snapshot = await _ref.where('uid', isEqualTo: uid).get();
      if (snapshot.docs.isEmpty) return;

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'displayName': displayName});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Leaderboard displayName update failed: $e');
    }
  }

  /// Get a specific user's rank for a given mode.
  Future<int?> getUserRank({
    required String uid,
    required LeaderboardMode mode,
  }) async {
    try {
      final docId = '${uid}_${mode.name}';
      final doc = await _ref.doc(docId).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      final userScore = (data['score'] as num).toInt();

      final higherCount = await _ref
          .where('mode', isEqualTo: mode.name)
          .where('score', isGreaterThan: userScore)
          .count()
          .get();

      return (higherCount.count ?? 0) + 1;
    } catch (e) {
      debugPrint('Rank fetch failed: $e');
      return null;
    }
  }
}
