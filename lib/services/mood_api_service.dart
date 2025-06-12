import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/mood_summary_model.dart';
import '../models/analyze_entry_model.dart';

class MoodApiService {
  static const Duration _timeout = Duration(seconds: 30);
  Future<MoodSummaryResponse> getMoodSummary({String period = 'weekly'}) async {
    try {
      final url = ApiConstants.getSummaryUrl(period: period);
      debugPrint('Making API request to: $url'); // Debug log

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning':
                  'true', // Skip ngrok browser warning
            },
          )
          .timeout(_timeout);

      debugPrint('API Response status: ${response.statusCode}'); // Debug log
      debugPrint(
        'API Response body length: ${response.body.length}',
      ); // Debug log

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint('Successfully parsed JSON data'); // Debug log
        return MoodSummaryResponse.fromJson(jsonData);
      } else {
        debugPrint(
          'API Error: ${response.statusCode} - ${response.body}',
        ); // Debug log
        throw Exception('Failed to load mood summary: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception in getMoodSummary: $e'); // Debug log
      throw Exception('Error fetching mood summary: $e');
    }
  }

  // Helper method to calculate emotion trends for charts
  List<double> getEmotionTrend(List<MoodEntry> entries, String emotionType) {
    return entries.map((entry) {
      return entry.emotion[emotionType] ?? 0.0;
    }).toList();
  }

  // Helper method to get mood distribution
  Map<String, int> getMoodDistribution(List<MoodEntry> entries) {
    final Map<String, int> distribution = {};
    for (final entry in entries) {
      distribution[entry.mood] = (distribution[entry.mood] ?? 0) + 1;
    }
    return distribution;
  }

  // Calculate mood improvement percentage (simplified)
  double calculateMoodImprovement(List<MoodEntry> entries) {
    if (entries.length < 2) return 0.0;

    final recentEntries = entries.take(entries.length ~/ 2).toList();
    final olderEntries = entries.skip(entries.length ~/ 2).toList();

    final recentPositive =
        recentEntries.where((e) => e.mood == 'Positive').length;
    final olderPositive =
        olderEntries.where((e) => e.mood == 'Positive').length;

    if (olderEntries.isEmpty) return 0.0;

    final recentPercentage = recentPositive / recentEntries.length;
    final olderPercentage = olderPositive / olderEntries.length;
    return ((recentPercentage - olderPercentage) * 100);
  }

  // Analyze audio entry by uploading audio file
  Future<AnalyzeEntryResponse> analyzeEntry(
    File audioFile,
    String userId,
  ) async {
    try {
      final url = ApiConstants.analyzeEntryUrl;
      debugPrint('Making analyze entry request to: $url');

      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add the audio file
      request.files.add(
        await http.MultipartFile.fromPath('audio', audioFile.path),
      );

      // Add user_id parameter
      request.fields['user_id'] = userId;

      // Add headers
      request.headers.addAll({'ngrok-skip-browser-warning': 'true'});

      debugPrint('Uploading audio file: ${audioFile.path}');
      debugPrint('User ID: $userId');

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Analyze entry response status: ${response.statusCode}');
      debugPrint('Analyze entry response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint('Successfully parsed analyze entry JSON data');
        return AnalyzeEntryResponse.fromJson(jsonData);
      } else {
        debugPrint(
          'Analyze entry API Error: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to analyze entry: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception in analyzeEntry: $e');
      throw Exception('Error analyzing entry: $e');
    }
  }
}
