import 'dart:io';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:custom_video_player/CustomVideoPlayer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Video Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Custom Video Player Examples'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String videoUrl = 'https://www.shutterstock.com/shutterstock/videos/1103928479/preview/stock-footage-one-hour-neon-digital-negative-countdown-timer-hour-digital-negative-countdown-neon-one-hour.webm';
  String videoLocation = 'assets/videos/video1.mov';

  late VideoPlayerController networkVideoController;
  late VideoPlayerController assetVideoController;

  String videoLink = '';
  Widget videoPlayerComponent = Container();
  VideoPlayerController fileVideoController = VideoPlayerController.file(File(''));
  ImagePicker _picker = ImagePicker();
  ValueNotifier<double> width = ValueNotifier(200);
  ValueNotifier<double> height = ValueNotifier(350);

  @override void initState(){
    super.initState();
    networkVideoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    assetVideoController = VideoPlayerController.asset(videoLocation);
    initializeVideoController();
  }

  Future<void> initializeVideoController() async{
    setState(() async{
      await networkVideoController.initialize();
      await assetVideoController.initialize();
    });
  }

  Future<void> pickVideo() async {
    try {
      bool permissionIsGranted = false;
      ph.Permission? permission;
      if(Platform.isAndroid){
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if(androidInfo.version.sdkInt <= 32){
          permission = ph.Permission.storage;
        }else{
          permission = ph.Permission.videos;
        }
      }
      permissionIsGranted = await permission!.isGranted;
      if(!permissionIsGranted){
        await permission.request();
        permissionIsGranted = await permission.isGranted;
      }
      if(permissionIsGranted){
        if(videoLink.isEmpty){
          final XFile? pickedFile = await _picker.pickVideo(
            source: ImageSource.gallery,
          );
          if(pickedFile != null ){
            String videoLUri = pickedFile.path;
            VideoPlayerController getController = VideoPlayerController.file(File(videoLUri));
            await getController.initialize().then((value){
              setState(() {
                videoLink = videoLUri;
                videoPlayerComponent = CustomVideoPlayer(
                  playerController: getController,
                  skipDuration: 10000, rewindDuration: 10000, videoSourceType: VideoSourceType.file, 
                  durationEndDisplay: DurationEndDisplay.remainingDuration, displayMenu: false, 
                  thumbColor: Colors.red, activeTrackColor: Colors.black, inactiveTrackColor: Colors.grey, 
                  overlayBackgroundColor: Colors.transparent, 
                  pressablesBackgroundColor: Colors.amber,
                  overlayDisplayDuration: 5000
                );
                fileVideoController = getController;
              });
            });
          }
        }
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            CustomVideoPlayer(
              key: UniqueKey(),
              playerController: networkVideoController,
              skipDuration: 30000, //how many milliseconds you want to skip
              rewindDuration: 30000, //how many milliseconds you want to rewind
              videoSourceType: VideoSourceType.network, //the source of the video: assets, file, network,
              durationEndDisplay: DurationEndDisplay.totalDuration, //whether to display in total duration or remaining duration
              displayMenu: true, //whether to display menu
              thumbColor: Colors.red, //color of the slider's thumb
              activeTrackColor: Colors.pink, //color of active tracks
              inactiveTrackColor: Colors.green, //color of inactive tracks
              overlayBackgroundColor: Colors.grey.withOpacity(0.5), //color of the overlay's background
              pressablesBackgroundColor: Colors.teal, //background color of the pressable icons such as play, pause, replay, and menu
              overlayDisplayDuration: 3000, //how long to display the overlay before it disappears, in ms
            ),
            const SizedBox(
              height: 50
            ),
            CustomVideoPlayer(
              key: UniqueKey(),
              skipDuration: 10000, //how many milliseconds you want to skip
              rewindDuration: 10000, //how many milliseconds you want to rewind
              videoSourceType: VideoSourceType.asset, //the source of the video: assets, file, network,
              playerController: assetVideoController,
              durationEndDisplay: DurationEndDisplay.totalDuration, //whether to display in total duration or remaining duration
              displayMenu: false, //whether to display menu
              thumbColor: Colors.grey, //color of the slider's thumb
              activeTrackColor: Colors.black, //color of active tracks
              inactiveTrackColor: Colors.cyan, //color of inactive tracks
              overlayBackgroundColor: Colors.grey.withOpacity(0.5), //color of the overlay's background
              pressablesBackgroundColor: Colors.transparent, //background color of the pressable icons such as play, pause, replay, and menu
              overlayDisplayDuration: 3000, //how long to display the overlay before it disappears, in ms
            ),
            videoLink.isEmpty ?
              ElevatedButton(
                onPressed: () => pickVideo(),
                child: Text('Pick Video')
              )
            :
              Stack(
                children: [
                  ValueListenableBuilder<double>(
                    valueListenable: width,
                    builder: (BuildContext context, double width, Widget? child){
                      return ValueListenableBuilder<double>(
                        valueListenable: height,
                        builder: (BuildContext context, double height, Widget? child){
                          return videoPlayerComponent;
                        }
                      );
                    }
                  ),
                  Positioned(
                    top: 5, right: 0.03 * getScreenWidth(),
                    child: Container(
                      width: 0.075 * getScreenWidth(),
                      height: 0.075 * getScreenWidth(),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        onTap: (){
                          setState((){
                            videoLink = '';
                            videoPlayerComponent = Container();
                            width.value = 200;
                            height.value = 350;
                            fileVideoController.pause();
                            fileVideoController.dispose();
                          });
                        },
                        child: Icon(Icons.delete, size: 25, color: Colors.white)
                      )
                    )
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}

