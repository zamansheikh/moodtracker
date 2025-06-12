class ApiConstants {
  static const String baseUrl = 'https://crane-meet-poorly.ngrok-free.app';
  static const String getSummaryEndpoint = '/get-summary';
  static const String analyzeEntryEndpoint = '/analyze-entry';

  // User ID - you can make this dynamic later
  static const String userId = 'sbik123';

  // Helper methods to build URLs
  static String getSummaryUrl({String period = 'weekly'}) {
    return '$baseUrl$getSummaryEndpoint?user_id=$userId&period=$period';
  }

  static String get analyzeEntryUrl => '$baseUrl$analyzeEntryEndpoint';
}
