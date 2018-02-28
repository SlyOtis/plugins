import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

//import 'video.dart';


class CameraExampleHome extends StatefulWidget {
  @override
  _CameraExampleHomeState createState() {
    return new _CameraExampleHomeState();
  }
}

IconData cameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw new ArgumentError('Unknown lens direction');
}

class _CameraExampleHomeState extends State<CameraExampleHome> {
  bool opening = false;
  CameraController controller;
  CameraController currentcontroller;
  String imagePath;
  String videofile;
  bool recording = false;
  int pictureCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> headerChildren = <Widget>[];

    final List<Widget> cameraList = <Widget>[];

    if (cameras.isEmpty) {
      cameraList.add(const Text('No cameras found'));
    } else {
      for (CameraDescription cameraDescription in cameras) {
        cameraList.add(
          new SizedBox(
            width: 90.0,
            child: new RadioListTile<CameraDescription>(
              title: new Icon(cameraLensIcon(cameraDescription.lensDirection)),
              groupValue: controller?.description,
              value: cameraDescription,
              onChanged: (CameraDescription newValue) async {
                final CameraController tempController = controller;
                controller = null;
                await tempController?.dispose();
                controller =
                    new CameraController(newValue, ResolutionPreset.high);
                currentcontroller = new CameraController(newValue, ResolutionPreset.high);
                await controller.initialize();
                setState(() {});
              },
            ),
          ),
        );
      }
    }

