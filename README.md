# Mood Tracker

An AI-powered Flutter mood tracking application that integrates with a backend API to display real-time mood analytics and trends.

## Features

- **Real-time Mood Data**: Fetches mood summary data from API
- **Interactive Charts**: Visual representation of stress and joy levels over time
- **Period Selection**: Switch between weekly and monthly data views
- **Mood Analytics**: Displays mood improvement percentages and emotional word analysis
- **Audio Recording & Analysis**: Record daily diary entries with AI transcription and emotion analysis
- **Cloud Integration**: Upload audio for sentiment analysis and emotion detection
- **Error Handling**: Graceful handling of network issues and API errors

## API Integration

The app integrates with a mood analytics API:

**Base URL**: `https://crane-meet-poorly.ngrok-free.app`

### Endpoints Used

- `GET /get-summary?user_id=sbik123&period=weekly`
- `GET /get-summary?user_id=sbik123&period=monthly`  
- `POST /analyze-entry` (multipart form upload)

### API Response Structure

**Get Summary Response:**
```json
{
  "entries": [
    {
      "EMOTION": "{\"sadness\": 0.5545, \"joy\": 0.0009, ...}",
      "JOURNAL_DATE": "2025-06-06",
      "MOOD": "Negative"
    }
  ],
  "entry_count": 7,
  "period": "weekly",
  "top_emotional_words": [
    {
      "emotion": "positive",
      "frequency": 10,
      "score": 0.5994,
      "word": "solution"
    }
  ],
  "user_id": "sbik123",
  "word_cloud": "{...}"
}
```

**Analyze Entry Response:**
```json
{
  "emotion": "{\"sadness\": 0.0005, \"joy\": 0.9984, \"love\": 0.0006, ...}",
  "sentiment": "Positive",
  "userid": "sbik123",
  "word_cloud": "{\"happy\": {\"frequency\": 5, \"emotion\": \"positive\", \"color\": \"green\"}, ...}"
}
```

## Project Structure

```
lib/
├── constants/
│   └── api_constants.dart          # API URLs and configuration
├── models/
│   ├── mood_summary_model.dart     # Data models for API responses
│   └── analyze_entry_model.dart    # Models for audio analysis API
├── services/
│   ├── mood_api_service.dart       # HTTP service for API calls
│   └── gemini_service.dart         # AI transcription service
├── controllers/
│   └── audio_controller.dart       # Audio recording and analysis logic
├── views/
│   ├── dashboard_page.dart         # Main dashboard with mood data
│   ├── record_page.dart            # Audio recording and analysis page
│   └── widgets/
│       └── mood_trend_chart.dart   # Chart widget for trends
└── main.dart                       # App entry point
```

## Dependencies

- `http: ^1.2.0` - HTTP requests to mood API
- `fl_chart: ^0.70.2` - Interactive charts for mood trends
- `flutter_dotenv: ^5.2.1` - Environment variables
- `google_generative_ai: ^0.4.6` - AI transcription
- `audioplayers: ^6.4.0` - Audio playback
- `record: ^6.0.0` - Audio recording
- `speech_to_text: ^7.0.0` - Speech recognition

## Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd moodtracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   Create a `.env` file in the root directory:
   ```
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Configuration

### API Configuration

The API configuration is centralized in `lib/constants/api_constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'https://crane-meet-poorly.ngrok-free.app';
  static const String userId = 'sbik123';
  
  static String getSummaryUrl({String period = 'weekly'}) {
    return '$baseUrl/get-summary?user_id=$userId&period=$period';
  }
}
```

### Changing the API URL

To update the API URL (e.g., when ngrok URL changes), modify the `baseUrl` in `ApiConstants`.

## Features in Detail

### Dashboard

- **Period Selector**: Toggle between weekly and monthly data
- **Mood Trends**: Line charts showing stress and joy levels over time
- **Mood Summary**: 
  - Top emotional words with frequency
  - Mood distribution (Positive/Negative/Neutral)
  - Mood improvement percentage
  - Total entry count

### Recording and Analysis

- **Two-step Process**: Record → Transcribe → Analyze
- **Local Transcription**: Uses Gemini AI for speech-to-text
- **Cloud Analysis**: Uploads audio for emotion and sentiment analysis
- **Results Display**: Shows analysis results in user-friendly dialog
- **Error Handling**: Graceful handling of transcription and analysis failures

### Real-time Data Loading

- Loading states with progress indicators
- Error handling with retry functionality
- Automatic data refresh when period changes
- Debug logging for API requests

### Data Processing

- Emotion data parsing from JSON strings
- Trend calculation for chart visualization
- Mood improvement percentage calculation
- Word frequency analysis

## Testing

Run the test suite:

```bash
flutter test
```

The project includes:
- **Unit tests** for API service functionality
- **Widget tests** for UI components
- **Integration tests** for API constants

## Error Handling

The app gracefully handles:
- Network connectivity issues
- API server downtime
- Invalid response formats
- Timeout errors
- Rate limiting

Error states show:
- Clear error messages
- Retry buttons
- Fallback content when data unavailable

## Development

### Adding New API Endpoints

1. Add endpoint constants to `ApiConstants`
2. Create corresponding methods in `MoodApiService`
3. Add data models if needed
4. Update UI components to use new data

### Debugging API Issues

Enable debug logging by checking console output for:
- `Making API request to: <URL>`
- `API Response status: <status>`
- `Successfully parsed JSON data`

## Platform Support

- ✅ Windows (primary development target)
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ macOS
- ✅ Linux

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.
