import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';

import 'package:project_mini_games/ML_Components/camera_service.dart';
import 'package:project_mini_games/ML_Components/model.dart';

class EmotionDetectionPage extends StatefulWidget {
  const EmotionDetectionPage({Key? key}) : super(key: key);

  @override
  _EmotionDetectionPageState createState() => _EmotionDetectionPageState();
}

class _EmotionDetectionPageState extends State<EmotionDetectionPage> {
  final CameraService _cameraService = CameraService();
  final TFLiteService _tfliteService = TFLiteService();

  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = "";

  String _currentEmotion = "No emotion detected";
  double _confidence = 0.0;
  Map<String, double>? _allProbabilities;

  // ✅ Fully integrated variables
  String _attentionState = "Unknown";     // Attentive / Inattentive
  String _primaryEmotion = "Unknown";     // Happy / Sad / Disgust / Angry
  double _attentionConfidence = 0.0;
  double _emotionConfidence = 0.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    setState(() {
      _hasError = false;
      _isInitialized = false;
      _currentEmotion = "Initializing...";
    });

    try {
      await _tfliteService.initModel();

      _cameraService.onFrameCaptured = (Uint8List imageBytes) async {
        final result = await _tfliteService.runModel(imageBytes);
        if (!mounted) return;
        setState(() {
          if (result != null) {
            _currentEmotion = result['label'];
            _confidence = result['confidence'];
            _allProbabilities =
                Map<String, double>.from(result['allLabelsWithProbs']);
            _processEmotionResults(); // <-- derive attention & primary emotion
          } else {
            _currentEmotion = "Processing error";
            _confidence = 0.0;
            _allProbabilities = null;
            _attentionState = "Unknown";
            _primaryEmotion = "Unknown";
            _attentionConfidence = 0.0;
            _emotionConfidence = 0.0;
          }
        });
      };

      await _cameraService.setupCameraController();
      _cameraService.startImageStream(); // 2 FPS throttled in service

      if (!mounted) return;
      setState(() {
        _isInitialized = true;
        _hasError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isInitialized = false;
      });
    }
  }

  void _retryInitialization() {
    _initializeServices();
  }

  // Split attention vs. emotion, compute confidences
  void _processEmotionResults() {
    if (_allProbabilities == null) return;

    final Map<String, double> attentionStates = {};
    final Map<String, double> emotions = {};

    for (final entry in _allProbabilities!.entries) {
      final k = entry.key.toLowerCase();
      if (k.contains('attentive') || k.contains('inattentive')) {
        attentionStates[entry.key] = entry.value;
      } else {
        emotions[entry.key] = entry.value;
      }
    }

    if (attentionStates.isNotEmpty) {
      final bestA = attentionStates.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      _attentionState = bestA.key;
      _attentionConfidence = bestA.value;
    } else {
      _attentionState = "Unknown";
      _attentionConfidence = 0.0;
    }

    if (emotions.isNotEmpty) {
      final bestE = emotions.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      _primaryEmotion = bestE.key;
      _emotionConfidence = bestE.value;
    } else {
      _primaryEmotion = "Unknown";
      _emotionConfidence = 0.0;
    }
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'attentive':
        return Colors.green;
      case 'inattentive':
        return Colors.orange;
      case 'happy':
        return Colors.blue;
      case 'sad':
        return Colors.indigo;
      case 'disgust':
        return Colors.brown;
      case 'angry':
        return Colors.red;
      default:
        return Colors.deepPurple;
    }
  }

  IconData _getEmotionIcon(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'attentive':
        return Icons.visibility;
      case 'inattentive':
        return Icons.visibility_off;
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'disgust':
        return Icons.sentiment_dissatisfied;
      case 'angry':
        return Icons.sentiment_neutral;
      default:
        return Icons.face;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion Detection'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _hasError
          ? _buildErrorScreen()
          : _isInitialized
              ? _buildMainContent()
              : _buildLoadingWidget(),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 80),
              const SizedBox(height: 20),
              const Text(
                'Initialization Failed',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                        child: const Text('Go Back'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ElevatedButton(
                        onPressed: _retryInitialization,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                        child: const Text('Retry'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading model and camera...', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Camera Preview on Top
        Expanded(
          flex: 2,
          child: SizedBox(
            width: double.infinity,
            child: _cameraService.cameraController != null &&
                    _cameraService.cameraController!.value.isInitialized
                ? CameraPreview(_cameraService.cameraController!)
                : _buildCameraErrorWidget(),
          ),
        ),

        // Results on Bottom
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: _buildResultsWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraErrorWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 60),
              const SizedBox(height: 20),
              const Text(
                'Camera Not Available',
                style: TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ElevatedButton(
                        onPressed: _retryInitialization,
                        child: const Text('Retry'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsWidget() {
    if (_currentEmotion.toLowerCase().contains("error")) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning, color: Colors.orange, size: 50),
            const SizedBox(height: 16),
            Text(
              _currentEmotion,
              style: const TextStyle(fontSize: 18, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _retryInitialization,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final emotionColor = _getEmotionColor(_currentEmotion);
    final emotionIcon = _getEmotionIcon(_currentEmotion);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Main emotion display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(emotionIcon, size: 32, color: emotionColor),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  _currentEmotion.toUpperCase(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: emotionColor,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${(_confidence * 100).toStringAsFixed(1)}% confident',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // ✅ NEW: attention + primary emotion rows
          _buildKeyValueRow(
            label: 'Attention',
            value:
                '$_attentionState (${(_attentionConfidence * 100).toStringAsFixed(1)}%)',
            icon: _getEmotionIcon(_attentionState),
            color: _getEmotionColor(_attentionState),
          ),
          const SizedBox(height: 8),
          _buildKeyValueRow(
            label: 'Primary Emotion',
            value:
                '$_primaryEmotion (${(_emotionConfidence * 100).toStringAsFixed(1)}%)',
            icon: _getEmotionIcon(_primaryEmotion),
            color: _getEmotionColor(_primaryEmotion),
          ),
          const SizedBox(height: 16),

          // All probabilities list (scrollable, no overflow)
          if (_allProbabilities != null) ...[
            Text(
              'All Emotions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  children: _allProbabilities!.entries
                      .map(
                        (entry) => Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Icon(
                                      _getEmotionIcon(entry.key),
                                      size: 16,
                                      color: _getEmotionColor(entry.key),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        entry.key,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight:
                                              entry.value == _confidence
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '${(entry.value * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight:
                                          entry.value == _confidence
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKeyValueRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text('$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            )),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[800]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _cameraService.stopCameraService();
    _tfliteService.dispose();
    super.dispose();
  }
}