    headerChildren.add(new Row(children: cameraList));
    //headerChildren.add(new Text( 'Video: ' + videofile  ));
    if (controller != null) {
      headerChildren.add(playPauseButton());
    }
    if (imagePath != null) {
      headerChildren.add(imageWidget());
    }
    // if (videofile != null) {
    //   headerChildren.add(new Text( 'Saved here: $videofile '  ));
    // }
    final List<Widget> columnChildren = <Widget>[];
    //columnChildren.add(new Row(children: headerChildren));
    if (controller == null || !controller.value.initialized) {
      columnChildren.add(new Text('Tap a camera',
      style: new TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),));
    } else if (controller.value.hasError) {
      columnChildren.add(
        new Text('Camera error ${controller.value.errorDescription}'),
      );
    } else {
      columnChildren.add(
        new Container(
        child: new AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: new CameraPreview(controller),
              ),
              height: (MediaQuery.of(context).size.height - 230.0),
              color: Colors.black,
            ),



      );
    }
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Camera example'),
      ),
      body: new Column(
        children: <Widget>[
          new Container(
           child: new Padding(
                padding: const EdgeInsets.all(1.0),
                child: new Center(
                child: new Column(

                  mainAxisAlignment: MainAxisAlignment.center ,
                  children: columnChildren
                ),
              ),
            ),
          //height: 400.0,

          width: MediaQuery.of(context).size.width ,
          decoration: new BoxDecoration(
          color: Colors.black,
          border: new Border.all(
              color: Colors.redAccent,
              width: controller != null && controller.value.isStarted && recording ? 3.0 : 0.0,
            ),
          ),

        ),


          new Padding(
            padding: const EdgeInsets.all(5.0),
            child: new Row(
            mainAxisAlignment: MainAxisAlignment.start ,
            children: headerChildren

          ),
        ),

        vidMsg(),


        ]
        ),
        bottomNavigationBar: (controller == null)
            ? null
            : new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
              mainAxisSize: MainAxisSize.max ,
          children: <Widget>[
              new IconButton(
              icon: new Icon( Icons.camera_alt ),
              color: Colors.blue,
              onPressed: controller.value.isStarted ? capture : null,
            ),
              new IconButton(
              icon: new Icon( Icons.videocam ),
              color: Colors.blue ,
              onPressed: controller.value.isStarted && !recording ? videoStart : null, //videoStart //
            ),
              new IconButton(
              icon: new Icon( Icons.stop ) ,
              color: Colors.red ,
              onPressed: controller.value.isStarted && recording ? videoStop : null, //videoStop //

            ),

          ]),
      // bottomNavigationBar:  (controller == null)
      //     ? null
      //     : new IconButton(
      //   icon: new Icon( Icons.videocam ) ,
      //   color: Colors.blue ,
      //   onPressed: controller.value.isStarted ? video : null,
      // ),
      // floatingActionButton: (controller == null)
      //     ? null
      //     : new FloatingActionButton(
      //         child: const Icon(Icons.camera),
      //         onPressed: controller.value.isStarted ? capture : null,
      //       ),

    );
  }

  void videoStart() {

    videostart();

      setState(
        () {
          // if (!controller.value.videoOn) {
            recording = true;
          // }
        },
      );
  }


  void videoStop() {

     videostop();

      setState(
        () {
          // if (controller.value.videoOn) {
            recording = false;
          // }
        },
      );
  }

  Widget imageWidget() {
    return new Expanded(
      child: new Align(
        alignment: Alignment.centerRight,
        child: new SizedBox(
          child: new Image.file(new File(imagePath)),
          width: 64.0,
          height: 64.0,
        ),
      ),
    );
  }

  Widget vidMsg() {
    if (videofile == null && controller == null){
      return const Padding(
        padding: const EdgeInsets.all(1.0),
        child:
        const Text( 'Choose a camera') ,
      );
    }
    else if (videofile != null && controller == null){
      return new Padding(
        padding: const EdgeInsets.all(1.0),
        child:
        new Text( 'Saved: $videofile ')
      );
    }
    else if (videofile == null && controller != null){
      return const Padding(
        padding: const EdgeInsets.all(1.0),
        child:
        const Text( 'Take a video / photo ') ,
      );
    }
    else {
      return const Padding(
        padding: const EdgeInsets.all(1.0),
        child:
        const Text( 'Take a video / photo ') ,
      );

    }

  }

  Widget playPauseButton() {
    return new FlatButton(
      onPressed: () {
        setState(
          () {
            if (controller.value.isStarted) {
              controller.stop();
            } else {
              controller.start();
            }
          },
        );
      },
      child:
          new Icon(controller.value.isStarted ? Icons.pause : Icons.play_arrow),
    );
  }

  Future<Null> videostart() async {
    if (controller.value.isStarted) {
     final Directory tempDir = await getTemporaryDirectory();
     if (!mounted) {
       return;
     }
     final String tempPath = tempDir.path;
     final String path = '$tempPath/movie${pictureCount++}.mp4';
//      await controller.video(path);
//      if (!mounted) {
//        return;
//      }
//      setState(
//            () {
//          imagePath = path;
//        },
//      );
      //final String tempPath = "VIDEOSTART/path/to/some/video.mp4";
      await controller.videostart(path);
      //final String hello = await controller.video(tempPath);
      //print(hello + ':::From example:::');

    }
  }

  Future<Null> restartcam() async {
   final CameraController tempController2 = controller;
   controller = null;
   await tempController2?.dispose();
   controller = currentcontroller ;
   await controller.initialize();
   //setState(() {});
 }

  Future<Null> videostop() async {
    if (controller.value.isStarted) {
     // final Directory tempDir = await getTemporaryDirectory();
     // if (!mounted) {
     //   return;
     // }
     // final String tempPath = tempDir.path;
//      final String path = '$tempPath/movie${pictureCount++}.jpg';
//      await controller.video(path);
//      if (!mounted) {
//        return;
//      }
//      setState(
//            () {
//          imagePath = path;
//        },
//      );
      //final String tempPath = "VIDEOSTOP/path/to/some/video.mp4";


     final String vfile =  await controller.videostop();

      setState(() {
        videofile = vfile;
      });
      await restartcam();
      //restartcam();

      //final String hello = await controller.video(tempPath);
      //print(hello + ':::From example:::');

    }
  }


  Future<Null> capture() async {
    if (controller.value.isStarted) {
      final Directory tempDir = await getTemporaryDirectory();
      if (!mounted) {
        return;
      }
      final String tempPath = tempDir.path;
      final String path = '$tempPath/picture${pictureCount++}.jpg';
      await controller.capture(path);
      if (!mounted) {
        return;
      }
      setState(
        () {
          imagePath = path;
        },
      );
    }
  }
}

class CameraApp extends StatelessWidget {

@override
Widget build(BuildContext context){
  return new MaterialApp(
    home: new CameraExampleHome(),
    // routes: <String, WidgetBuilder> {
    //     //"/Video": (BuildContext context) => new CameraExampleVideo(),
    //
    //   }
  );

}

}

List<CameraDescription> cameras;

Future<Null> main() async {
  cameras = await availableCameras();
  runApp( new CameraApp());
}
