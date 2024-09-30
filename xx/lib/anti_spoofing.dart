import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
// import 'package:image/image.dart' as img;

class AntiSpoofing {
  late Interpreter _interpreter;
  static const String path = 'model_1.tflite';
  bool _isModelLoaded = false;

  // Constructor
  AntiSpoofing();

  // Asynchronous method to load the model
  Future<void> initialize() async {
    try {
      InterpreterOptions options = InterpreterOptions()
        ..threads = Platform.numberOfProcessors - 1;
      _interpreter = await Interpreter.fromAsset(path, options: options);
      _isModelLoaded = true;
      print('Anti-spoofing model loaded successfully.');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  // Function to run the model and predict if the face is real or fake
  Future<bool> runAntiSpoofing(File imageFile) async {
    if (!_isModelLoaded) {
      throw StateError("Anti-spoofing model has not been loaded yet.");
    }

    // Convert and preprocess the image
    TensorImage inputImage = _convertImageToTensor(imageFile);

    // Prepare output buffer (assuming the model returns a single output)
    var output = List.filled(1, 0.0).reshape([1, 1]);

    // Run inference
    _interpreter.run(inputImage.buffer, output);

    // Get the liveness probability
    double livenessProbability = output[0][0];
    print('Liveness probability: $livenessProbability');

    return livenessProbability > 0.1;
  }

  // Convert and preprocess the image file to TensorImage
  TensorImage _convertImageToTensor(File imageFile) {
    // Load the image as RGB and resize to 150x150
    TensorImage tensorImage = TensorImage.fromFile(imageFile);

    // Preprocess: Resize to 150x150, convert to RGB, and normalize (scale 0-1)
    tensorImage = ImageProcessorBuilder()
        .add(ResizeOp(150, 150, ResizeMethod.BILINEAR))
        .add(NormalizeOp(0, 255)) // Normalize between 0 and 1
        .build()
        .process(tensorImage);

    return tensorImage;
  }
}
