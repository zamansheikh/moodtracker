import 'package:flutter/foundation.dart';

class AnalyzeEntryResponse {
  final Map<String, double> emotion;
  final String sentiment;
  final String userId;
  final Map<String, WordCloudEntry> wordCloud;

  AnalyzeEntryResponse({
    required this.emotion,
    required this.sentiment,
    required this.userId,
    required this.wordCloud,
  });

  factory AnalyzeEntryResponse.fromJson(Map<String, dynamic> json) {
    // Parse emotion data
    final emotionData = json['emotion'] as String;
    final emotionMap = <String, double>{};

    try {
      // Simple manual parsing since the format is predictable
      final cleanEmotion = emotionData.replaceAll(RegExp(r'[{}"]'), '');
      final emotionPairs = cleanEmotion.split(', ');

      for (String pair in emotionPairs) {
        final keyValue = pair.split(': ');
        if (keyValue.length == 2) {
          final key = keyValue[0].trim();
          final value = double.tryParse(keyValue[1].trim()) ?? 0.0;
          emotionMap[key] = value;
        }
      }
    } catch (e) {
      debugPrint('Error parsing emotion data: $e');
    }

    // Parse word cloud data
    final wordCloudData = json['word_cloud'] as String;
    final wordCloudMap = <String, WordCloudEntry>{};

    try {
      // This is a simplified parsing - in production you might want more robust JSON parsing
      // For now, we'll extract the basic structure
      debugPrint('Word cloud data received: $wordCloudData');
    } catch (e) {
      debugPrint('Error parsing word cloud data: $e');
    }

    return AnalyzeEntryResponse(
      emotion: emotionMap,
      sentiment: json['sentiment'] as String,
      userId: json['userid'] as String,
      wordCloud: wordCloudMap,
    );
  }
}

class WordCloudEntry {
  final int frequency;
  final String emotion;
  final String color;

  WordCloudEntry({
    required this.frequency,
    required this.emotion,
    required this.color,
  });

  factory WordCloudEntry.fromJson(Map<String, dynamic> json) {
    return WordCloudEntry(
      frequency: json['frequency'] as int,
      emotion: json['emotion'] as String,
      color: json['color'] as String,
    );
  }
}
