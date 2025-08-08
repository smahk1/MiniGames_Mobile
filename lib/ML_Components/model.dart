import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  late Interpreter _interpreter;
  List<String> _labels = [];

  // How ML models work is that they expect an input and an output in a specific way.
  // The input should have set dimensions and have color data in a certain range.
  // For example, the model may expect [1, 224, 224, 3] where:
  // 1 = number of images, 224x224 = dimensions, and 3 = RGB channels.

  // We first load and initialize the model interpreter and load labels.
  Future<void> initModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/attention_set.tflite');
      await _loadLabels();
      
      print('Model loaded');
      print('Input tensor: ${_interpreter.getInputTensor(0)}');
      print('Output tensor: ${_interpreter.getOutputTensor(0)}');
      print('Labels loaded: ${_labels.length}');
    } catch (e) {
      print('Error loading model: $e');
      rethrow; // Re-throw so the UI can handle it
    }
  }

  // Load labels from the labels.txt file
  Future<void> _loadLabels() async {
    try {
      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData.split('\n').where((label) => label.trim().isNotEmpty).toList();
    } catch (e) {
      print('Error loading labels: $e');
      // Use default labels if file not found
      _labels = ['unknown'];
    }
  }

  // Now we convert the image data from Uint8List (RGBA) into Float32List
  // We normalize the RGB values by dividing by 255 so they're between 0.0 and 1.0.
  // This is how most models are trained to accept pixel input.
  Float32List _preprocessImage(Uint8List imageBytes) {
    try {
      final input = Float32List(1 * 224 * 224 * 3); // shape: [1, 224, 224, 3]
      int index = 0;

      // Check if we have enough data
      if (imageBytes.length < 224 * 224 * 4) {
        throw Exception('Image data too small: ${imageBytes.length} bytes');
      }

      for (int i = 0; i < imageBytes.length && index < input.length; i += 4) {
        if (i + 2 < imageBytes.length) {
          input[index++] = imageBytes[i] / 255.0;     // R
          input[index++] = imageBytes[i + 1] / 255.0; // G
          input[index++] = imageBytes[i + 2] / 255.0; // B
        }
        // We skip the 4th value (A channel) since our model doesn't need it
      }

      return input;
    } catch (e) {
      print('Error preprocessing image: $e');
      rethrow;
    }
  }

  // We then reshape the input and run inference.
  // The model returns predictions based on what it sees in the image.
  Future<Map<String, dynamic>?> runModel(Uint8List imageBytes) async {
    try {
      if (_labels.isEmpty) {
        print('Labels not loaded');
        return null;
      }

      final input = _preprocessImage(imageBytes);
      final reshapedInput = input.reshape([1, 224, 224, 3]);

      // Use the actual number of labels instead of hardcoded 5
      var output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);
      _interpreter.run(reshapedInput, output);
      
      List<double> probabilities = List<double>.from(output[0]);
      
      // Find the highest probability and its index
      double maxProb = 0.0;
      int maxIndex = 0;
      
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }
      
      return {
        'label': _labels[maxIndex],
        'confidence': maxProb,
        'probabilities': probabilities,
        'allLabelsWithProbs': Map.fromIterables(_labels, probabilities),
      };
    } catch (e) {
      print('Error in model inference: $e');
      return null; // Return null instead of crashing
    }
  }

  void dispose() {
    try {
      _interpreter.close();
    } catch (e) {
      print('Error disposing interpreter: $e');
    }
  }
}

// Helper extension for reshaping lists
extension ListReshape<T> on List<T> {
  List<List<T>> reshape(List<int> shape) {
    if (shape.length != 2) {
      throw ArgumentError('Only 2D reshaping supported');
    }
    
    List<List<T>> result = [];
    for (int i = 0; i < shape[0]; i++) {
      result.add(sublist(i * shape[1], (i + 1) * shape[1]));
    }
    return result;
  }
}