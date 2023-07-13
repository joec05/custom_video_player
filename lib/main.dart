import 'package:custom_video_player/CustomVideoPlayer.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Custom Video Player',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const MyHomePage(title: 'Custom Video Player Examples'),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomVideoPlayer(
              skipDuration: 10000, //how many milliseconds you want to skip
              rewindDuration: 10000, //how many milliseconds you want to rewind
              videoSourceType: VideoSourceType.network, //the source of the video: assets, file, network,
              videoUrl: videoUrl, //the url of your video, if the source is network
              durationEndDisplay: DurationEndDisplay.totalDuration, //whether to display in total duration or remaining duration
              displayMenu: true, //whether to display menu
              thumbColor: Colors.red, //color of the slider's thumb
              activeTrackColor: Colors.pink, //color of active tracks
              inactiveTrackColor: Colors.green, //color of inactive tracks
              overlayBackgroundColor: Colors.grey.withOpacity(0.5), //color of the overlay's background
              pressablesBackgroundColor: Colors.teal, //background color of the pressable icons such as play, pause, replay, and menu
              overlayDisplayDuration: 3000, //how long to display the overlay before it disappears, in ms
            ),
          ],
        ),
      ),
    );
  }
}

