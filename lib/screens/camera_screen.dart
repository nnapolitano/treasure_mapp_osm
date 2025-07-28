import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:treasure_mapp/screens/picture_screen.dart';
import '../place.dart';

class CameraScreen extends StatefulWidget {
  final Place place;

  ///Constructor takes a Place.
  const CameraScreen(this.place, {super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  ///list of possible cameras to use (front and rear, etc)
  List<CameraDescription>? cameras;
  CameraDescription? camera;
  Widget? cameraPreview;
  Image? image;

  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ///access the place
    Place place = widget.place;

    ///text and preview for taking picture
    return Scaffold(
      appBar: AppBar(
        title: Text('Take Picture'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () async {
              ///handle if camerea not initlized properly
              if (_controller == null || !_controller!.value.isInitialized) {
                print("camera not initlilized");
                return;
              }

              try {
                ///depreciated way of getting files
                // final path = join(
                //   (await getTemporaryDirectory()).path,
                //   '${DateTime.now()}.png',
                // );

                ///Attempt to take a picture, stopping the preview just before to prevent buffer conflicts.
                await _controller!.pausePreview();
                XFile picture = await _controller!.takePicture();
                final String picturePath = picture.path;

                ///change screen to see picture that was taken attched to the place
                MaterialPageRoute route = MaterialPageRoute(
                  builder: (context) => PictureScreen(picturePath, place),
                );
                Navigator.push(context, route);
              } catch (e) {
                print(e);
              }
            },
          ),
        ],
      ),
      body: Container(child: cameraPreview),
    );
  }

  ///modified book code to initilize the cameras as async function.
  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras == null || cameras!.isEmpty) {
      print("no cameras avalable");
      return;
    }

    ///camera!.first would be the front camera, we want the rear so using [1]
    camera = cameras![1];

    _controller = CameraController(camera!, ResolutionPreset.medium);

    try {
      await _controller!.initialize();
      cameraPreview = Center(child: CameraPreview(_controller!));
      setState(() {
        cameraPreview = cameraPreview;
      });
    } catch (e) {
      ///bad error handling for fail
      print(e);
    }
  }
}
