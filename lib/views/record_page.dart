import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/audio_controller.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late AudioController _controller;
  DateTime selectedDate = DateTime.now();
  final TextEditingController _textController = TextEditingController();
  bool _isTranscribing = false;
  bool _isConfirmMode = false;
  String _audioFilePath = '';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AudioController();
    _controller.setStateCallback = setState;
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveOrConfirm(BuildContext context) async {
    if (_isConfirmMode) {
      // Confirm and save the note, then navigate back
     //Call api to save the audio to cloud
     

      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      // Start transcription and show it in the text box
      setState(() {
        _isTranscribing = true;
      });
      // await _controller.saveAndTranscribeRecording(
      //   context,
      // ); // Transcribe the audio

      final String audioFilePath = await _controller.saveAndReturnPath(context);
      setState(() {
        _textController.text = _controller.audioModel.transcribedText;
        _isTranscribing = false;
        _isConfirmMode = true;
        _audioFilePath = audioFilePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DAILY JOURNAL',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Date Picker
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEE, M/d/y').format(selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.calendar_today, size: 20),
                    Spacer(),
                    Container(
                      alignment: Alignment.center,
                      width: 100,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        selectedDate.day == DateTime.now().day &&
                                selectedDate.month == DateTime.now().month &&
                                selectedDate.year == DateTime.now().year
                            ? 'Today'
                            : 'Selected Date',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Record Button
            GestureDetector(
              onTap:
                  _controller.isRecording
                      ? _controller.stopRecording
                      : _controller.startRecording,
              child: Column(
                children: [
                  Icon(
                    _controller.isRecording ? Icons.stop_circle : Icons.mic,
                    size: 60,
                    color: _controller.isRecording ? Colors.red : Colors.black,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _controller.isRecording ? 'recording' : 'tap to record',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Playback Controls
            if (_controller.audioModel.filePath != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed:
                        _controller.audioModel.filePath != null &&
                                !_controller.isRecording
                            ? () {
                              _controller.playRecording();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Playing recording'),
                                ),
                              );
                            }
                            : null,
                    iconSize: 40,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed:
                        _controller.isPlaying
                            ? () {
                              _controller.pauseRecording();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Paused playback'),
                                ),
                              );
                            }
                            : null,
                    iconSize: 40,
                  ),
                  const SizedBox(width: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('PLAY', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            const Spacer(),

            // Editable Text Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  _isTranscribing
                      ? const Center(child: CircularProgressIndicator())
                      : TextField(
                        controller: _textController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Transcription will appear here...',
                          border: InputBorder.none,
                        ),
                      ),
            ),
            const SizedBox(height: 16),

            // Save/Confirm Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed:
                      _controller.audioModel.filePath != null &&
                              !_controller.isRecording
                          ? () => _handleSaveOrConfirm(context)
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back),
                      const SizedBox(width: 10),
                      Text(
                        _isConfirmMode
                            ? 'CONFIRM SAVE NOTE'
                            : 'SAVE DAILY NOTE',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
