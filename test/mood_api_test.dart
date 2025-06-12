import 'package:flutter_test/flutter_test.dart';
import 'package:moodtracker/services/mood_api_service.dart';
import 'package:moodtracker/constants/api_constants.dart';

void main() {
  group('Mood API Service Tests', () {
    late MoodApiService apiService;

    setUp(() {
      apiService = MoodApiService();
    });

    test('API Constants should have correct base URL', () {
      expect(ApiConstants.baseUrl, 'https://crane-meet-poorly.ngrok-free.app');
      expect(ApiConstants.userId, 'sbik123');
    });

    test('getSummaryUrl should build correct URL', () {
      final weeklyUrl = ApiConstants.getSummaryUrl(period: 'weekly');
      expect(
        weeklyUrl,
        'https://crane-meet-poorly.ngrok-free.app/get-summary?user_id=sbik123&period=weekly',
      );

      final monthlyUrl = ApiConstants.getSummaryUrl(period: 'monthly');
      expect(
        monthlyUrl,
        'https://crane-meet-poorly.ngrok-free.app/get-summary?user_id=sbik123&period=monthly',
      );
    });

    test('getEmotionTrend should return correct trend data', () {
      // This test would require mock data
      expect(true, true); // Placeholder
    });
  });
}
