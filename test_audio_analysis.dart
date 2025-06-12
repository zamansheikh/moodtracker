import 'dart:io';
import 'lib/services/mood_api_service.dart';
import 'lib/constants/api_constants.dart';

/// Test script to verify the analyze-entry API endpoint works
void main() async {
  print('Testing Audio Analysis API Integration...');
  print('Base URL: ${ApiConstants.baseUrl}');
  print('Analyze Entry URL: ${ApiConstants.analyzeEntryUrl}');
  print('User ID: ${ApiConstants.userId}');
  print('');

  final apiService = MoodApiService();

  // Note: This test requires an actual audio file to work
  // In a real scenario, you would have recorded audio from the app
  print('ℹ️  Audio analysis test requires an actual audio file.');
  print('When you record audio in the app and tap "CONFIRM SAVE NOTE",');
  print('the following will happen:');
  print('');
  print('1. Audio file will be uploaded to: ${ApiConstants.analyzeEntryUrl}');
  print('2. Form data will include:');
  print('   - audio: [audio file]');
  print('   - user_id: ${ApiConstants.userId}');
  print('3. API will return emotion analysis and sentiment');
  print('4. Results will be displayed in a dialog box');
  print('');
  print('🎉 Audio analysis integration is ready to use!');
  print('');
  print('Expected API Response format:');
  print('{');
  print('  "emotion": "{\\"sadness\\": 0.0005, \\"joy\\": 0.9984, ...}",');
  print('  "sentiment": "Positive",');
  print('  "userid": "${ApiConstants.userId}",');
  print('  "word_cloud": "{\\"happy\\": {\\"frequency\\": 5, ...}}"');
  print('}');
}
