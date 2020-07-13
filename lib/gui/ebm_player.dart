import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/rendering.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:xml/xml.dart';
import 'package:basic_utils/basic_utils.dart';

enum STREAM_TYPE {
  AAC,
  MP3192,
  MP3320,
  OGG_LOW,
  OGG_HIGH,
  UNKNOWN
}

class EbmPlayer extends StatefulWidget {
  EbmPlayer({this.latest, this.streamType, this.lastChanged});
  _EbmPlayer createState() => _EbmPlayer();
  final ValueNotifier<String> lastChanged;
  set queue(STREAM_TYPE t){
    switch(t){
      case STREAM_TYPE.MP3192:
        AudioServiceBackground.setQueue(_mp3_192);
        break;
      case STREAM_TYPE.MP3320:
        AudioServiceBackground.setQueue(_mp3_320);
        break;
      case STREAM_TYPE.OGG_LOW:
        AudioServiceBackground.setQueue(_ogg_low);
        break;
      case STREAM_TYPE.OGG_HIGH:
        AudioServiceBackground.setQueue(_ogg_high);
        break;
      default:
        AudioServiceBackground.setQueue(_aac);
    }
  }
  final List<String> latest;
  final ValueNotifier<STREAM_TYPE> streamType;
  final TextEditingController _currentSong = TextEditingController();
  final ValueNotifier<bool> _playing = ValueNotifier(true);
  final List<MediaItem> _aac = <MediaItem>[
    MediaItem(
        id: 'http://ebm-radio.org:8000',
        title: '(((EBM Radio)))',
        album: 'AAC 8K'
    )
  ];
  final List<MediaItem> _mp3_192 = <MediaItem>[
    MediaItem(
        id: 'http://ebm-radio.org:7000',
        title: '(((EBM Radio)))',
        album: 'MP3 192K'
    )
  ];
  final List<MediaItem> _mp3_320 = <MediaItem>[
    MediaItem(
        id: 'http://ebm-radio.org:7000/hq',
        title: '(((EBM Radio)))',
        album: 'MP3 320K'
    )
  ];
  final List<MediaItem> _ogg_low = <MediaItem>[
    MediaItem(
        id: 'http://ebm-radio.org:9000/ebm.ogg',
        title: '(((EBM Radio)))',
        album: 'MP3 320K'
    )
  ];
  final List<MediaItem> _ogg_high = <MediaItem>[
    MediaItem(
        id: 'http://ebm-radio.org:9000/ebm_high.ogg',
        title: '(((EBM Radio)))',
        album: 'MP3 320K'
    )
  ];
}

