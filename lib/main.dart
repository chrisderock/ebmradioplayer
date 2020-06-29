import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:basic_utils/basic_utils.dart';
import 'dart:async';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';
import 'package:webfeed/webfeed.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:localstorage/localstorage.dart';

enum STREAM_TYPE {
  AAC,
  MP3192,
  MP3320,
  UNKNOWN
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: '(((EBM Radio)))'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  /// holds the current streamed title
  final TextEditingController _current = TextEditingController();
  /// the current stream-url
  final ValueNotifier<String> _streamUrl = ValueNotifier("http://ebm-radio.org:8000");
  /// the url to check the status for the whishform
  final String _whishStatusUri =
      "https://www.ebm-radio.de/scripts/wunschform_status/status.php";
  final String _wishSendUrl =
  /// the url to post a whish
      "https://www.ebm-radio.de/scripts/wunschform_status/wish.php";
  /// the url of the newsfeed
  final String _feedUrl = 'https://ebm-radio.de/index.php?format=feed&type=rss';
  /// is the stream running or not?
  final ValueNotifier<bool> _running = ValueNotifier(false);
  /// is the whishform active or not?
  final ValueNotifier<bool> _wishes = ValueNotifier(false);
  /// holds the name of the user for the whishform
  final TextEditingController _name = TextEditingController();
  /// holds the songtitle for the whishform
  final TextEditingController _song = TextEditingController();
  /// the band/artist for the whishform
  final TextEditingController _artist = TextEditingController();
  /// greetings from the whishform
  final TextEditingController _greetings = TextEditingController();
  /// the configuration for the stream url
  final ValueNotifier<STREAM_TYPE> _type = ValueNotifier(STREAM_TYPE.UNKNOWN);
  /// for storing the stream type
  final LocalStorage _localStorage = LocalStorage("ebmradioplayer");
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// the player itself
  AudioPlayer _player;
  /// the newsitems
  List<String> _newsItems = List();
  /// init the player page
  void initState() {
    super.initState();
    /// get the current stream configuration and set the matching url
    var type = widget._localStorage.getItem("type");
    if(type == null)
      type = "0";
    widget._type.value = STREAM_TYPE.values[int.parse(type)];
    switch(widget._type.value) {
      case STREAM_TYPE.AAC:
        print("AAC");
        widget._streamUrl.value = "http://ebm-radio.org:8000";
        break;
      case STREAM_TYPE.MP3192:
        print("192");
        widget._streamUrl.value = "http://ebm-radio.org:7000";
        break;
      case STREAM_TYPE.MP3320:
        print("320");
        widget._streamUrl.value = "http://ebm-radio.org:7000/hq";
        break;
      default:
        widget._streamUrl.value = "http://ebm-radio.org:8000";
    }
    /// init the player
    AudioPlayer.setIosCategory(IosCategory.playback);
    _player = AudioPlayer();
    Stream<IcyMetadata> s = _player.icyMetadataStream;
    s.listen((event) {
      print(event.info.title);
      print(widget._running.value);
      setState(() {
        widget._current.text = event.info.title;
      });
    });
    /// check periodic for the status of the whishform
    Timer.periodic(Duration(minutes: 5, seconds: 0), (timer) {
      print("Timer run");
      _wishFormStatus();
    });
    /// check periodic for news
    Timer.periodic(Duration(hours: 1), (timer) {
      _feed();
    });
    _feed();
  }
  /// load the current newsfeed and display them
  _feed() async {
    var feed = await HttpUtils.getForString(widget._feedUrl);
    var rss = RssFeed.parse(feed);
    setState(() {
      int i = 0;
      _newsItems.clear();
      rss.items.forEach((element) {
        if(i++ < 11) {
          print(element.title);
          _newsItems.add(element.title);
        }
      });
    });
  }
  /// check the state of the whishform
  _wishFormStatus() async {
    String ret = await HttpUtils.getForString(widget._whishStatusUri);
    setState(() {
      widget._wishes.value = (ret == "1" ? true : false);
    });
  }
  /// start and stop the player
  _playPause() async {
    if (_player.playbackState == AudioPlaybackState.playing) {
      await _player.stop();
    } else {
      await _player.setUrl(widget._streamUrl.value).catchError((err) {
        widget._current.text = err.toString();
      });
      await _player.play();
    }
  }
  /// send a whish
  _sendWish(BuildContext ctx) async {
    if (widget._name.text.isEmpty) {
      Scaffold.of(ctx).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(S.current.enterYourName),
      ));
      return;
    }
    if (widget._song.text.isEmpty) {
      Scaffold.of(ctx).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(S.current.enterASong),
      ));
      return;
    }
    if (widget._artist.text.isEmpty) {
      Scaffold.of(ctx).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(S.current.enterArtist),
      ));
      return;
    }
    String uri = widget._wishSendUrl + '?interpret='
        + widget._artist.text + '&song='
        + widget._song.text + '&name='
        + widget._name.text + '&gruesse='
        + widget._greetings.text;
    String send = Uri.encodeFull(uri);
    print(send);
    var resp = await HttpUtils.getForString(send);
    /* String bdy = 'name=' +
        Uri.encodeComponent(widget._name.text) +
        '&interpret=' +
        Uri.encodeComponent(widget._artist.text) +
        '&song=' +
        Uri.encodeComponent(widget._song.text) +
        '&gruesse=' +
        Uri.encodeComponent(widget._greetings.text);
    print(bdy);
    Map<String, String> hdr = Map();
    hdr['Content-Type'] = 'application/x-www-form-urlencoded';
    var resp = await HttpUtils.postForString(widget._wishSendUrl, body: bdy);*/
    print(resp);
    widget._song.clear();
    widget._artist.clear();
    widget._greetings.clear();
    Scaffold.of(ctx).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Text(S.current.wishSent),
    ));
  }
  /// visit a url via browser
  _visitWeb(String url) async {
    if(await canLaunch(url)){
      await launch(url);
    }
  }
  /// show the config dialog and configure the stream source
  _configure(BuildContext ctx) async {
    var stream = await showDialog(
        context: ctx,
      builder: (BuildContext context){
          return _ConfigDialog(
            type: widget._type,
          );
      }
    );
    switch(stream){
      case STREAM_TYPE.AAC:
        print("AAC");
        widget._streamUrl.value = "http://ebm-radio.org:8000";
        widget._localStorage.setItem("type", 0);
        break;
      case STREAM_TYPE.MP3192:
        print("192");
        widget._streamUrl.value = "http://ebm-radio.org:7000";
        widget._localStorage.setItem("type", 1);
        break;
      case STREAM_TYPE.MP3320:
        print("320");
        widget._streamUrl.value = "http://ebm-radio.org:7000/hq";
        widget._localStorage.setItem("type", 2);
        break;
      default:
        print("No Changes");
    }
  }
  /// show the user interface
  @override
  Widget build(BuildContext context) {
    Locale _l = Localizations.localeOf(context);
    S.load(_l);
    print(_l);
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            widget.title,
            style:
                TextStyle(backgroundColor: Colors.black, color: Colors.green),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          actions: [ /// the configuration menu
            PopupMenuButton(
              onSelected: (res){
                print("on select");
                _configure(context);
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                const PopupMenuItem(
                  value: 1,
                    child: Text(
                      "Configure",
                      style: TextStyle(color: Colors.green),
                    )
                )
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                /// the top view that dosnt change
                Text(
                  'Strange music for strange people',
                  style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Image(
                  image: AssetImage('assets/radiologo.png'),
                  fit: BoxFit.fitWidth,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget._current,
                        readOnly: true,
                        enabled: false,
                        style: TextStyle(color: Colors.green),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        minLines: 1,
                      ),
                    )
                  ],
                ),
                Visibility(
                  visible: !widget._running.value,
                  child: RaisedButton.icon(
                    color: Colors.black,
                    shape: Border.all(width: 2.0, color: Colors.green),
                    onPressed: () {
                      widget._running.value = true;
                      _playPause();
                    },
                    icon: Icon(
                      Icons.play_arrow,
                      color: Colors.green,
                    ),
                    label: Text(
                      "Play",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ),
                Visibility(
                  visible: widget._running.value,
                  child: RaisedButton.icon(
                    color: Colors.black,
                    shape: Border.all(width: 2.0, color: Colors.green),
                    onPressed: () {
                      widget._running.value = false;
                      _playPause();
                    },
                    icon: Icon(
                      Icons.stop,
                      color: Colors.green,
                    ),
                    label: Text(
                      "Stop",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ),
                /// the whishform
                Builder(
                  builder: (BuildContext context) {
                    return Column(children: [
                      Visibility(
                          visible: widget._wishes.value,
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2.0, color: Colors.green)),
                            child: Center(
                              child: Column(
                                children: [
                                  Text(
                                    S.current.makeAWish,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: S.current.yourName,
                                      hintStyle: TextStyle(color: Colors.green),
                                    ),
                                    style: TextStyle(color: Colors.green),
                                    controller: widget._name,
                                    scrollPadding: EdgeInsets.all(80.0),
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: S.current.songName,
                                      hintStyle: TextStyle(color: Colors.green),
                                    ),
                                    style: TextStyle(color: Colors.green),
                                    controller: widget._song,
                                    scrollPadding: EdgeInsets.all(80.0),
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: S.current.artist,
                                      hintStyle: TextStyle(color: Colors.green),
                                    ),
                                    style: TextStyle(color: Colors.green),
                                    controller: widget._artist,
                                    scrollPadding: EdgeInsets.all(80.0),
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: S.current.greetings,
                                      hintStyle: TextStyle(color: Colors.green),
                                    ),
                                    style: TextStyle(color: Colors.green),
                                    controller: widget._greetings,
                                    scrollPadding: EdgeInsets.all(80.0),
                                    minLines: 2,
                                    maxLines: 2,
                                    textInputAction: TextInputAction.send,
                                    onEditingComplete: () {
                                      _sendWish(context);
                                    },
                                  ),
                                  RaisedButton(
                                    child: Text(
                                      S.current.send,
                                      style: TextStyle(color: Colors.green),
                                    ),
                                    color: Colors.black,
                                    shape: Border.all(
                                        width: 2.0, color: Colors.green),
                                    onPressed: () {
                                      print("sending...");
                                      _sendWish(context);
                                    },
                                  )
                                ],
                              ),
                            ),
                          )
                      ),
                      /// the newsfeed
                      Visibility(
                        visible: !widget._wishes.value,
                        child: SizedBox(
                          // padding: const EdgeInsets.all(20.0),
                          height: 300.0,
                          child: Column(
                            children: [
                              Text(
                                "News",
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: _newsItems.length,
                                itemBuilder: (BuildContext ctxt, int index){
                                  return new Text(
                                      _newsItems[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.green),
                                  );
                                },
                              ),
                              RaisedButton(
                                color: Colors.black,
                                shape: Border.all(
                                    width: 2.0, color: Colors.green),
                                onPressed: () {
                                  _visitWeb("https://ebm-radio.de");
                                },
                                child: Text(
                                    S.current.ourWebsite,
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                              Spacer(),
                              /// social buttons
                              Row(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    fit: FlexFit.tight,
                                    child: RaisedButton(
                                      color: Colors.black,
                                      child: Image(
                                        image: AssetImage("assets/facebook.png"),
                                      ),
                                      onPressed: (){
                                        _visitWeb("https://www.facebook.com/groups/ebm.radio/");
                                      },
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    fit: FlexFit.tight,
                                    child: RaisedButton(
                                      color: Colors.black,
                                      child: Image(
                                        image: AssetImage("assets/telegram.png"),
                                      ),
                                      onPressed: (){
                                        _visitWeb("https://t.me/ebm_radio");
                                      },
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    fit: FlexFit.tight,
                                    child: RaisedButton(
                                      color: Colors.black,
                                      child: Image(
                                        image: AssetImage("assets/instagram.png"),
                                      ),
                                      onPressed: (){
                                        _visitWeb("https://www.instagram.com/ebm_radio/");
                                      },
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    fit: FlexFit.tight,
                                    child: RaisedButton(
                                      color: Colors.black,
                                      child: Image(
                                        image: AssetImage("assets/twitter.png"),
                                      ),
                                      onPressed: (){
                                        _visitWeb("https://twitter.com/ebm_radio");
                                      },
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ]);
                  },
                )
              ],
            ),
          ),
        ));
  }
}
/// the configuration dialog
class _ConfigDialog extends StatefulWidget {
  _ConfigDialog({this.type});
  _ConfigDialogState createState() => _ConfigDialogState();
  final ValueNotifier<STREAM_TYPE> type;
}

class _ConfigDialogState extends State<_ConfigDialog>{
  Widget build(BuildContext context){
    return SimpleDialog(
      title: Text(S.current.configStream),
      children: [
        ListTile(
          title: const Text("AAC 8k"),
          leading: Radio(
            value: STREAM_TYPE.AAC,
            groupValue: widget.type.value,
            onChanged: (val){
              setState(() {
                widget.type.value = val;
              });
            },
          ),
        ),
        ListTile(
          title: const Text("MP3 192k"),
          leading: Radio(
            value: STREAM_TYPE.MP3192,
            groupValue: widget.type.value,
            onChanged: (val){
              setState(() {
                widget.type.value = val;
              });
            },
          ),
        ),
        ListTile(
          title: const Text("MP3 320k"),
          leading: Radio(
            value: STREAM_TYPE.MP3320,
            groupValue: widget.type.value,
            onChanged: (val){
              setState(() {
                widget.type.value = val;
              });
            },
          ),
        ),
        SimpleDialogOption(
          child: const Text("OK"),
          onPressed: (){
            Navigator.pop(context, widget.type.value);
          },
        )
      ],
    );
  }
}