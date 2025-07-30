import 'package:camera/camera.dart';
import 'package:project_mini_games/main.dart';

CameraImage? cameraImage; // frame that is recorded by the camera
CameraController? cameraController;
String output = '';


// Current goal is to load the camera get a stable stream of images
// Modify the images as per requirements and process them using the interpreters as per my knowledge.
// The camera part can be done by learning how the camera workd in flutter.
// The interpreter part can be learnt by youtube videos and some documentation.

// The end goal is to return the current emotional state of the user and call an event on screen 
// responding to their current emotional state. A simple variable check can do this so the implementation 
// isnt that difficult.