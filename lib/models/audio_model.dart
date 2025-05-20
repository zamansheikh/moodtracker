class AudioModel {
  final String? filePath;
  final String transcribedText;

  AudioModel({this.filePath, this.transcribedText = ''});

  AudioModel copyWith({String? filePath, String? transcribedText}) {
    return AudioModel(
      filePath: filePath ?? this.filePath,
      transcribedText: transcribedText ?? this.transcribedText,
    );
  }
}
