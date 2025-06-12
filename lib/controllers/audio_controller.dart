import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/audio_model.dart';
import '../services/gemini_service.dart';
import '../services/mood_api_service.dart';
import '../constants/api_constants.dart';
import '../models/analyze_entry_model.dart';

class AudioController {
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final GeminiService _geminiService = GeminiService();
  final MoodApiService _moodApiService = MoodApiService();
  StreamSubscription<PlayerState>? _playerStateSubscription;

  AudioModel audioModel = AudioModel();
  bool _speechEnabled = false;
  bool _realTimeSpeechEnabled = false;
  String _realTimeLastWords = '';
  bool _isListeningRealTime = false;
  bool _isRecording = false;
  bool _isPlaying = false;

  void Function(void Function())? setStateCallback;

  AudioController() {
    _initSpeech();
    _initPlayer();
  }

  void setState(void Function() callback) {
    setStateCallback?.call(callback);
  }

  Future<void> _initSpeech() async {
    debugPrint("_initSpeech called");
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (error) => _handleSpeechError(error),
        onStatus: (status) => debugPrint("STT status: $status"),
      );
      _realTimeSpeechEnabled = _speechEnabled;
      debugPrint(
        "_speechEnabled: $_speechEnabled, _realTimeSpeechEnabled: $_realTimeSpeechEnabled",
      );
      setState(() {});
    } catch (e) {
      debugPrint("Exception in _initSpeech: $e");
      _handleSpeechError(e);
    }
  }

  void _handleSpeechError(dynamic error) {
    setState(() {
      _speechEnabled = false;
      _realTimeSpeechEnabled = false;
    });
    debugPrint("Speech error: $error");
  }

  Future<void> _initPlayer() async {
    _playerStateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  Future<void> startRealTimeListening() async {
    debugPrint("_startRealTimeListening called");
    if (!_realTimeSpeechEnabled) return;

    try {
      if (!_speechToText.isAvailable) {
        debugPrint("SpeechToText is not available.");
        return;
      }
      await _speechToText.listen(
        onResult: _onRealTimeSpeechResult,
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
        ),
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(minutes: 5),
      );
      setState(() => _isListeningRealTime = true);
    } catch (e) {
      setState(() {
        _isListeningRealTime = false;
        _realTimeLastWords = "Error during live transcription: $e";
      });
      debugPrint("Error during live transcription: $e");
    }
  }

  Future<void> stopRealTimeListening() async {
    await _speechToText.stop();
    setState(() => _isListeningRealTime = false);
  }

  void _onRealTimeSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _realTimeLastWords = result.recognizedWords;
    });
  }

  Future<void> startRecording() async {
    if (_isRecording) return;

    Directory tempDir = await getTemporaryDirectory();
    audioModel = audioModel.copyWith(
      filePath: '${tempDir.path}/audio_recording.m4a',
    );

    if (await audioRecorder.hasPermission()) {
      await audioRecorder.start(
        const RecordConfig(),
        path: audioModel.filePath!,
      );
      setState(() {
        _isRecording = true;
        audioModel = audioModel.copyWith(transcribedText: '');
      });
    }
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;
    await audioRecorder.stop();
    setState(() => _isRecording = false);
  }

  Future<void> playRecording() async {
    if (audioModel.filePath == null || _isPlaying) return;
    await audioPlayer.play(DeviceFileSource(audioModel.filePath!));
    setState(() => _isPlaying = true);
  }

  Future<void> pauseRecording() async {
    if (!_isPlaying) return;
    await audioPlayer.pause();
    setState(() => _isPlaying = false);
  }

  Future<void> saveAndTranscribeRecording(BuildContext context) async {
    debugPrint('Transcribing audio from ${audioModel.filePath}');
    if (audioModel.filePath == null) return;

    Directory? externalDir;

    if (defaultTargetPlatform == TargetPlatform.android) {
      externalDir = await getExternalStorageDirectory();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      externalDir = await getApplicationDocumentsDirectory();
    }

    if (externalDir == null) {
      debugPrint("Unable to determine external directory.");
      return;
    }
    String newPath =
        '${externalDir.path}/saved_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await File(audioModel.filePath!).copy(newPath);

    try {
      final transcribedText = await _geminiService.transcribeAudio(
        File(audioModel.filePath!),
      );
      setState(() {
        audioModel = audioModel.copyWith(transcribedText: transcribedText);
        debugPrint("Transcribed text: $transcribedText");
      });
    } catch (e) {
      setState(() {
        audioModel = audioModel.copyWith(
          transcribedText: "Error transcribing audio: $e",
        );
      });
      debugPrint("Error transcribing audio: $e");
    }

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Audio saved to $newPath')));
    }
  }

  Future<String> saveAndReturnPath(BuildContext context) async {
    debugPrint('Transcribing audio from ${audioModel.filePath}');
    if (audioModel.filePath == null) return '';

    Directory? externalDir;

    if (defaultTargetPlatform == TargetPlatform.android) {
      externalDir = await getExternalStorageDirectory();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      externalDir = await getApplicationDocumentsDirectory();
    }

    if (externalDir == null) {
      debugPrint("Unable to determine external directory.");
      return '';
    }
    String newPath =
        '${externalDir.path}/saved_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await File(audioModel.filePath!).copy(newPath);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Audio saved to $newPath')));
    }
    return newPath;
  }

  // Save audio and analyze it using the cloud API
  Future<AnalyzeEntryResponse?> saveAndAnalyzeAudio(
    BuildContext context,
  ) async {
    debugPrint('Saving and analyzing audio from ${audioModel.filePath}');
    if (audioModel.filePath == null) return null;

    try {
      // First transcribe the audio locally
      final transcribedText = await _geminiService.transcribeAudio(
        File(audioModel.filePath!),
      );

      setState(() {
        audioModel = audioModel.copyWith(transcribedText: transcribedText);
      });

      // Then upload to cloud for analysis
      final result = await _moodApiService.analyzeEntry(
        File(audioModel.filePath!),
        ApiConstants.userId,
      );

      debugPrint('Audio analysis completed successfully');
      debugPrint('Sentiment: ${result.sentiment}');
      debugPrint('Emotions: ${result.emotion}');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio analyzed! Sentiment: ${result.sentiment}'),
            backgroundColor:
                result.sentiment == 'Positive'
                    ? Colors.green
                    : result.sentiment == 'Negative'
                    ? Colors.red
                    : Colors.orange,
          ),
        );
      }

      return result;
    } catch (e) {
      debugPrint('Error analyzing audio: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  void dispose() {
    audioRecorder.dispose();
    audioPlayer.dispose();
    _playerStateSubscription?.cancel();
    _speechToText.cancel();
  }

  // Getters for UI
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  bool get isListeningRealTime => _isListeningRealTime;
  bool get realTimeSpeechEnabled => _realTimeSpeechEnabled;
  String get realTimeLastWords => _realTimeLastWords;
}
