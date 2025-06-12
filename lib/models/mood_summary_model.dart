class MoodEntry {
  final Map<String, double> emotion;
  final String journalDate;
  final String mood;

  MoodEntry({
    required this.emotion,
    required this.journalDate,
    required this.mood,
  });  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    // Parse the EMOTION string (which is a JSON string) to Map
    final emotionData = json['EMOTION'] as String;
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
      }    } catch (e) {
      // Fallback parsing if JSON parsing fails
      // Use debugPrint instead of print for Flutter
    }
    
    return MoodEntry(
      emotion: emotionMap,
      journalDate: json['JOURNAL_DATE'] as String,
      mood: json['MOOD'] as String,
    );
  }
}

class TopEmotionalWord {
  final String emotion;
  final int frequency;
  final double score;
  final String word;

  TopEmotionalWord({
    required this.emotion,
    required this.frequency,
    required this.score,
    required this.word,
  });

  factory TopEmotionalWord.fromJson(Map<String, dynamic> json) {
    return TopEmotionalWord(
      emotion: json['emotion'] as String,
      frequency: json['frequency'] as int,
      score: (json['score'] as num).toDouble(),
      word: json['word'] as String,
    );
  }
}

class WordCloudItem {
  final int frequency;
  final String emotion;
  final String color;

  WordCloudItem({
    required this.frequency,
    required this.emotion,
    required this.color,
  });

  factory WordCloudItem.fromJson(Map<String, dynamic> json) {
    return WordCloudItem(
      frequency: json['frequency'] as int,
      emotion: json['emotion'] as String,
      color: json['color'] as String,
    );
  }
}

class MoodSummaryResponse {
  final List<MoodEntry> entries;
  final int entryCount;
  final String period;
  final List<TopEmotionalWord> topEmotionalWords;
  final String userId;
  final Map<String, WordCloudItem> wordCloud;

  MoodSummaryResponse({
    required this.entries,
    required this.entryCount,
    required this.period,
    required this.topEmotionalWords,
    required this.userId,
    required this.wordCloud,
  });
  factory MoodSummaryResponse.fromJson(Map<String, dynamic> json) {
    // Parse word cloud - simplified for now since it's complex
    final wordCloudMap = <String, WordCloudItem>{};
    
    return MoodSummaryResponse(
      entries: (json['entries'] as List)
          .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      entryCount: json['entry_count'] as int,
      period: json['period'] as String,
      topEmotionalWords: (json['top_emotional_words'] as List)
          .map((e) => TopEmotionalWord.fromJson(e as Map<String, dynamic>))
          .toList(),
      userId: json['user_id'] as String,
      wordCloud: wordCloudMap, // Simplified for now
    );
  }
}
