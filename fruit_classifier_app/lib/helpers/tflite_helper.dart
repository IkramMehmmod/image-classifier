import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteHelper {
  late Interpreter _interpreter;
  bool _modelLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
          'assets/fruits_classifier_float16.tflite');
      _modelLoaded = true;
      print("✅ TFLite Model Loaded Successfully!");
    } catch (e) {
      print("❌ Error Loading Model: $e");
    }
  }

  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    if (!_modelLoaded) {
      print("⚠️ Model not loaded!");
      return {"prediction": null, "confidence": null};
    }

    // Read and decode the image
    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
    if (image == null) {
      print("❌ Error decoding image");
      return {"prediction": null, "confidence": null};
    }

    // Resize image to match model input size (299x299)
    image = img.copyResize(image, width: 299, height: 299);

    // Create input tensor
    var input = List.generate(
      1,
      (i) => List.generate(
        299,
        (j) => List.generate(299, (k) => List.filled(3, 0.0)),
      ),
    );

    // Convert image to Float32List (Normalize RGB values)
    for (int y = 0; y < 299; y++) {
      for (int x = 0; x < 299; x++) {
        final pixel = image.getPixel(x, y);

        input[0][y][x][0] = pixel.r / 255.0; // Red
        input[0][y][x][1] = pixel.g / 255.0; // Green
        input[0][y][x][2] = pixel.b / 255.0; // Blue
      }
    }

    // Create output tensor (10 classes)
    var output = List.filled(1 * 10, 0.0).reshape([1, 10]);

    // Run inference
    _interpreter.run(input, output);

    // ✅ FIXED: Get the class with highest probability
    int predictedIndex = 0;
    double maxConfidence = 0.0;

    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > maxConfidence) {
        maxConfidence = output[0][i];
        predictedIndex = i;
      }
    }

    print(
        "🟢 Predicted Class Index: $predictedIndex, Confidence: ${maxConfidence * 100}%");

    return {
      "prediction": predictedIndex,
      "confidence": maxConfidence * 100, // Convert to percentage
    };
  }

  void closeModel() {
    _interpreter.close();
  }
}
