import 'dart:async';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';

class CameraService {
  CameraController? cameraController;
  List<CameraDescription> cameras = [];
  Timer? _frameCaptureTimer;

  // This is the callback we define to give each captured frame to the ML model
  Function(Uint8List)? onFrameCaptured;

  // Setup and start camera
  Future<void> setupCameraController() async {
    List<CameraDescription> hasCameras = await availableCameras();
    if (hasCameras.isNotEmpty) {
      cameras = hasCameras;
      cameraController = CameraController(cameras.first, ResolutionPreset.medium);
      await cameraController?.initialize();
    }
  }

  // This method captures images every 500ms (2FPS)
  void startFrameCaptureLoop() {
    setupCameraController();
    _frameCaptureTimer = Timer.periodic(Duration(milliseconds: 500), (_) async {
      try {
        final XFile file = await cameraController!.takePicture();
        final bytes = await file.readAsBytes();

        // We get the image as bytes, resize it to 224x224, and convert to raw pixel bytes
        Uint8List processedImage = _processCapturedImage(bytes);

        // Then we pass the resized pixel data (RGBA) to our ML service
        onFrameCaptured?.call(processedImage);
      } catch (e) {
        print("Error taking picture: $e");
      }
    });
  }

  // This resizes the image to 224x224 and returns raw RGBA bytes
  Uint8List _processCapturedImage(Uint8List bytes) {
    final original = img.decodeImage(bytes)!;
    final resized = img.copyResize(original, width: 224, height: 224);
    return resized.getBytes(); // RGBA bytes
  }

  // Stop camera and clean up
  void stopCameraService() async {
    _frameCaptureTimer?.cancel();
    await cameraController?.dispose();
  }
}
