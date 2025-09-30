import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // Create a new habit
  Future<void> createHabit(
    String uid,
    String habitTitle, {
    String frequency = 'Daily',
  }) async {
    await _db.collection('habits').add({
      'ownerId': uid,
      'habitTitle': habitTitle,
      'streak': 0,
      'frequency': frequency,
      'createdAt': FieldValue.serverTimestamp(),
      'lastChecked': null,
      'points': 0,
    });
  }

  // Get user habits
  Stream<QuerySnapshot> getUserHabits(String uid) {
    return _db
        .collection('habits')
        .where('ownerId', isEqualTo: uid)
        .snapshots();
  }

  // Update streak (simple version)
  Future<void> checkInHabit(String habitId, int newStreak) async {
    await _db.collection('habits').doc(habitId).update({
      'streak': newStreak,
      'lastChecked': DateTime.now().toIso8601String(),
    });
  }

  // ✅ Gamification: Update user points & badges
  Future<void> updateUserPoints(String uid, int pointsToAdd) async {
    final userRef = _db.collection('users').doc(uid);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);

      if (!snapshot.exists) {
        transaction.set(userRef, {'points': pointsToAdd, 'badges': []});
      } else {
        final data = snapshot.data() as Map<String, dynamic>;
        final currentPoints = data['points'] ?? 0;
        final newPoints = currentPoints + pointsToAdd;

        // Badge logic
        List<String> badges = List<String>.from(data['badges'] ?? []);
        if (newPoints >= 100 && !badges.contains("Starter")) {
          badges.add("Starter");
        }
        if (newPoints >= 500 && !badges.contains("Consistency Pro")) {
          badges.add("Consistency Pro");
        }

        transaction.update(userRef, {'points': newPoints, 'badges': badges});
      }
    });
  }

  // ✅ Get user profile (points + badges stream)
  Stream<DocumentSnapshot> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // Create a post
  Future<void> createPost(String uid, String text) async {
    await _db.collection('posts').add({
      'authorId': uid,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': 0,
    });
  }

  // Get feed posts
  Stream<QuerySnapshot> getPosts() {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getLeaderboardByHabit(String habitTitle) {
    return _db
        .collection('habits')
        .where('habitTitle', isEqualTo: habitTitle)
        .orderBy('points', descending: true)
        .limit(10) // top 10
        .snapshots();
  }
}
