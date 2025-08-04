import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'camera_service.dart';

class TFLiteService {
  // How ML models work is that they expect an input and an output in a specfic way. The input should have set dimentions and have color data in a certain color channel range.
  // For example the models trained in teachable machine usually have the following shape requirements [1, 224, 224, 3] something like this. Here 1 means the number of images 
  // 224X224 are the dimentions and 3 is the how many color channels that we have. (RGB)

  // For now what we will do is get the Uint8List for the image data from onFrameCaptured then convert that data into the Float32 format (Float32List)
  // After that we normalize the RGB values by dividing each channel value by 255. This way we get a float value that we can then give as input to the model.

  Future<void> _initTensorFlow () async{
    final interpreter = await Interpreter.fromAsset('assets/your_model.tflite');
    print(interpreter.getInputTensor(0));
    print(interpreter.getOutputTensor(0));

  }
}