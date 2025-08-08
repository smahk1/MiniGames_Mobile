import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';

import 'package:project_mini_games/ML_Components/camera_service.dart';
import 'package:project_mini_games/ML_Components/model.dart';

// Import your services
// import 'camera_service.dart';
// import 'tflite_service.dart';

class EmotionDetectionPage extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    setState(() {
      _hasError = false;
      _isInitialized = false;
      _currentEmotion = "Initializing...";
    });

    try {
      // Initialize the ML model
      await _tfliteService.initModel();
      
      // Set up camera callback
      _cameraService.onFrameCaptured = (Uint8List imageBytes) async {
        try {
          final result = await _tfliteService.runModel(imageBytes);
          
          if (result != null) {
            setState(() {
              _currentEmotion = result['label'];
              _confidence = result['confidence'];
              _allProbabilities = result['allLabelsWithProbs'];
            });
          } else {
            // Handle error case
            setState(() {
              _currentEmotion = "Processing error";
              _confidence = 0.0;
              _allProbabilities = null;
            });
          }
        } catch (e) {
          print('Error processing frame: $e');
          setState(() {
            _currentEmotion = "Camera error";
            _confidence = 0.0;
            _allProbabilities = null;
          });
        }
      };
      
      // Start camera
      await _cameraService.setupCameraController();
      _cameraService.startFrameCaptureLoop();
      
      setState(() {
        _isInitialized = true;
        _hasError = false;
      });
      
    } catch (e) {
      print('Error initializing services: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emotion Detection'),
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
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 80),
            SizedBox(height: 20),
            Text(
              'Initialization Failed',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: Text('Go Back'),
                ),
                ElevatedButton(
                  onPressed: _retryInitialization,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Loading model and camera...'),
          Text(_currentEmotion, style: TextStyle(color: Colors.grey)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Option to go back while loading
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Camera Preview on Top
        Expanded(
          flex: 2,
          child: Container(
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
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.only(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: Colors.white, size: 60),
            SizedBox(height: 20),
            Text(
              'Camera Not Available',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back
                  },
                  child: Text('Go Back'),
                ),
                ElevatedButton(
                  onPressed: _retryInitialization,
                  child: Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsWidget() {
    if (_currentEmotion.contains("error") || _currentEmotion.contains("Error")) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning, color: Colors.orange, size: 50),
          SizedBox(height: 20),
          Text(
            _currentEmotion,
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _retryInitialization,
            child: Text('Retry'),
          ),
        ],
      );
    }

    // Normal results display
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Main emotion result
        Text(
          _currentEmotion.toUpperCase(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        SizedBox(height: 10),
        
        // Confidence percentage
        Text(
          '${(_confidence * 100).toStringAsFixed(1)}% confident',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 20),
        
        // All probabilities (optional)
        if (_allProbabilities != null)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _allProbabilities!.entries
                    .map((entry) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                '${(entry.value * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: entry.value == _confidence
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _cameraService.stopCameraService();
    _tfliteService.dispose();
    super.dispose();
  }
}