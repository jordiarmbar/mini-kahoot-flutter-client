import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<DocumentSnapshot> sessionStream(String pin) =>
      _db.collection('sessions').doc(pin).snapshots();

  Future<bool> joinSession(String pin, String playerName) async {
    var doc = await _db.collection('sessions').doc(pin).get();
    if (!doc.exists) return false;
    await _db
        .collection('sessions')
        .doc(pin)
        .collection('players')
        .doc(playerName)
        .set({'name': playerName, 'score': 0, 'hasAnsweredCurrent': false});
    return true;
  }

  Future<void> submitAnswer(
    String pin,
    String playerName,
    int scoreToAdd,
  ) async {
    var pRef = _db
        .collection('sessions')
        .doc(pin)
        .collection('players')
        .doc(playerName);
    await pRef.update({
      'score': FieldValue.increment(scoreToAdd),
      'hasAnsweredCurrent': true,
    });
  }
}
