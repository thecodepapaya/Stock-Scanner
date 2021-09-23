import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:scan_gsheet/generic_scaffold.dart';
import 'package:scan_gsheet/globals.dart';

class ShowCamera extends StatefulWidget {
  const ShowCamera({Key? key}) : super(key: key);

  @override
  _ShowCameraState createState() => _ShowCameraState();
}

class _ShowCameraState extends State<ShowCamera> {
  late CameraController controller;
  List<CameraDescription> cameras = Globals.cameras;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        // onNewCameraSelected(controller.description);
      }
    }
  }

  // Future<CameraController> initializeCameras() async {
  //   cameras = await availableCameras();
  //   controller = CameraController(cameras[0], ResolutionPreset.max);
  //   controller.initialize().then((_) {
  //     if (!mounted) {
  //       return const Text("Camera not mounted");
  //     }
  //   });
  //   return controller;
  // }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return GenericScaffold(
      title: "Camera",
      body: Stack(
        children: [
          CameraPreview(controller),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 40,
                ),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  minimumSize: const Size(70, 70),
                ),
                onPressed: () async {
                  XFile file = await controller.takePicture();
                  debugPrint("File from cam: $file");
                  debugPrint("File from cam: ${file.path}");
                  Navigator.pop(context, file);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
