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

If you want to display a video which source comes from a network, 

```dart
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
)
```

If you wanted to display a video which source comes from an asset,

```dart
CustomVideoPlayer(
    skipDuration: 5000, //how many milliseconds you want to skip
    rewindDuration: 5000, //how many milliseconds you want to rewind
    videoSourceType: VideoSourceType.asset, //the source of the video: asset, file, network,
    videoLocation: videoLocation, //the location of your video, if the source is asset
    durationEndDisplay: DurationEndDisplay.remainingDuration, //whether to display in total duration or remaining duration
    displayMenu: false, //whether to display menu
    thumbColor: Colors.brown, //color of the slider's thumb
    activeTrackColor: Colors.indigo, //color of active tracks
    inactiveTrackColor: Colors.grey, //color of inactive tracks
    overlayBackgroundColor: Colors.grey.withOpacity(0.5), //color of the overlay's background
    pressablesBackgroundColor: Colors.deepOrange, //background color of the pressable icons such as play, pause, replay, and menu
    overlayDisplayDuration: 3000, //how long to display the overlay before it disappears, in ms,
)
```

If you wanted to display a video which source comes from a file, 

```dart
CustomVideoPlayer(
    skipDuration: 5000, //how many milliseconds you want to skip
    rewindDuration: 5000, //how many milliseconds you want to rewind
    videoSourceType: VideoSourceType.file, //the source of the video: asset, file, network,
    playerController: playerController, //the VideoPlayerController of your video, if the source is file
    durationEndDisplay: DurationEndDisplay.remainingDuration, //whether to display in total duration or remaining duration
    displayMenu: false, //whether to display menu
    thumbColor: Colors.green, //color of the slider's thumb
    activeTrackColor: Colors.cyan, //color of active tracks
    inactiveTrackColor: Colors.magenta, //color of inactive tracks
    overlayBackgroundColor: Colors.grey.withOpacity(0.5), //color of the overlay's background
    pressablesBackgroundColor: Colors.white, //background color of the pressable icons such as play, pause, replay, and menu
    overlayDisplayDuration: 5000, //how long to display the overlay before it disappears, in ms
)```

