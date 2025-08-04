import 'dart:async';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import 'package:camera/camera.dart';

class CameraService{
    CameraImage? cameraImage; // frame that is recorded by the camera
    CameraController? cameraController;
    List<CameraDescription> cameras = [];

    Timer? _frameCaptureTimer;
    Function(Uint8List)? onFrameCaptured;
    

    Future<void> _setupCameraController() async{
        List<CameraDescription> hasCameras = await availableCameras();
        if (hasCameras.isNotEmpty){
            // Creating a camera controller
            cameras = hasCameras; // Setting the public cameras[] value
            cameraController = CameraController(cameras.first, ResolutionPreset.medium);
            await cameraController?.initialize();
        }
    }

    // There are 2 methods of taking frames one is just to take a stream of images and then process them and the other is
    // a somewhat more efficient way of taking just 2 total pictures in a second. This conserves power and might even improve 
    // performance, not that I would know.
    // void startImageStream() {
    //     _setupCameraController();
    //     cameraController!.startImageStream((CameraImage image) {   
    // });
    //}

    // Everytime this method is called we must also call the stopCameraService() method
    void startFrameCaptureLoop() {
      _setupCameraController();
      _frameCaptureTimer = Timer.periodic(Duration(milliseconds: 500), (_) async {
          try {
            final XFile file = await cameraController!.takePicture();
            final bytes = await file.readAsBytes();
            Uint8List processedImage = _processCapturedImage(bytes); // Resize
            // This variable function can now be called and given a definition through which we can define what it does with this processedImage.
            onFrameCaptured?.call(processedImage);
          } catch (e) {
            print("Error taking picture: $e");
            print (e);
          }
      });
    }

    // This function returns the image. We will give this as the input to the model for inference.
    Uint8List _processCapturedImage(Uint8List bytes) {
      final original = img.decodeImage(bytes)!;

      // Resized to 224x224 for the model. Can be changed according to the model being used.
      final resized = img.copyResize(original, width: 224, height: 224);

      // Convert to grayscale if needed
      // final grayscale = img.grayscale(resized)

      final input = resized.getBytes();

      return input;
      // Feed to model
      // model(input);
    }



    void stopCameraService() async {
        _frameCaptureTimer?.cancel();
        await cameraController?.dispose();
    }


}


// The camera part can be done by learning how the camera workd in flutter. [✓]
// Current goal is to load the camera get a stable stream of images [✓]
// Modify the images as per requirements and process them using the interpreters as per my knowledge. [] ...
// The interpreter part can be learnt by youtube videos and some documentation. []

// The end goal is to return the current emotional state of the user and call an event on screen 
// responding to their current emotional state. A simple variable check can do this so the implementation 
// isnt that difficult. []