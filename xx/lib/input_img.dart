import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'localdb.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'image_process.dart' as imgp;
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'painter.dart';

class ImageInputHandler extends StatefulWidget {
  const ImageInputHandler({super.key});

  @override
  _ImageInputHandlerState createState() => _ImageInputHandlerState();
}

class _ImageInputHandlerState extends State<ImageInputHandler> {
  File? _selectedImage1;
  Size? _imageSize1;
  List<Face>? _faces1;
  final imgp.FaceNet _faceNet = imgp.FaceNet();
  late List<double> _embeddings1;
  late String clockTime = '';
  UserHelper userHelper = UserHelper();

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final CollectionReference _userDetails =
      FirebaseFirestore.instance.collection("User");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 30, left: 15, right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _idController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "User ID",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Username",
                ),
              ),
              const SizedBox(height: 10),
              _selectedImage1 != null
                  ? SizedBox(
                      width: 200.0,
                      height: 200.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.file(
                            _selectedImage1!,
                            fit: BoxFit.cover,
                            width: 200.0,
                            height: 200.0,
                          ),
                          CustomPaint(
                            painter: FacePainter(_faces1 ?? [],
                                Image.file(_selectedImage1!), _imageSize1!),
                            child: const SizedBox(width: 300.0, height: 300.0),
                          ),
                        ],
                      ),
                    )
                  : const Text('No image selected'),
              const SizedBox(
                height: 10,
                width: 120,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            height: 200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Text('Choose to pick Image'),
                                  ElevatedButton(
                                    onPressed: () => {
                                      _pickImageGallery(1),
                                      Navigator.pop(context),
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF273671),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 30),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text('Gallery',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  ElevatedButton(
                                    onPressed: () => {
                                      _pickImageCamera(1),
                                      Navigator.pop(context),
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF273671),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 30),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text('Camera',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF273671),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Image',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                width: 120,
                child: ElevatedButton(
                  onPressed: () => _saveUser(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF273671), // Button background color
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white), // Text color
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                width: 120,
                child: ElevatedButton(
                  onPressed: () => _deleteDuplicateId(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF273671), // Button background color
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.white), // Text color
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageGallery(int imageNumber) async {
    //pick image
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    InputImage inputImage;
    final options = FaceDetectorOptions();
    final faceDetector = FaceDetector(options: options);

    //save image
    if (pickedFile != null) {
      final appDir = await getTemporaryDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final savedImage =
          await File(pickedFile.path).copy('${appDir.path}/$fileName.jpg');

      inputImage = InputImage.fromFile(savedImage);

      //detect face
      final Image imag = Image.file(savedImage);
      imag.image
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo info, bool _) async {
        final List<Face> faces = await faceDetector.processImage(inputImage);

        faceDetector.close();

        if (faces.isNotEmpty) {
          //crop img
          Uint8List uint8list = await savedImage.readAsBytes();
          img.Image? image = img.decodeImage(uint8list);

          if (image != null) {
            Rect rect = faces[0]
                .boundingBox; // Assuming we are cropping the first detected face
            img.Image croppedImage = img.copyCrop(image, rect.left.toInt(),
                rect.top.toInt(), rect.width.toInt(), rect.height.toInt());

            //save crop img
            final croppedFileName =
                DateTime.now().millisecondsSinceEpoch.toString();
            final croppedFilePath = '${appDir.path}/$croppedFileName.jpg';
            final croppedFile = File(croppedFilePath);
            croppedFile.writeAsBytesSync(img.encodeJpg(croppedImage));

            List<double> embeddings = _faceNet.recognizeImage(croppedFile);

            //chk model recognise img
            if (_faceNet.isModelLoaded()) {
              List<double> embeddings = _faceNet.recognizeImage(croppedFile);
              print('Embeddings: $embeddings');
            } else {
              print('Model is not yet loaded, please wait...');
            }
            setState(() {
              if (imageNumber == 1) {
                _selectedImage1 = croppedFile;
                _faces1 = [];
                _imageSize1 = Size(croppedImage.width.toDouble(),
                    croppedImage.height.toDouble());
                _embeddings1 = embeddings;
              }
            });
          }
        }
      }));
    }
  }

  Future<void> _pickImageCamera(int imageNumber) async {
    //pick image
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    InputImage inputImage;
    final options = FaceDetectorOptions();
    final faceDetector = FaceDetector(options: options);

    //save image
    if (pickedFile != null) {
      final appDir = await getTemporaryDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final savedImage =
          await File(pickedFile.path).copy('${appDir.path}/$fileName.jpg');

      inputImage = InputImage.fromFile(savedImage);

      //detect face
      final Image imag = Image.file(savedImage);
      imag.image
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo info, bool _) async {
        final List<Face> faces = await faceDetector.processImage(inputImage);

        faceDetector.close();

        if (faces.isNotEmpty) {
          //crop img
          Uint8List uint8list = await savedImage.readAsBytes();
          img.Image? image = img.decodeImage(uint8list);

          if (image != null) {
            Rect rect = faces[0]
                .boundingBox; // Assuming we are cropping the first detected face
            img.Image croppedImage = img.copyCrop(image, rect.left.toInt(),
                rect.top.toInt(), rect.width.toInt(), rect.height.toInt());

            //save crop img
            final croppedFileName =
                DateTime.now().millisecondsSinceEpoch.toString();
            final croppedFilePath = '${appDir.path}/$croppedFileName.jpg';
            final croppedFile = File(croppedFilePath);
            croppedFile.writeAsBytesSync(img.encodeJpg(croppedImage));

            List<double> embeddings = _faceNet.recognizeImage(croppedFile);

            //chk model recognise img
            if (_faceNet.isModelLoaded()) {
              List<double> embeddings = _faceNet.recognizeImage(croppedFile);
              print('Embeddings: $embeddings');
            } else {
              print('Model is not yet loaded, please wait...');
            }
            setState(() {
              if (imageNumber == 1) {
                _selectedImage1 = croppedFile;
                _faces1 = [];
                _imageSize1 = Size(croppedImage.width.toDouble(),
                    croppedImage.height.toDouble());
                _embeddings1 = embeddings;
              }
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('No face detected'),
          ));
        }
      }));
    }
  }

