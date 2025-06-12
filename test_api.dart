import 'lib/services/mood_api_service.dart';
import 'lib/constants/api_constants.dart';

/// Simple script to test the API integration manually
void main() async {
  print('Testing Mood Tracker API Integration...');
  print('Base URL: ${ApiConstants.baseUrl}');
  print('User ID: ${ApiConstants.userId}');
  print('');

  final apiService = MoodApiService();

  try {
    print('Making API call for weekly data...');
    final weeklyData = await apiService.getMoodSummary(period: 'weekly');

    print('✅ Successfully retrieved data!');
    print('Period: ${weeklyData.period}');
    print('Entry count: ${weeklyData.entryCount}');
    print('User ID: ${weeklyData.userId}');
    print('Number of entries: ${weeklyData.entries.length}');
    print('Top emotional words: ${weeklyData.topEmotionalWords.length}');

    if (weeklyData.entries.isNotEmpty) {
      print('\nFirst entry details:');
      final firstEntry = weeklyData.entries.first;
      print('Date: ${firstEntry.journalDate}');
      print('Mood: ${firstEntry.mood}');
      print('Emotions: ${firstEntry.emotion}');
    }

    if (weeklyData.topEmotionalWords.isNotEmpty) {
      print('\nTop 3 emotional words:');
      for (int i = 0; i < 3 && i < weeklyData.topEmotionalWords.length; i++) {
        final word = weeklyData.topEmotionalWords[i];
        print(
          '${i + 1}. ${word.word} (${word.emotion}, frequency: ${word.frequency})',
        );
      }
    }

    print('\n🎉 API integration is working correctly!');
  } catch (e) {
    print('❌ Error testing API:');
    print(e.toString());
    print('\nThis might be expected if:');
    print('1. The ngrok URL has changed');
    print('2. The API server is not running');
    print('3. Network connectivity issues');
  }
}
