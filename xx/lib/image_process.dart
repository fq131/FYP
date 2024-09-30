import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class FaceNet {
  late Interpreter _interpreter;
  late ImageProcessor _imageProcessor;
  static const String path = 'model_new.tflite';
  bool _isModelLoaded = false;

  bool isModelLoaded() {
    return _isModelLoaded;
  }

  FaceNet() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    InterpreterOptions().threads = Platform.numberOfProcessors - 1;
    //load model from assets
    _interpreter =
        await Interpreter.fromAsset(path, options: InterpreterOptions());
    _imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(160, 160, ResizeMethod.BILINEAR))
        .add(CastOp(TfLiteType.float32))
        .build();
    print('Load facenet model successfully');
    _isModelLoaded = true;
  }

  void close() {
    _interpreter.close();
  }

  ByteBuffer _convertImageToByteBuffer(File image) {
    TensorImage tensorImage = TensorImage.fromFile(image);
    //img file resize
    tensorImage = _imageProcessor.process(tensorImage);
    print('convert Successfully');
    return tensorImage.getBuffer();
  }

  List<double> recognizeImage(File image) {
    if (!_isModelLoaded) {
      throw StateError("Model has not been loaded yet");
    }

    ByteBuffer input = _convertImageToByteBuffer(image);
    print(input);
    int embeddingDim = 128;
    var output = List.filled(embeddingDim, 0.0).reshape([1, embeddingDim]);
    _interpreter.run(input, output);
    print(output);
    return output[0];
  }

  static double cosineSimilarity(List<double> x1, List<double> x2) {
    double dotProduct = 0.0;
    double mag1 = 0.0;
    double mag2 = 0.0;

    for (int i = 0; i < x1.length; i++) {
      dotProduct += (x1[i] * x2[i]);
      mag1 += pow(x1[i], 2);
      mag2 += pow(x2[i], 2);
    }

    double euclideanDist = sqrt(mag1) * sqrt(mag2);

    return dotProduct / euclideanDist;
  }
}
