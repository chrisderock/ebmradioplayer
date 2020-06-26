import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:basic_utils/basic_utils.dart';
import 'dart:async';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';

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
  final String _whishStatusUri = "https://www.ebm-radio.de/scripts/wunschform_status/status.php";
  final String _wishSendUrl = "https://www.ebm-radio.de/scripts/wunschform_status/wish.php";
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
  // String _dropDownValue = "AAC 8k";
  AudioPlayer _player;
  void initState(){
    super.initState();

    AudioPlayer.setIosCategory(IosCategory.playback);
    _player = AudioPlayer();
    // _player.setUrl(widget._url);
    Stream<IcyMetadata> s = _player.icyMetadataStream;
    s.listen((event) {
      print(event.info.title);
      print(widget._running.value);
      setState(() {
        widget._current.text = event.info.title;
      });
    });
    Timer.periodic(Duration(minutes: 5), (timer) {
      print("Timer run");
      _wishFormStatus();
    });
  }
  _wishFormStatus() async {
    String ret = await HttpUtils.getForString(widget._whishStatusUri);
    setState(() {
      widget._wishes.value = (ret == "1" ? true : false);
    });
  }
  _playPause() async {
    if(_player.playbackState == AudioPlaybackState.playing){
      await _player.stop();
    }else {
      await _player.setUrl(widget._url).catchError((err){
        widget._current.text = err.toString();
      });
      await _player.play();
    }
  }
  _sendWish(BuildContext ctx) async {
    if(widget._name.text.isEmpty){
      Scaffold.of(ctx).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(S.current.enterYourName),
      ));
      return;
    }
    if(widget._song.text.isEmpty){
      Scaffold.of(ctx).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(S.current.enterASong),
      ));
      return;
    }
    if(widget._artist.text.isEmpty){
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
    print(resp);
    widget._song.clear();
    widget._artist.clear();
    widget._greetings.clear();
    Scaffold.of(ctx).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Text(S.current.wishSent),
    ));
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
            style: TextStyle(
              backgroundColor: Colors.black,
              color: Colors.green
            ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                'Strange music for strange people',
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                ),
              ),
              Image(
                image: AssetImage('assets/radiologo.png'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget._current,
                      readOnly: true,
                      style: TextStyle(
                          color: Colors.green
                      ),
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
                  shape: Border.all(
                      width: 2.0,
                      color: Colors.green
                  ),
                  onPressed: (){
                    widget._running.value = true;
                    _playPause();
                  },
                  icon: Icon(
                    Icons.play_arrow,
                    color: Colors.green,
                  ),
                  label: Text("Play", style: TextStyle(color: Colors.green),),
                ),
              ),
              Visibility(
                visible: widget._running.value,
                child: RaisedButton.icon(
                  color: Colors.black,
                  shape: Border.all(
                      width: 2.0,
                      color: Colors.green
                  ),
                  onPressed: (){
                    widget._running.value = false;
                    _playPause();
                  },
                  icon: Icon(
                    Icons.stop,
                    color: Colors.green,
                  ),
                  label: Text("Stop", style: TextStyle(color: Colors.green),),
                ),
              ),
              //Spacer(),
              Builder(
                builder: (BuildContext context){
                  return Visibility(
                      visible: widget._wishes.value,
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                            border: Border.all(width: 2.0, color: Colors.green)
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Text(S.current.makeAWish,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              TextField(
                                decoration: InputDecoration(
                                    hintText: S.current.yourName,
                                    hintStyle: TextStyle(color: Colors.green),
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 2.0,
                                            color: Colors.green
                                        )
                                    )
                                ),
                                style: TextStyle(color: Colors.green),
                                controller: widget._name,
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: S.current.songName,
                                  hintStyle: TextStyle(color: Colors.green),
                                ),
                                style: TextStyle(color: Colors.green),
                                controller: widget._song,
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: S.current.artist,
                                  hintStyle: TextStyle(color: Colors.green),
                                ),
                                style: TextStyle(color: Colors.green),
                                controller: widget._artist,
                              ),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: S.current.greetings,
                                  hintStyle: TextStyle(color: Colors.green),
                                ),
                                style: TextStyle(color: Colors.green),
                                controller: widget._greetings,
                                minLines: 2,
                                maxLines: 2,
                                textInputAction: TextInputAction.send,
                                onEditingComplete: (){
                                  _sendWish(context);
                                },
                              ),
                              RaisedButton(
                                child: Text(S.current.send, style: TextStyle(color: Colors.green),),
                                color: Colors.black,
                                shape: Border.all(
                                    width: 2.0,
                                    color: Colors.green
                                ),
                                onPressed: (){
                                  print("sending...");
                                  _sendWish(context);
                                },
                              )
                            ],
                          ),
                        ),
                      )
                  );
                },
              )
            ],
          ),
        ),
      )
    );
  }
}
