// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:math';
import 'styles/AppStyles.dart';

enum AudioState{
  mute, unmute
}

enum VideoSourceType{
  file, network, asset
}

enum DurationEndDisplay{
  remainingDuration, 
  totalDuration
}

class CustomVideoPlayer extends StatefulWidget {
  final videoUrl;
  final playerController;
  final int skipDuration;
  final int rewindDuration;
  final VideoSourceType videoSourceType;
  final videoLocation;
  final DurationEndDisplay durationEndDisplay;
  final bool displayMenu;
  final Color thumbColor;
  final Color activeTrackColor;
  final Color inactiveTrackColor;
  final Color overlayBackgroundColor;
  final Color pressablesBackgroundColor;
  final int overlayDisplayDuration;

  const CustomVideoPlayer({
    Key? key, this.videoUrl, this.playerController, required this.skipDuration, 
    required this.rewindDuration, required this.videoSourceType, this.videoLocation, 
    required this.durationEndDisplay, required this.displayMenu, required this.thumbColor,
    required this.activeTrackColor, required this.inactiveTrackColor,
    required this.overlayBackgroundColor, required this.pressablesBackgroundColor,
    required this.overlayDisplayDuration
  }): super(key: key);

  @override
  CustomVideoPlayerState createState() => CustomVideoPlayerState();
}

class CustomVideoPlayerState extends State<CustomVideoPlayer> {

  late ValueNotifier<VideoPlayerController> playerController;
  ValueNotifier<Duration> timeRemaining = ValueNotifier(Duration.zero);
  ValueNotifier<bool> overlayVisible = ValueNotifier(true);
  Timer? _overlayTimer;
  ValueNotifier<bool> isDraggingSlider = ValueNotifier(false);
  ValueNotifier<double> currentPosition = ValueNotifier(0.0);
  ValueNotifier<bool> hasPlayedOnce = ValueNotifier(false);
  ValueNotifier<String> displayCurrentDuration = ValueNotifier('00:00');
  TapDownDetails _doubleTapDetails = TapDownDetails();
  ValueNotifier<bool> isSkipping = ValueNotifier<bool>(false);
  ValueNotifier<bool> isRewinding = ValueNotifier<bool>(false);
  OverlayEntry? overlayEntry;
  ValueNotifier<bool> isFullScreenValue = ValueNotifier(false);
  AudioState audioState = AudioState.unmute;
  double currentPlaybackSpeed = 1.0;

  @override
  void initState(){
    super.initState();
    if(widget.videoSourceType != VideoSourceType.file){
      initializeController(widget.videoUrl);
    }else{
      playerController = ValueNotifier(widget.playerController);
      playerController.value.addListener(() {
        updateCurrentPosition();
        updateOverlayIcon();
      });
      playerController.value.setLooping(false);
    }
  }

  void initializeController(url) async{
    if(widget.videoSourceType == VideoSourceType.network){
      playerController = ValueNotifier(VideoPlayerController.networkUrl(Uri.parse(url)));
    }else if(widget.videoSourceType == VideoSourceType.asset){
      playerController = ValueNotifier(VideoPlayerController.asset(widget.videoLocation));
    }
    playerController.value.addListener(() {
      if(mounted){
        updateCurrentPosition();
        updateOverlayIcon();
      }
    });
    playerController.value.setLooping(false);
    await playerController.value.initialize();
  }

  void updateCurrentPosition(){
    if(mounted){
      if(!isDraggingSlider.value && playerController.value.value.isInitialized){
        currentPosition.value = playerController.value.value.position.inMilliseconds / playerController.value.value.duration.inMilliseconds;
        displayCurrentDuration.value = _formatDuration(playerController.value.value.position);
        if(widget.durationEndDisplay == DurationEndDisplay.remainingDuration){
          timeRemaining.value = playerController.value.value.duration - playerController.value.value.position;
        }
      }
    }
  }

  void updateOverlayIcon(){
    if(playerController.value.value.position.inMilliseconds.toDouble() == playerController.value.value.duration.inMilliseconds.toDouble() && !playerController.value.value.isPlaying && mounted){
      overlayVisible.value = true;
      _overlayTimer?.cancel();
    }
  }

  String _formatDuration(Duration duration) {
    String hours = (duration.inHours).toString().padLeft(2, '0');
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    if (hours == '00') {
      return '$minutes:$seconds';
    } else {
      return '$hours:$minutes:$seconds';
    }
  }

  String formatSeconds(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds ~/ 60) % 60;
    int remainingSeconds = seconds % 60;
    
    String formattedTime = '';
    
    if (hours > 0) {
      formattedTime += hours.toString().padLeft(2, '0') + ':';
    }
    
