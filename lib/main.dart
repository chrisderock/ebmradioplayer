import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:basic_utils/basic_utils.dart';
import 'dart:async';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';
import 'package:webfeed/webfeed.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final TextEditingController _current = TextEditingController();
  final String _url = "http://ebm-radio.org:7000/";
  final String _whishStatusUri =
      "https://www.ebm-radio.de/scripts/wunschform_status/status.php";
  final String _wishSendUrl =
      "https://www.ebm-radio.de/scripts/wunschform_status/wish.php";
  final String _feedUrl = 'https://ebm-radio.de/index.php?format=feed&type=rss';
  final ValueNotifier<bool> _running = ValueNotifier(false);
  final ValueNotifier<bool> _wishes = ValueNotifier(false);
  final TextEditingController _name = TextEditingController();
  final TextEditingController _song = TextEditingController();
  final TextEditingController _artist = TextEditingController();
  final TextEditingController _greetings = TextEditingController();
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AudioPlayer _player;
  List<String> _newsItems = List();
  void initState() {
    super.initState();

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
    Timer.periodic(Duration(minutes: 5, seconds: 0), (timer) {
      print("Timer run");
      _wishFormStatus();
    });
    Timer.periodic(Duration(hours: 1), (timer) {
      _feed();
    });
    _feed();
  }

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

  _wishFormStatus() async {
    String ret = await HttpUtils.getForString(widget._whishStatusUri);
    setState(() {
      widget._wishes.value = (ret == "1" ? true : false);
    });
  }

  _playPause() async {
    if (_player.playbackState == AudioPlaybackState.playing) {
      await _player.stop();
    } else {
      await _player.setUrl(widget._url).catchError((err) {
        widget._current.text = err.toString();
      });
      await _player.play();
    }
  }

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
    /*
    String uri = widget._wishSendUrl + '?interpret='
        + widget._artist.text + '&song='
        + widget._song.text + '&name='
        + widget._name.text + '&gruesse='
        + widget._greetings.text;
    String send = Uri.encodeFull(uri);
    print(send);
     */
    // var resp = await HttpUtils.getForString(send);
    String bdy = 'name=' +
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
    var resp = await HttpUtils.postForString(widget._wishSendUrl, body: bdy);
    print(resp);
    widget._song.clear();
    widget._artist.clear();
    widget._greetings.clear();
    Scaffold.of(ctx).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Text(S.current.wishSent),
    ));
  }
  _visitWeb(String url) async {
    if(await canLaunch(url)){
      await launch(url);
    }
  }
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
        ),
        body: SingleChildScrollView(

          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
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
                        maxLines: 3,
                        minLines: 3,
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
                //Spacer(),
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
                                        image: AssetImage("assets/flickr.png"),
                                      ),
                                      onPressed: (){
                                        _visitWeb("https://www.flickr.com/photos/154224693@N07/");
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