class _EbmPlayer extends State<EbmPlayer> with WidgetsBindingObserver{
  void _loadTracks() async {
    print("load tracks");
    Map<String,String> m = Map();
    m["sid"]="1";
    String str = await HttpUtils.getForString("http://ebm-radio.org:7000/stats",headers: m);
    XmlDocument doc = parse(str);
    Iterable<XmlElement> elem = doc.findAllElements("SONGTITLE");
    XmlElement e1 = elem.first;
    print(e1.firstChild);
    print(Platform.operatingSystem);
    if(e1.firstChild.text != null && e1.firstChild.text != widget._currentSong.text){
      setState(() {
        widget._currentSong.text = e1.firstChild.text;
        if(widget.latest.length == 10) widget.latest.removeLast();
        widget.latest.insert(0, e1.firstChild.text);
        widget.lastChanged.value = e1.firstChild.text;
      });
    }
  }
  void initState(){
    print("Player init State");
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AudioService.start(
        backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
        androidNotificationChannelName: '(((EBM Radio)))',
        androidNotificationColor: 0xFF5cb12d,
        androidNotificationIcon: 'mipmap/ic_stat_ebm_radio_bw',
        androidEnableQueue: false,
        androidStopForegroundOnPause: true
        // androidArtDownscaleSize: Size.square(100.0)
    );
    AudioService.currentMediaItemStream.listen((event) {
      // print(event);
      if(event != null && event.title != null && event.title != widget._currentSong.text)
        setState(() {
          widget._currentSong.text = event.title;
          if(widget.latest.indexOf(event.title) < 0) {
            if (widget.latest.length == 10) {
              widget.latest.removeLast();
            }
            widget.latest.insert(0, event.title);
            widget.lastChanged.value = event.title;
          }
        });
    });
    AudioService.playbackStateStream.listen((event) {
      if(event.playing != widget._playing.value)
        setState(() {
          widget._playing.value = event.playing;
        });
    });
    if(Platform.isIOS){
      _loadTracks();
      Timer.periodic(Duration(seconds: 10), (timer) {
        print("timer run");
        _loadTracks();
      });
    }
    /* switch(widget.streamType.value){
      case STREAM_TYPE.MP3192:
        AudioServiceBackground.setQueue(widget._mp3_192);
        break;
      case STREAM_TYPE.MP3320:
        AudioServiceBackground.setQueue(widget._mp3_320);
        break;
      default:
        AudioServiceBackground.setQueue(widget._aac);
    }*/
    widget.streamType.addListener(() {
      //_streamChange();
    });

  }
  _loadLatestFromBackground() async {
    print("loadLatestFromBackground");
    await AudioService.connect();
    List<dynamic> lts = await AudioService.customAction("getLatest");
    if(lts != null){
      setState(() {
        widget.latest.clear();
        lts.reversed.forEach((element) {
          widget.latest.insert(0, element.toString());
          // widget.latest.add(element.toString());
          print("adding: " + element.toString());
        });

        widget.lastChanged.value = lts[0].toString();
        widget.lastChanged.notifyListeners();
      });
    }
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    print("didChangeAppLifecycleState");
    print(state);
    if(state == AppLifecycleState.resumed){
      AudioService.connect();
    }
  }
  void _streamChange() async {
    print("Stream Changed: " + widget.streamType.value.toString());
    // await AudioService.pause();
    switch(widget.streamType.value){
      case STREAM_TYPE.MP3192:
        await AudioService.updateQueue(widget._mp3_192);
        break;
      case STREAM_TYPE.MP3320:
        await AudioService.updateQueue(widget._mp3_320);
        break;
      case STREAM_TYPE.OGG_LOW:
        await AudioService.updateQueue(widget._ogg_low);
        break;
      case STREAM_TYPE.OGG_HIGH:
        await AudioService.updateQueue(widget._ogg_high);
        break;
      default:
        await AudioService.updateQueue(widget._aac);
    }
    // await AudioService.play();
  }
  void dispose(){
    stopAll();
    super.dispose();
  }
  stopAll() async {
    await AudioService.stop();
  }
  start() => AudioService.play();
  pause() => AudioService.pause();
  stop() => AudioService.stop();
  Widget build(BuildContext context){
    return AudioServiceWidget(
        child: Container(
          height: 280,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/radiologo.png'),
              fit: BoxFit.fitWidth
            )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: widget._currentSong,
                enabled: false,
                readOnly: true,
                textAlign: TextAlign.center,
              ),
              Spacer(
                flex: 2,
              ),
              Visibility(
                visible: widget._playing.value,
                child: RaisedButton(
                  child: Text("Pause"),
                  onPressed: pause,
                ),
              ),
              Visibility(
                visible: !widget._playing.value,
                child: RaisedButton(
                  child: Text("Play"),
                  onPressed: start,
                ),
              )
            ],
          ),
        )
    );
  }
}

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl skipToNextControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_next',
  label: 'Next',
  action: MediaAction.skipToNext,
);
MediaControl skipToPreviousControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_previous',
  label: 'Previous',
  action: MediaAction.skipToPrevious,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class AudioPlayerTask extends BackgroundAudioTask {
  final _queue = <MediaItem>[
    MediaItem(
        id: 'http://ebm-radio.org:8000',
        title: '(((EBM Radio)))',
        album: '(((EBM Radio)))'
    ),
  ];
  int _queueIndex = -1;
  AudioPlayer _audioPlayer = new AudioPlayer();
  AudioProcessingState _skipState;
  bool _playing;
  bool _interrupted = false;

  bool get hasNext => _queueIndex + 1 < _queue.length;

  bool get hasPrevious => _queueIndex > 0;

  MediaItem get mediaItem => _queue[_queueIndex];

  StreamSubscription<AudioPlaybackState> _playerStateSubscription;
  StreamSubscription<AudioPlaybackEvent> _eventSubscription;

  final List<String> _latestTracks = List<String>();

  @override
  Future<dynamic> onCustomAction(String name, dynamic arguments){
    if(name == "getLatest"){
      return Future.value(_latestTracks);
    }
    return null;
  }
  @override
  void onStart(Map<String, dynamic> params) {
    AudioPlayer.setIosCategory(IosCategory.playback);
    _playerStateSubscription = _audioPlayer.playbackStateStream
        .where((state) => state == AudioPlaybackState.completed)
        .listen((state) {
      _handlePlaybackCompleted();
    });
    _audioPlayer.icyMetadataStream.listen((event) {
      if(event != null && event.info != null && event.info.title != null && event.info.title != "") {
        MediaItem current = this.mediaItem.copyWith(title: event.info.title);
        AudioServiceBackground.setMediaItem(current);
        if(_latestTracks.length == 0 || _latestTracks[0] != event.info.title) {
          print("BG-Info" + event.info.title);
          if (_latestTracks.length == 10) {
            _latestTracks.removeLast();
          }
          _latestTracks.insert(0, event.info.title);
        }
      }
    });
    _eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      final bufferingState =
      event.buffering ? AudioProcessingState.buffering : null;
      switch (event.state) {
        case AudioPlaybackState.paused:
          _setState(
            processingState: bufferingState ?? AudioProcessingState.ready,
            position: event.position,
          );
          break;
        case AudioPlaybackState.playing:
          _setState(
            processingState: bufferingState ?? AudioProcessingState.ready,
            position: event.position,
          );
          break;
        case AudioPlaybackState.connecting:
          _setState(
            processingState: _skipState ?? AudioProcessingState.connecting,
            position: event.position,
          );
          break;
        default:
          break;
      }
    });

    AudioServiceBackground.setQueue(_queue);
    onSkipToNext();
  }

  @override
  Future<void> onUpdateQueue(List<MediaItem> newQueue) async {
    print("newQueue");
    MediaItem item = this.mediaItem.copyWith(
      id: newQueue[0].id,
      album: newQueue[0].album
    );
    print(item.id);
    await _audioPlayer.stop();
    Map<String,String> m = Map();
    m["Icy-Meta"]="1";
    await _audioPlayer.setUrl(item.id);
    await AudioServiceBackground.setMediaItem(item);
    await _audioPlayer.play();
    //_queueIndex = -1;
    //onSkipToNext();
  }
  void _handlePlaybackCompleted() {
    if (hasNext) {
      onSkipToNext();
    } else {
      onStop();
    }
  }

  void playPause() {
    if (AudioServiceBackground.state.playing)
      onPause();
    else
      onPlay();
  }

  @override
  Future<void> onSkipToNext() => _skip(1);

  @override
  Future<void> onSkipToPrevious() => _skip(-1);

  Future<void> _skip(int offset) async {
    final newPos = _queueIndex + offset;
    if (!(newPos >= 0 && newPos < _queue.length)) return;
    if (_playing == null) {
      // First time, we want to start playing
      _playing = true;
    } else if (_playing) {
      // Stop current item
      await _audioPlayer.stop();
    }
    // Load next item
    _queueIndex = newPos;
    AudioServiceBackground.setMediaItem(mediaItem);
    _skipState = offset > 0
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;
    Map<String,String> m = Map();
    m["Icy-Meta"] = "1";
    await _audioPlayer.setUrl(mediaItem.id);
    _skipState = null;
    // Resume playback if we were playing
    if (_playing) {
      onPlay();
    } else {
      _setState(processingState: AudioProcessingState.ready);
    }
  }

  @override
  void onPlay() {
    if (_skipState == null) {
      _playing = true;
      _audioPlayer.play();
      AudioServiceBackground.sendCustomEvent('just played');
    }
  }

  @override
  void onPause() {
    if (_skipState == null) {
      _playing = false;
      _audioPlayer.pause();
      AudioServiceBackground.sendCustomEvent('just paused');
    }
  }

  @override
  void onSeekTo(Duration position) {
    _audioPlayer.seek(position);
  }

  @override
  void onClick(MediaButton button) {
    playPause();
  }

  @override
  Future<void> onFastForward() async {
    await _seekRelative(fastForwardInterval);
  }

  @override
  Future<void> onRewind() async {
    await _seekRelative(-rewindInterval);
  }

  Future<void> _seekRelative(Duration offset) async {
    var newPosition = _audioPlayer.playbackEvent.position + offset;
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > mediaItem.duration) newPosition = mediaItem.duration;
    await _audioPlayer.seek(newPosition);
  }

  @override
  Future<void> onStop() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    _playing = false;
    _playerStateSubscription.cancel();
    _eventSubscription.cancel();
    await _setState(processingState: AudioProcessingState.stopped);
    // Shut down this task
    await super.onStop();
  }

  /* Handling Audio Focus */
  @override
  void onAudioFocusLost(AudioInterruption interruption) {
    if (_playing) _interrupted = true;
    switch (interruption) {
      case AudioInterruption.pause:
      case AudioInterruption.temporaryPause:
      case AudioInterruption.unknownPause:
        onPause();
        break;
      case AudioInterruption.temporaryDuck:
        _audioPlayer.setVolume(0.5);
        break;
    }
  }

  @override
  void onAudioFocusGained(AudioInterruption interruption) {
    switch (interruption) {
      case AudioInterruption.temporaryPause:
        if (!_playing && _interrupted) onPlay();
        break;
      case AudioInterruption.temporaryDuck:
        _audioPlayer.setVolume(1.0);
        break;
      default:
        break;
    }
    _interrupted = false;
  }

  @override
  void onAudioBecomingNoisy() {
    onPause();
  }

  Future<void> _setState({
    AudioProcessingState processingState,
    Duration position,
    Duration bufferedPosition,
  }) async {
    if (position == null) {
      position = _audioPlayer.playbackEvent.position;
    }
    await AudioServiceBackground.setState(
      controls: getControls(),
      systemActions: [MediaAction.seekTo],
      processingState:
      processingState ?? AudioServiceBackground.state.processingState,
      playing: _playing,
      position: position,
      bufferedPosition: bufferedPosition ?? position,
      speed: _audioPlayer.speed,
    );
  }

  List<MediaControl> getControls() {
    if (_playing) {
      return [
        // skipToPreviousControl,
        pauseControl,
        // stopControl,
        // skipToNextControl
      ];
    } else {
      return [
        // skipToPreviousControl,
        playControl,
        // stopControl,
        // skipToNextControl
      ];
    }
  }
}