//add id, name and embedding1
  //add id, name and embedding1
  Future<void> _saveUser() async {
    // Check if ID and name are not empty
    if (_idController.text.isEmpty || _nameController.text.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('ID and name cannot be empty'),
      ));
      return;
    }

    // Check if embedding1, embedding2, and embedding3 are not empty
    if (_embeddings1.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No embeddings found for one or more images'),
      ));
      return;
    }

    try {
      // Check if the user ID already exists
      final existingUser =
          await _userDetails.where('id', isEqualTo: _idController.text).get();
      if (existingUser.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('User with the same ID already exists'),
        ));
        return;
      }

      // Retrieve the user details
      User? userDetails = FirebaseAuth.instance.currentUser;

      // Check if userDetails is not null
      if (userDetails != null) {
        // Update user ID and name
        await _userDetails.doc(userDetails.uid).set({
          'id': _idController.text,
          'email': userDetails.email,
          'name': _nameController.text,
        });

        // Add embeddings to Firestore
        await _userDetails.doc(userDetails.uid).collection('embeddings').add({
          'emb1': _embeddings1,
        });

        await userHelper.addUser(
            _idController.text, _nameController.text, clockTime, _embeddings1);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('User added successfully'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('User not logged in'),
        ));
      }
    } catch (e) {
      print('Error adding user: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to add user'),
      ));
    }
  }

  Future<void> _deleteDuplicateId() async {
    // Check if ID and name are not empty
    if (_idController.text.isEmpty || _nameController.text.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('ID and name cannot be empty'),
      ));
      return;
    }

    try {
      // Query the Firestore to find the user with the provided ID
      final querySnapshot =
          await _userDetails.where('id', isEqualTo: _idController.text).get();

      // Check if any user found with the provided ID
      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('User with the provided ID not found'),
        ));
        return;
      }

      // Delete the user document
      await querySnapshot.docs.first.reference.delete();

      // Delete the embeddings subcollection associated with the user
      for (final doc in querySnapshot.docs) {
        await doc.reference.collection('embeddings').get().then((snapshot) {
          for (final doc in snapshot.docs) {
            doc.reference.delete();
          }
        });
      }

      await userHelper.deleteUser(_idController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      print('Error deleting user: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to delete user'),
      ));
    }
  }
}
