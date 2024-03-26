import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lcos/screens/add_post_screen.dart';
import 'package:file_picker/file_picker.dart';

class SnapOrRecord extends StatefulWidget {
  const SnapOrRecord({Key? key}) : super(key: key);

  @override
  _SnapOrRecordState createState() => _SnapOrRecordState();
}

class _SnapOrRecordState extends State<SnapOrRecord> {
  Uint8List? _file;
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  bool isRecording = false;
  bool isVideoMode = false;
  late ValueNotifier<int> _recordingTime;
  Completer<void> _recordingCompleter = Completer<void>();
  late Timer _recordingTimer;
  static const int MAX_RECORDING_TIME = 60;
  String? _videoPath;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCameraController();
    _recordingTime = ValueNotifier<int>(0);
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (isRecording) {
        setState(() {
          _recordingTime.value++;
        });
      }
    });
  }

  Future<void> _initializeCameraController() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
      );
      await _cameraController.initialize();
    }
  }

  Future<void> _toggleRecording() async {
    try {
      if (_cameraController.value.isRecordingVideo) {
        await _stopRecording();
        setState(() {
          isRecording = false;
        });
      } else {
        String? videoPath = await _startRecording(); // Wait for the video path
        if (videoPath != null) {
          setState(() {
            isRecording = true;
            _videoPath = videoPath; // Store the video path
          });
        }
      }
    } catch (e) {
      print('Error toggling recording: $e');
    }
  }

  Future<void> _takePicture() async {
    if (!_cameraController.value.isTakingPicture) {
      try {
        final XFile picture = await _cameraController.takePicture();
        final Uint8List fileBytes = await picture.readAsBytes();
        setState(() {
          _file = fileBytes;
        });
        _proceedToNextProcess(null); // Pass null as video path for pictures
      } catch (e) {
        print('Error taking picture: $e');
      }
    }
  }

  Future<void> _pickImageOrVideo() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path!);

      // Update to handle both images and videos
      if (result.files.single.extension == 'jpg' ||
          result.files.single.extension == 'jpeg' ||
          result.files.single.extension == 'png') {
        // It's an image, read bytes
        _file = await file.readAsBytes();
        _proceedToNextProcess(null); // Pass null as video path for images
      } else if (result.files.single.extension == 'mp4' ||
                 result.files.single.extension == 'mov') {
        // It's a video, handle video file accordingly
        _proceedToNextProcess(file.path);
      }

      print('Picked file path: ${file.path}');
      print('Picked file size: ${_file?.length} bytes');

      setState(() {});
    } else {
      print('No file picked');
    }
  } catch (e) {
    print('Error picking media: $e');
  }
}

  Future<String?> _startRecording() async {
    try {
      await _initializeControllerFuture;
      await _cameraController.startVideoRecording();

      _recordingTime.value = 0;
      _recordingCompleter = Completer<void>();

      // Set up a callback to stop recording after a specific duration
      Timer(Duration(seconds: MAX_RECORDING_TIME), () async {
        await _stopRecording();
      });

      return _videoPath; // Return the video path
    } catch (e) {
      print('Error starting recording: $e');
      _proceedToNextProcess(
          null); // Pass null as video path in case of an error
      return null;
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (_cameraController.value.isRecordingVideo) {
        XFile videoFile = await _cameraController.stopVideoRecording();
        _videoPath = videoFile.path; // Store the video path
        _proceedToNextProcess(
            _videoPath); // Pass the video path to AddPostScreen
      }
    } catch (e) {
      print('Error stopping recording: $e');
      _proceedToNextProcess(
          null); // Pass null as video path in case of an error
    }
  }

  void _proceedToNextProcess(String? videoPath) {
    if (!isRecording) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AddPostScreen(file: _file, videoPath: videoPath),
        ),
      );
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _recordingTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            color: Colors.black,
            width: double.infinity,
            height: double.infinity,
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_cameraController);
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Positioned(
            bottom: 16.0,
            child: Column(
              children: [
                // UI components for the snap mode
                if (!isRecording)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 130,
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              isVideoMode ? 'Video' : 'Picture',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            Switch(
                              value: isVideoMode,
                              onChanged: (value) {
                                setState(() {
                                  isVideoMode = value;
                                });
                              },
                              activeTrackColor: Colors.grey,
                              activeColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        child: FloatingActionButton(
                          onPressed:
                              isVideoMode ? _toggleRecording : _takePicture,
                          child: Icon(
                            isVideoMode
                                ? (isRecording ? Icons.stop : Icons.videocam)
                                : Icons.camera,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        width: 130,
                        child: IconButton(
                          onPressed: _pickImageOrVideo,
                          icon: Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                // UI components for the record mode
                if (isRecording)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          'Recording Time: ${_recordingTime.value} seconds',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                if (isRecording)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: FloatingActionButton(
                          onPressed: _toggleRecording,
                          child: Icon(
                            isRecording ? Icons.stop : Icons.videocam,
                          ),
                        ),
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
}
