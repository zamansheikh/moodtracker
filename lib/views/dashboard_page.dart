import 'package:flutter/material.dart';
import 'package:moodtracker/views/widgets/mood_trend_chart.dart';
import '../services/mood_api_service.dart';
import '../models/mood_summary_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final MoodApiService _apiService = MoodApiService();
  MoodSummaryResponse? _moodSummary;
  bool _isLoading = true;
  String? _error;
  String _selectedPeriod = 'weekly'; // Add period selector
  @override
  void initState() {
    super.initState();
    _loadMoodData();
  }

  Future<void> _loadMoodData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      debugPrint('Loading mood data from API...');
      final moodData = await _apiService.getMoodSummary(
        period: _selectedPeriod,
      );
      debugPrint('Successfully loaded ${moodData.entries.length} mood entries');

      setState(() {
        _moodSummary = moodData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading mood data: $e');
      setState(() {
        _error = 'Failed to load mood data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'WELCOME USER',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMoodData),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your mood data...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMoodData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector
          _buildPeriodSelector(),
          const SizedBox(height: 20),

          // Daily Diary (Record) Button
          _buildRecordButton(),
          const SizedBox(height: 20),

          // Latest Mood Trends
          _buildMoodTrends(),
          const SizedBox(height: 20),

          // Mood Summary
          _buildMoodSummary(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Data Period:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          DropdownButton<String>(
            value: _selectedPeriod,
            underline: Container(),
            items: const [
              DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
            ],
            onChanged: (String? newValue) {
              if (newValue != null && newValue != _selectedPeriod) {
                setState(() {
                  _selectedPeriod = newValue;
                });
                _loadMoodData();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/record');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'DAILY DIARY (RECORD)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Click to record',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodTrends() {
    if (_moodSummary == null || _moodSummary!.entries.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LATEST MOOD TRENDS',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('No mood data available yet. Start recording your daily diary!'),
        ],
      );
    }

    // Get emotion trends from API data
    final stressData =
        _apiService
            .getEmotionTrend(_moodSummary!.entries, 'stress')
            .map((e) => e * 5) // Scale to 0-5 range for chart
            .toList();
    final joyData =
        _apiService
            .getEmotionTrend(_moodSummary!.entries, 'joy')
            .map((e) => e * 5) // Scale to 0-5 range for chart
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LATEST MOOD TRENDS (${_moodSummary!.period.toUpperCase()})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: MoodTrendChart(
                title: 'STRESS',
                data: stressData,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MoodTrendChart(
                title: 'JOY',
                data: joyData,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoodSummary() {
    if (_moodSummary == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MOOD SUMMARY',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('No data available yet.'),
          ],
        ),
      );
    }

    final moodImprovement = _apiService.calculateMoodImprovement(
      _moodSummary!.entries,
    );
    final topWords = _moodSummary!.topEmotionalWords.take(5).toList();
    final moodDistribution = _apiService.getMoodDistribution(
      _moodSummary!.entries,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MOOD SUMMARY',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Top emotional words
          if (topWords.isNotEmpty) ...[
            const Text(
              '• Top emotional words:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children:
                  topWords
                      .map(
                        (word) => Chip(
                          label: Text(
                            '${word.word} (${word.frequency})',
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: _getEmotionColor(word.emotion),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 10),
          ],

          // Mood distribution
          if (moodDistribution.isNotEmpty) ...[
            const Text(
              '• Mood distribution:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            ...moodDistribution.entries.map(
              (entry) => Text(
                '  ${entry.key}: ${entry.value} entries',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Mood improvement
          Text(
            moodImprovement >= 0
                ? 'Your mood has improved ${moodImprovement.toStringAsFixed(1)}% this ${_moodSummary!.period}'
                : 'Your mood has declined ${moodImprovement.abs().toStringAsFixed(1)}% this ${_moodSummary!.period}',
            style: TextStyle(
              color: moodImprovement >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),
          Text(
            'Total entries: ${_moodSummary!.entryCount}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'positive':
        return Colors.green.shade100;
      case 'negative':
        return Colors.red.shade100;
      case 'neutral':
        return Colors.grey.shade100;
      default:
        return Colors.blue.shade100;
    }
  }
}