    formattedTime += minutes.toString().padLeft(2, '0') + ':' + remainingSeconds.toString().padLeft(2, '0');
    
    return formattedTime;
  }


  void _togglePlayPause() {
    if(!hasPlayedOnce.value){
      playerController.value.play();
      Timer(Duration(milliseconds: 100), () {
        _startOverlayTimer();
      });
    }else if(playerController.value.value.position.inMilliseconds.toDouble() == playerController.value.value.duration.inMilliseconds.toDouble() && !playerController.value.value.isPlaying){
      playerController.value.play();
      playerController.value.seekTo(Duration(milliseconds: 0));
    }else if(playerController.value.value.isPlaying){
      playerController.value.pause();
    }else if(!playerController.value.value.isPlaying){
      playerController.value.play();
    }
    hasPlayedOnce.value = true;
    overlayVisible.value = true;
  }

  @override
  void dispose() {
    _overlayTimer?.cancel();
    playerController.value.dispose();
    super.dispose();
  }
  
  void onSliderStart(value){
    overlayVisible.value = true;
    _overlayTimer?.cancel();
    currentPosition.value = value;
  }

  void onSliderChange(value){
    isDraggingSlider.value = true;
    currentPosition.value = value;
    var currentSecond = (value * playerController.value.value.duration.inMilliseconds / 1000).floor();
    displayCurrentDuration.value = formatSeconds(currentSecond);
  }

  void onSliderEnd(value){
    var duration = ((value * playerController.value.value.duration.inMilliseconds) ~/ 10) * 10;
    playerController.value.seekTo(Duration(milliseconds: duration));
    currentPosition.value = value;
    Timer(Duration(milliseconds: 25), () {
      if(!playerController.value.value.isPlaying){
        playerController.value.play();
      }
      isDraggingSlider.value = false;
      overlayVisible.value = true;
      if(value < 1){
        Timer(Duration(milliseconds: 100), () {
          _startOverlayTimer();
        });
      }else if(value >= 1){
        _overlayTimer?.cancel();
      }
    });
  }

  void skip(){
    int duration = min(playerController.value.value.duration.inMilliseconds, playerController.value.value.position.inMilliseconds + widget.skipDuration);
    playerController.value.seekTo(Duration(milliseconds: duration));
    Timer(Duration(milliseconds: 25), () {
      if(!playerController.value.value.isPlaying){
        playerController.value.play();
      }
      if(duration / playerController.value.value.duration.inMilliseconds >= 1){
        _overlayTimer?.cancel();
      }
    });
  }

  void rewind(){
    int duration = max(0, playerController.value.value.position.inMilliseconds - widget.rewindDuration);
    playerController.value.seekTo(Duration(milliseconds: duration));
    Timer(Duration(milliseconds: 25), () {
      if(!playerController.value.value.isPlaying){
        playerController.value.play();
      }
      if(duration / playerController.value.value.duration.inMilliseconds >= 1){
        _overlayTimer?.cancel();
      }
    });
  }

  void _startOverlayTimer() {
    _overlayTimer?.cancel();
    _overlayTimer = Timer(Duration(milliseconds: widget.overlayDisplayDuration), () {
      if(mounted){
        overlayVisible.value = false;
      }
    });
  }

  void _toggleOverlay() {
    if(hasPlayedOnce.value){
      overlayVisible.value = !overlayVisible.value;
      if (overlayVisible.value) {
        _startOverlayTimer();
      } else {
        _overlayTimer?.cancel();
      }
    }
  }

  Widget displayActionIcon(VideoPlayerController playerController){
    var icon;
    if(!playerController.value.isInitialized){
      icon = Icons.play_circle;
    }else{
      if(!hasPlayedOnce.value){
        icon = Icons.play_circle;
      }else if(playerController.value.position.inMilliseconds >= playerController.value.duration.inMilliseconds){
        icon = Icons.replay_rounded;
      }else if(playerController.value.isPlaying){
        icon = Icons.pause;
      }else if(hasPlayedOnce.value && !playerController.value.isPlaying){
        icon = Icons.play_arrow; 
      }
    }
    return Container(
      color: widget.pressablesBackgroundColor,
      child: Icon(icon, size: videoControlActionIconSize),
    );
  }  

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    Offset selectedPosition = _doubleTapDetails.localPosition;
    if(selectedPosition.dx >= 0 && selectedPosition.dx <= 35.w){
      rewind();
      isRewinding.value = true;
      isSkipping.value = false;
      Timer(Duration(milliseconds: 1500), () {
        isRewinding.value = false;
      });
    }else if(selectedPosition.dx >= 65.w && selectedPosition.dx <= 100.w){
      skip();
      isSkipping.value = true;
      isRewinding.value = false;
      Timer(Duration(milliseconds: 1500), () {
        isSkipping.value = false;
      });
    }
  }

  void displayVideoOptions(){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: menuMainContainerButtonMargin,
                child: SizedBox(
                  width: menuButtonWidth,
                  child: ElevatedButton(
                    style: menuButtonStyle,
                    onPressed: (){
                      Navigator.of(context).pop();
                      displayPlaybackSpeedOptions();
                    },
                    child: Text('Set playback speed')
                  )
                )
              ),
              Container(
                margin: menuMainContainerButtonMargin,
                child: SizedBox(
                  width: menuButtonWidth,
                  child: ElevatedButton(
                    style: menuButtonStyle,
                    onPressed: (){
                      if (audioState == AudioState.mute) {
                        playerController.value.setVolume(1.0);
                        audioState = AudioState.unmute;
                      }else if(audioState == AudioState.unmute){
                        playerController.value.setVolume(0.0);
                        audioState = AudioState.mute;
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text(audioState == AudioState.mute ? 'Unmute' : 'Mute')
                  )
                )
              ),
            ],
          )
        );
      }
    );
  }

  void showFullScreenVideoPlayer(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context2) {
        return WillPopScope(
          onWillPop: () async{
            if(isFullScreenValue.value){
              Navigator.of(context2).pop();
              isFullScreenValue.value = false;
              return false;
            }
            return false;
          },
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              child: videoPlayerComponent(playerController.value, context2),
              
            ),
          )
        );
      },
    );
  }

  void displayPlaybackSpeedOptions(){
    List playbackSpeeds = [
      0.25,
      0.5,
      0.75,
      1.0,
      1.5,
      2.0
    ];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            children: [
              for(int i = 0; i < playbackSpeeds.length; i++)
              Container(
                margin: menuMainContainerButtonMargin,
                child: SizedBox(
                  width: menuButtonWidth,
                  child: currentPlaybackSpeed != playbackSpeeds[i] ?
                    ElevatedButton(
                      style: menuButtonStyle,
                      onPressed: (){
                        playerController.value.setPlaybackSpeed(playbackSpeeds[i]);
                        currentPlaybackSpeed = playbackSpeeds[i];
                        Navigator.of(context).pop();
                      },
                      child: Text('${playbackSpeeds[i]}')
                    )
                  :
                    ElevatedButton.icon(
                      style: menuButtonStyle,
                      icon: Icon(Icons.check),
                      onPressed: (){
                        playerController.value.setPlaybackSpeed(playbackSpeeds[i]);
                        Navigator.of(context).pop();
                      },
                      label: Text('${playbackSpeeds[i]}')
                    )
                )
                  ),
            ],
          )
        );
      }
    );
  }


  Widget videoPlayerComponent(VideoPlayerController videoPlayerController, context2){
    Widget component = Container(
      child: GestureDetector(
        onTap: _toggleOverlay,
        onDoubleTapDown: _handleDoubleTapDown,
        onDoubleTap: _handleDoubleTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(videoPlayerController),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    
                    child: ValueListenableBuilder<bool>(
                      valueListenable: overlayVisible,
                      builder: (BuildContext context, bool overlayVisible, Widget? child) {
                        return overlayVisible && widget.displayMenu ? 
                          Container(
                            color: widget.pressablesBackgroundColor,
                            child: AnimatedOpacity(
                              opacity: overlayVisible ? 1.0 : 0.0,
                              duration: Duration(milliseconds: 500),
                              child: GestureDetector(
                                onTap: displayVideoOptions,
                                child: Icon(Icons.menu, size: videoControlFullScreenIconSize)
                              )
                            )
                          )
                        : Container();
                      }
                    )
                  ),
                  Positioned.fill(
                    left: 0,
                    child: Center(
                      child: ValueListenableBuilder<bool>(
                        valueListenable: overlayVisible,
                        builder: (BuildContext context, bool overlayVisible, Widget? child) {
                          return ValueListenableBuilder(
                            valueListenable: videoPlayerController,
                            builder: (BuildContext context, playerController, Widget? child) {
                              return overlayVisible ? 
                                 GestureDetector(
                                  onTap: _togglePlayPause,
                                  child: AnimatedOpacity(
                                    opacity: overlayVisible ? 1.0 : 0.0,
                                    duration: Duration(milliseconds: 500),
                                    child: displayActionIcon(videoPlayerController)
                                  )
                                )
                              : Container();
                            }
                          );
                        }
                      )
                    )
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: overlayVisible,
                      builder: (BuildContext context, bool overlayVisible, Widget? child) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: hasPlayedOnce,
                          builder: (BuildContext context, bool hasPlayedOnce, Widget? child) {
                            return overlayVisible && hasPlayedOnce ?
                              GestureDetector(
                                onTap: (){},
                                child: Container(
                                 
                                  padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 1.h),
                                  color: widget.overlayBackgroundColor,
                                  child: AnimatedOpacity(
                                    opacity: overlayVisible && hasPlayedOnce ? 1.0 : 0.0,
                                    duration: Duration(milliseconds: 500),
                                    child: Column(
                                      children: [
                                      
                                        ValueListenableBuilder<bool>(
                                          valueListenable: isFullScreenValue,
                                          builder: (BuildContext context, bool isFullScreen, Widget? child) {
                                            return Container(
                                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                                              child:Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  
                                                  ValueListenableBuilder<String>(
                                                    valueListenable: displayCurrentDuration,
                                                    builder: (BuildContext context, String displayCurrentDuration, Widget? child) {
                                                      return widget.durationEndDisplay == DurationEndDisplay.totalDuration ?
                                                        Text(
                                                          '$displayCurrentDuration / ${_formatDuration(videoPlayerController.value.duration)}',
                                                          style: TextStyle(fontSize: standardTextFontSize)
                                                        )
                                                      : 
                                                        ValueListenableBuilder<Duration>(
                                                          valueListenable: timeRemaining,
                                                          builder: (BuildContext context, Duration timeRemaining, Widget? child) {
                                                            return Text(
                                                              '$displayCurrentDuration / -${_formatDuration(timeRemaining)}',
                                                              style: TextStyle(fontSize: standardTextFontSize)
                                                            );
                                                          }
                                                        );
                                                    }
                                                  ),
                                                  Container(
                                                    margin: videoControlFullScreenIconContainerMargin,
                                                    child: GestureDetector(
                                                      onTap: () async{
                                                        if(!isFullScreen){
                                                          showFullScreenVideoPlayer(context);
                                                          isFullScreenValue.value = true;
                                                        }else{
                                                          Navigator.of(context2).pop();
                                                          isFullScreenValue.value = false;
                                                        }
                                                      },
                                                      child: Icon(isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen, size: videoControlFullScreenIconSize)
                                                    )
                                                  )
                                                ]
                                              )
                                            );
                                          }
                                        ),
                                          
                                        Container(
                                          height: 15,
                                          child: SliderTheme(
                                            data: SliderThemeData(
                                              trackHeight: 3.0,
                                              thumbColor: widget.thumbColor,
                                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5.0),
                                              overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),
                                              activeTrackColor: widget.activeTrackColor,
                                              inactiveTrackColor: widget.inactiveTrackColor
                                            ),
                                            child: ValueListenableBuilder<double>(
                                              valueListenable: currentPosition,
                                              builder: (BuildContext context, double currentPosition, Widget? child) {
                                                return Slider(
                                                  min: 0.0,
                                                  max: max(1.0, currentPosition),
                                                  value: currentPosition,
                                                  onChangeStart: ((value){
                                                    onSliderStart(value);
                                                  }),
                                                  onChanged: (newValue) {
                                                    onSliderChange(newValue);
                                                  },
                                                  onChangeEnd: (newValue){
                                                    onSliderEnd(newValue);
                                                  },
                                                );
                                              }
                                            )
                                          ),
                                            
                                        ),
                                      ]
                                    
                                    )
                                  )
                                )
                              )
                              : Container();
                          }
                        );
                      }
                    )
                    
                  ),
                ]
              )
            ),
            
            Positioned(
              left: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: isRewinding,
                builder: (BuildContext context, bool isRewinding, Widget? child) {
                  return Container(
                    width: 50.w,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: isRewinding ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 250),
                        child: Container(
                          color: widget.pressablesBackgroundColor,
                          padding: EdgeInsets.all(2.w),
                          child: Icon(FontAwesomeIcons.backward, size: 30)
                        )
                      )
                    )
                  );
                }
              )
            ),
            Positioned(
              right: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: isSkipping,
                builder: (BuildContext context, bool isSkipping, Widget? child) {
                  return Container(
                    width: 50.w,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: isSkipping ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 250),
                        child: Container(
                          color: widget.pressablesBackgroundColor,
                          padding: EdgeInsets.all(2.w),
                          child: Icon(FontAwesomeIcons.forward, size: 30)
                        )
                      )
                    )
                  );
                }
              )
            )
          ],
        )
      )
    );

    return component;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: VisibilityDetector(
        key: ObjectKey(context),
        onVisibilityChanged: (info) {
          var visibleFraction = info.visibleFraction;
          if(visibleFraction < 1.0){
            playerController.value.pause();
          }
          if(visibleFraction == 1.0){
          }
        },
        child: playerController.value.value.isInitialized ? 
          videoPlayerComponent(playerController.value, context)
        : Center(child: CircularProgressIndicator())
      )
    );
  }
}


