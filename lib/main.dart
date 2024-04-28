import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> _cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const CameraApp());
}

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> with WidgetsBindingObserver {
  late CameraController _controller;
  late StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();

  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _streamSubscription.cancel(); // 取消訂閱
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _scanImage(image) async{
    print(image);
  }

  Future<void> _initCamera() async {
    _controller = CameraController(_cameras[0], ResolutionPreset.max);
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    try {
      await _controller.initialize();
      await _controller.startImageStream((CameraImage availableImage) async {
        _scanImage(availableImage);
      });
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          break;
        default:
          break;
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Camera Preview'),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: CameraPreview(_controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}