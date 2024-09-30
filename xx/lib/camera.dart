// import 'dart:async';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_recognition/anti_spoofing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:face_camera/face_camera.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'image_process.dart' as imgp;
import 'package:path_provider/path_provider.dart';
import 'localdb.dart';
import 'user_page.dart';

class FaceScan extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> user;

  const FaceScan({Key? key, required this.user}) : super(key: key);

  @override
  State<FaceScan> createState() => _FaceScanState();
}

class _FaceScanState extends State<FaceScan> {
  File? _capturedImage;
  List<File> images = [];
  bool isProcessing = true;
  List<double>? embeddings2;
  final imgp.FaceNet _faceNet = imgp.FaceNet();
  String _verificationResult = "";
  List<Map<String, dynamic>> allUsers = [];
  List<List<double>> emb1 = [];
  String base64img = '';
  UserHelper userHelper = UserHelper();
  final CollectionReference _userDetails =
      FirebaseFirestore.instance.collection("User");
  User? userDetails = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Face Camera'),
        ),
        body: Builder(builder: (context) {
          if (_capturedImage != null) {
            return Center(
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Image.file(
                      _capturedImage!,
                      width: double.maxFinite,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Container(
                    alignment: const Alignment(0.0, 0.75),
                    child: Text(
                      _verificationResult,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    // ElevatedButton(
                    //     onPressed: () => setState(() {
                    //           _capturedImage = null;
                    //         }),
                    //     child: const Text(
                    //       'Capture Again',
                    //       textAlign: TextAlign.center,
                    //       style: TextStyle(
                    //           fontSize: 14, fontWeight: FontWeight.w700),
                    //     )),
                  ),
                  // Container(
                  //   height: 40,
                  // ),
                  // Container(
                  //   alignment: const Alignment(0.0, 0.625),
                  //   child: ScaffoldMessenger(
                  //     child: Text(
                  //       _verificationResult,
                  //       style: const TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),
                  // )
                ],
              ),
            );
          }

          return Center(
            child: SmartFaceCamera(
                autoCapture: true,
                defaultCameraLens: CameraLens.front,
                showCameraLensControl: false,
                showFlashControl: false,
                showCaptureControl: false,
                imageResolution: ImageResolution.high,
                onCapture: _processImage,
                messageBuilder: (context, face) {
                  if (face == null) {
                    return _message('Place your face in the camera');
                  }
                  if (!face.wellPositioned) {
                    return _message('Center your face in the square');
                  }
                  return const SizedBox.shrink();
                }),
          );
        }),
      ),
    );
  }

  Widget _message(String msg) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 15),
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      );

  Future<void> _processImage(File? image) async {
    if (image != null) {
      // Initialize AntiSpoofing and check if the face is real or fake
      AntiSpoofing antiSpoofing = AntiSpoofing();
      await antiSpoofing.initialize();
      bool isReal = await antiSpoofing.runAntiSpoofing(image);

      if (!isReal) {
        // Spoof face detected
        setState(() {
          _capturedImage = image;
          _verificationResult = 'Spoof detected!';
        });
        await Future.delayed(const Duration(seconds: 5));
        _captureAgain();
        return;
      }

      InputImage inputImage = InputImage.fromFile(image);
      final faceDetector = FaceDetector(options: FaceDetectorOptions());
      final List<Face> faces = await faceDetector.processImage(inputImage);
      faceDetector.close();

      if (faces.isNotEmpty) {
        Uint8List unit8list = await image.readAsBytes();
        img.Image? a = img.decodeImage(unit8list);
        Rect rect = faces[0].boundingBox;

        a = img.copyRotate(a!, 90);
        final b = img.copyCrop(
          a,
          rect.left.toInt(),
          rect.top.toInt(),
          rect.width.toInt(),
          rect.height.toInt(),
        );

        final appDir = await getTemporaryDirectory();
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final croppedFilePath = '${appDir.path}/$fileName.jpg';
        final croppedFile = File(croppedFilePath);
        croppedFile.writeAsBytesSync(img.encodeJpg(b));

        Uint8List imagebytes = await croppedFile.readAsBytes();
        String base64string = base64.encode(imagebytes);
        setState(() {
          base64img = base64string;
          _capturedImage = croppedFile;
        });

        final emb2 = _getFaceFeaturesPoints(croppedFile);

        if (emb2 != null) {
          allUsers = await userHelper.getAllUser();
          emb1 = await userHelper.getEmbedding1();
          _compareFaces(emb1, emb2);
        }
      }
    }
  }

  List<double>? _getFaceFeaturesPoints(File image) {
    if (_faceNet.isModelLoaded()) {
      return _faceNet.recognizeImage(image);
    }
    return null;
  }

  Future<void> _compareFaces(
    emb1,
    List<double>? embeddings2,
  ) async {
    if (emb1 != null && embeddings2 != null) {
      for (int i = 0; i < emb1.length; i++) {
        //<List<List<List<double>>>>
        //   for (int j = 0; j < emb1[i].length; j++) {
        //     //<List<List<double>>>
        double similarity = imgp.FaceNet.cosineSimilarity(
            emb1[i], embeddings2); //<List<double>>
        //print(emb1[i][j]);

        if (similarity >= 0.43) {
          setState(() {
            _verificationResult = "Verification Successful";
            String userId = allUsers[i]['id'];
            String userName = allUsers[i]['name'];
            DateTime now = DateTime.now();
            String clockTime = DateFormat('d/M/y HH:mm:ss').format(now);
            userHelper.addClockTime(userId, clockTime);
            _userDetails.doc(userDetails!.uid).collection('clockTime').add({
              'clockTime': clockTime,
            });
            // print('User ID: $userId');
            // print('User Name: $userName');
            print('similiarity: $similarity');

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UserPage(
                  userId: userId,
                  userName: userName,
                  clockTime: clockTime,
                ),
              ),
            );
          });
          return;
        } else {
          setState(() {
            _verificationResult = "Verification Unsuccessful";
            Timer(const Duration(seconds: 3), () {
              _captureAgain();
            });
          });
        }
        //   }
      }
    }
  }

  void _captureAgain() {
    setState(() {
      _capturedImage = null;
    });
  }
}
