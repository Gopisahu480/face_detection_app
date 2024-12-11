import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

import 'face_detection_service.dart';
import 'camera_service.dart';

class FaceDetectionScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  final FaceDetectionService _faceDetectionService = FaceDetectionService();
  final CameraService _cameraService = CameraService();
  final ImagePicker _imagePicker = ImagePicker();

  List<Face> _detectedFaces = [];
  File? _imageFile;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _cameraService.initializeCamera();
    setState(() {});
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _processImage(File(pickedFile.path));
    }
  }

  Future<void> _captureImage() async {
    final XFile? capturedImage = await _cameraService.captureImage();
    if (capturedImage != null) {
      await _processImage(File(capturedImage.path));
    }
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      _isProcessing = true;
      _imageFile = imageFile;
    });

    final inputImage = InputImage.fromFile(imageFile);
    final faces = await _faceDetectionService.detectFaces(inputImage);

    setState(() {
      _detectedFaces = faces;
      _isProcessing = false;
    });
  }

  Widget _buildFaceDetectionOverlay() {
    if (_imageFile == null) return Container();

    return CustomPaint(
      painter: FaceDetectionPainter(_imageFile!, _detectedFaces),
      child: Image.file(_imageFile!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Detection App'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _imageFile != null
                ? _buildFaceDetectionOverlay()
                : (_cameraService.cameraController != null
                    ? CameraPreview(_cameraService.cameraController!)
                    : Center(child: CircularProgressIndicator())),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Detected Faces: ${_detectedFaces.length}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImageFromGallery,
                      icon: Icon(Icons.photo_library),
                      label: Text('Gallery'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: _captureImage,
                      icon: Icon(Icons.camera_alt),
                      label: Text('Capture'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _faceDetectionService.close();
    _cameraService.dispose();
    super.dispose();
  }
}

class FaceDetectionPainter extends CustomPainter {
  final File imageFile;
  final List<Face> faces;

  FaceDetectionPainter(this.imageFile, this.faces);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (Face face in faces) {
      canvas.drawRect(face.boundingBox, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
