# Custom Video Player

This video player package is a custom video player made specifically for Flutter applications. This package wraps the video_player plugin and adds key functionalities and design to help developers easily complete their video player of their liking.

## Features

* Perform any action on the player which includes play, pause, replay, and menu.

* An optional menu display which consists of 2 key features: changing the playback speed and mute/unmute.

* A smooth slider with options to design its UI.

* Double tap on the left to rewind and double tap on the right to skip. The duration in which to rewind and skip can be modified.

* An option to set the video player to full screen. 

* An option to set the duration of how long the overlay should appear before it disapears.

<br />

## Custom video player in display  

<br />

![](https://github.com/joec05/files/blob/main/custom_video_player/preview_video_player.gif?raw=true)

<br />

## How to use this package

Make sure to initialize the video player controller before passing it to the plugin, otherwise the video player won't load at all.

```dart
 CustomVideoPlayer(
    playerController: playerController,
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
)
```

