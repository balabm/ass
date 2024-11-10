// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  FirebaseService({required this.userId});

  Future<void> saveFormProcessingSession({
    required String ocrText,
    String? asrResponse,
    required String llmResponse,
    required String question,
    required DateTime timestamp,
  }) async {
    try {
      await _firestore.collection('form_processing_sessions').add({
        'userId': userId,
        'ocrText': ocrText,
        'asrResponse': asrResponse,
        'llmResponse': llmResponse,
        'question': question,
        'timestamp': timestamp,
      });
    } catch (e) {
      print('Error saving session: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getUserSessions() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('form_processing_sessions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching sessions: $e');
      throw e;
    }
  }
}
