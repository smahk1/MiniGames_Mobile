import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class CameraService {
  CameraController? cameraController;
  late List<CameraDescription> _cameras;

  /// Called with a 224x224 RGBA byte buffer (Uint8List length = 224*224*4)
  Function(Uint8List)? onFrameCaptured;

  DateTime? _lastFrameTime; // for ~2 FPS throttle

  Future<void> setupCameraController() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      throw Exception("No cameras available");
    }

    cameraController = CameraController(
      _cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420, // ensure YUV frames
    );

    await cameraController!.initialize();
  }

  /// Start streaming frames; processes ~2 fps and emits 224x224 RGBA bytes.
  void startImageStream() {
    final controller = cameraController;
    if (controller == null || !controller.value.isInitialized) {
      throw Exception("Camera not initialized");
    }
    if (controller.value.isStreamingImages) return;

    controller.startImageStream((CameraImage image) {
      // throttle to ~2 FPS
      final now = DateTime.now();
      if (_lastFrameTime != null &&
          now.difference(_lastFrameTime!) < const Duration(milliseconds: 500)) {
        return;
      }
      _lastFrameTime = now;

      try {
        final rgba = _yuv420ToRgba(image);               // raw RGBA
        final resized = _resizeRgba(rgba, image.width, image.height, 224, 224);
        onFrameCaptured?.call(resized);
      } catch (e) {
        // swallow per-frame errors to keep stream alive
        // print("Frame processing error: $e");
      }
    });
  }

  Future<void> stopCameraService() async {
    if (cameraController != null) {
      if (cameraController!.value.isStreamingImages) {
        await cameraController!.stopImageStream();
      }
      await cameraController!.dispose();
      cameraController = null;
    }
  }

  /// Convert CameraImage (YUV420) -> RGBA Uint8List (width*height*4)
  Uint8List _yuv420ToRgba(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    final Plane planeY = image.planes[0];
    final Plane planeU = image.planes[1];
    final Plane planeV = image.planes[2];

    final int strideY = planeY.bytesPerRow;
    final int strideU = planeU.bytesPerRow;
    final int strideV = planeV.bytesPerRow;
    final int pixelStrideU = planeU.bytesPerPixel ?? 1;
    final int pixelStrideV = planeV.bytesPerPixel ?? 1;

    final Uint8List out = Uint8List(width * height * 4);
    int o = 0;

    for (int y = 0; y < height; y++) {
      final int yRow = y * strideY;
      final int uvRow = (y >> 1) * strideU; // U & V have same row stride
      for (int x = 0; x < width; x++) {
        final int yIndex = yRow + x;
        final int uvIndexU = uvRow + (x >> 1) * pixelStrideU;
        final int uvIndexV = (y >> 1) * strideV + (x >> 1) * pixelStrideV;

        final int Y = planeY.bytes[yIndex] & 0xFF;
        final int U = planeU.bytes[uvIndexU] & 0xFF;
        final int V = planeV.bytes[uvIndexV] & 0xFF;

        // YUV420 to RGB (BT.601), integer math
        int C = Y - 16;    if (C < 0) C = 0;
        int D = U - 128;
        int E = V - 128;

        int R = (298 * C + 409 * E + 128) >> 8;
        int G = (298 * C - 100 * D - 208 * E + 128) >> 8;
        int B = (298 * C + 516 * D + 128) >> 8;

        if (R < 0) R = 0; else if (R > 255) R = 255;
        if (G < 0) G = 0; else if (G > 255) G = 255;
        if (B < 0) B = 0; else if (B > 255) B = 255;

        out[o++] = R;
        out[o++] = G;
        out[o++] = B;
        out[o++] = 255; // A
      }
    }

    return out;
  }

  /// Resize RGBA buffer using `package:image` for quality (keeps RGBA layout).
  Uint8List _resizeRgba(
    Uint8List rgba,
    int srcW,
    int srcH,
    int dstW,
    int dstH,
  ) {
    final src = img.Image.fromBytes(
      width: srcW,
      height: srcH,
      bytes: rgba.buffer,
      numChannels: 4,
    );
    final resized = img.copyResize(src, width: dstW, height: dstH); // RGBA
    return Uint8List.fromList(resized.getBytes());
  }
}
