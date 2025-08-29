import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  late Interpreter _interpreter;
  List<String> _labels = [];

  Future<void> initModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/attention_set.tflite');
      await _loadLabels();
      // Optional: print tensor info for debugging
      // print('Input: ${_interpreter.getInputTensor(0)}');
      // print('Output: ${_interpreter.getOutputTensor(0)}');
    } catch (e) {
      // ignore: avoid_print
      print('Error loading model: $e');
      rethrow;
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData
          .split('\n')
          .where((label) => label.trim().isNotEmpty)
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error loading labels: $e');
      // Fallback to hardcoded labels for your new model
      _labels = [
        'Attentive',
        'Inattentive', 
        'Happy',
        'Sad',
        'Disgust',
        'Angry'
      ];
    }
  }

  /// imageBytes must be 224*224*4 (RGBA)
  Float32List _preprocessImage(Uint8List imageBytes) {
    final expected = 224 * 224 * 4;
    if (imageBytes.length < expected) {
      throw Exception('Image data too small: ${imageBytes.length} bytes');
    }

    final Float32List input = Float32List(1 * 224 * 224 * 3);
    int j = 0;
    for (int i = 0; i < expected; i += 4) {
      input[j++] = imageBytes[i] / 255.0;     // R
      input[j++] = imageBytes[i + 1] / 255.0; // G
      input[j++] = imageBytes[i + 2] / 255.0; // B
      // skip A
    }
    return input;
  }

  Future<Map<String, dynamic>?> runModel(Uint8List imageBytes) async {
    try {
      if (_labels.isEmpty) {
        // ignore: avoid_print
        print('Labels not loaded');
        return null;
      }

      final input = ReshapeExtension(_preprocessImage(imageBytes)).reshape([1, 224, 224, 3]);
      final output = ReshapeExtension(List.filled(_labels.length, 0.0)).reshape([1, _labels.length]);

      _interpreter.run(input, output);

      final List<double> probs = List<double>.from(output[0]);
      double maxProb = -1.0;
      int maxIdx = 0;
      for (int i = 0; i < probs.length; i++) {
        if (probs[i] > maxProb) {
          maxProb = probs[i];
          maxIdx = i;
        }
      }

      return {
        'label': _labels[maxIdx],
        'confidence': maxProb,
        'probabilities': probs,
        'allLabelsWithProbs': Map.fromIterables(_labels, probs),
      };
    } catch (e) {
      // ignore: avoid_print
      print('Error in model inference: $e');
      return null;
    }
  }

  void dispose() {
    try {
      _interpreter.close();
    } catch (_) {}
  }
}

/// General N-D reshape for Lists (works for [1,224,224,3] and [1,N])
extension ReshapeExtension on List {
  dynamic reshape(List<int> shape) {
    if (shape.isEmpty) return this;
    final int total = shape.reduce((a, b) => a * b);
    if (length != total) {
      throw ArgumentError('Invalid shape: need $total elements, got $length');
    }

    dynamic build(List<int> dims, int offset) {
      if (dims.length == 1) {
        return sublist(offset, offset + dims[0]);
      }
      final int step = dims.sublist(1).reduce((a, b) => a * b);
      return List.generate(
        dims[0],
        (i) => build(dims.sublist(1), offset + i * step),
      );
    }
    return build(shape, 0);
  }
}