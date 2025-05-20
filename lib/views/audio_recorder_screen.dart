import 'package:flutter/material.dart';
import '../controllers/audio_controller.dart';

class AudioRecorderScreen extends StatefulWidget {
  const AudioRecorderScreen({super.key});

  @override
  State<AudioRecorderScreen> createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen> {
  late AudioController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AudioController();
    _controller.setStateCallback = setState;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Recorder & Live Transcribe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Live Transcription Section
            const Text(
              'Live Speech to Text',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _controller.isListeningRealTime
                    ? _controller.realTimeLastWords
                    : _controller.realTimeSpeechEnabled
                    ? 'Tap the microphone below to start live transcription...'
                    : 'Live speech not available',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            FloatingActionButton(
              heroTag: 'liveMicButton',
              onPressed:
                  _controller.realTimeSpeechEnabled
                      ? _controller.isListeningRealTime
                          ? _controller.stopRealTimeListening
                          : _controller.startRealTimeListening
                      : null,
              tooltip: 'Live Listen',
              backgroundColor:
                  _controller.realTimeSpeechEnabled ? Colors.blue : Colors.grey,
              child: Icon(
                _controller.isListeningRealTime ? Icons.mic : Icons.mic_off,
              ),
            ),
            if (!_controller.realTimeSpeechEnabled)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Real-time speech initialization failed.',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 40),

            // Audio Recording Section
            const Text(
              'Audio Recorder',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  _controller.isRecording
                      ? _controller.stopRecording
                      : _controller.startRecording,
              child: Text(
                _controller.isRecording ? 'Stop Recording' : 'Start Recording',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed:
                      _controller.audioModel.filePath != null &&
                              !_controller.isRecording
                          ? _controller.playRecording
                          : null,
                  child: const Text('Play'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed:
                      _controller.isPlaying ? _controller.pauseRecording : null,
                  child: const Text('Pause'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  _controller.audioModel.filePath != null &&
                          !_controller.isRecording
                      ? () => _controller.saveAndTranscribeRecording(context)
                      : null,
              child: const Text('Save & Transcribe'),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _controller.audioModel.transcribedText.isNotEmpty
                    ? 'Transcribed Text: ${_controller.audioModel.transcribedText}'
                    : 'No transcription yet',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _controller.isRecording
                  ? 'Recording...'
                  : _controller.isPlaying
                  ? 'Playing...'
                  : 'Ready',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
