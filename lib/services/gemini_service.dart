import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API key not found in .env file');
    }
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // Supports audio
      apiKey: apiKey,
    );
  }

  Future<String> transcribeAudio(File audioFile) async {
    try {
      final audioBytes = await audioFile.readAsBytes();
      final content = [
        Content.multi([
          DataPart('audio/m4a', audioBytes),
          TextPart('Transcribe this audio into text.'),
        ]),
      ];
      final response = await _model.generateContent(content);
      return response.text ?? 'No transcription available';
    } catch (e) {
      throw Exception('Error transcribing audio with Gemini: $e');
    }
  }
}
