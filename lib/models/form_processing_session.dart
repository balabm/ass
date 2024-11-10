// lib/models/form_processing_session.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FormProcessingSession {
  final String userId;
  final String ocrText;
  final String? asrResponse;
  final String llmResponse;
  final String question;
  final DateTime timestamp;

  FormProcessingSession({
    required this.userId,
    required this.ocrText,
    this.asrResponse,
    required this.llmResponse,
    required this.question,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'ocrText': ocrText,
      'asrResponse': asrResponse,
      'llmResponse': llmResponse,
      'question': question,
      'timestamp': timestamp,
    };
  }

  factory FormProcessingSession.fromMap(Map<String, dynamic> map) {
    return FormProcessingSession(
      userId: map['userId'],
      ocrText: map['ocrText'],
      asrResponse: map['asrResponse'],
      llmResponse: map['llmResponse'],
      question: map['question'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
