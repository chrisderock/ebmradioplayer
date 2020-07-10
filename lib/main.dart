import 'package:ebmradioplayer/gui/ebm_latest.dart';
import 'package:ebmradioplayer/gui/ebm_news.dart';
import 'package:ebmradioplayer/gui/ebm_player.dart';
import 'package:ebmradioplayer/gui/ebm_social.dart';
import 'package:ebmradioplayer/gui/ebm_theme.dart';
import 'package:ebmradioplayer/gui/ebm_wishform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
      theme: getEbmTheme(),
      // home: MyHomePage(title: '(((EBM Radio)))'),
      home: MyHomePage(title: '(((EBM Radio)))',),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  final String _wishSendUrl =
      "https://www.ebm-radio.de/scripts/wunschform_status/wish.php";
  final String _feedUrl = 'https://ebm-radio.de/index.php?format=feed&type=rss';
  final String _homeUrl = "https://ebm-radio.de";
  final List<String> _latest = List<String>();
  final ValueNotifier<String> _latestChanged = ValueNotifier("");
  /// the configuration for the stream url
  final ValueNotifier<STREAM_TYPE> _type = ValueNotifier(STREAM_TYPE.UNKNOWN);
  /// for storing the stream type
  final FlutterSecureStorage _localStorage = new FlutterSecureStorage();
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// the player itself
  // AudioPlayer _player;
  List<Widget> _widgets;
  int _selectedIndex = 0;
  void _navBarTap(int index){
    setState(() {
      _selectedIndex = index;
    });
  }
  void _readData() async{
    var type = await widget._localStorage.read(key: "type");
    print(type);
    widget._type.value = type == null ? STREAM_TYPE.AAC : STREAM_TYPE.values.firstWhere((element) => element.toString() == type);
  }
  /// init the player page
  void initState() {
    super.initState();
    _readData();
    _widgets = <Widget>[
      EbmNews(
        newsFeed: widget._feedUrl,
        webUrl: widget._homeUrl,
      ),
      EbmWishform(
        sendUrl: widget._wishSendUrl,
        storage: widget._localStorage,
      ),
      EbmSocial(

      ),
      EbmLatest(
        latest: widget._latest,
        lastChanged: widget._latestChanged,
      )
    ];
  }
  _configure(BuildContext context) async {
    STREAM_TYPE stream = await showDialog(
      context: context,
      builder: (BuildContext context){
        return _ConfigDialog(type: widget._type,);
      }
    );
    setState(() {
      print(widget._type.value);
      widget._localStorage.write(key: "type", value: stream.toString());
      widget._type.value = stream;
      // widget._type.notifyListeners();
    });
  }
  /// show the user interface
  @override
  Widget build(BuildContext context) {
    Locale _l = Localizations.localeOf(context);
    S.load(_l);
    print(_l);
    return Scaffold(
        // backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          actions: [ /// the configuration menu
            PopupMenuButton(
              onSelected: (res){
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
                EbmPlayer(
                  latest: widget._latest,
                  streamType: widget._type,
                  lastChanged: widget._latestChanged,
                ),
                Container(
                  child: _widgets.elementAt(_selectedIndex),
                )
              ],
            ),
          ),
        ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        // fixedColor: Colors.black,
        // selectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Colors.black,
            title: Text("News",
              style: TextStyle(color: Colors.green),
            ),
            icon: Icon(
                Icons.new_releases,
              color: Colors.green,
            ),
            activeIcon: Icon(
              Icons.new_releases,
              color: Colors.lightGreen,
            )
          ),
          BottomNavigationBarItem(
            title: Text("Wishes",
              style: TextStyle(color: Colors.green),
            ),
            icon: Icon(Icons.question_answer,
              color: Colors.green,
            ),
            activeIcon: Icon(
              Icons.question_answer,
              color: Colors.lightGreen,
            )
          ),
          BottomNavigationBarItem(
              title: Text("Social",
                style: TextStyle(color: Colors.green),
              ),
              icon: Icon(Icons.public,
                color: Colors.green,
              ),
              activeIcon: Icon(
                Icons.public,
                color: Colors.lightGreen,
              )
          ),
          BottomNavigationBarItem(
              title: Text("Latest Tracks",
                style: TextStyle(color: Colors.green),
              ),
              icon: Icon(Icons.format_list_bulleted,
                color: Colors.green,
              ),
              activeIcon: Icon(
                Icons.format_list_bulleted,
                color: Colors.lightGreen,
              )
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _navBarTap,
      ),
    );
  }
}
/// the configuration dialog
class _ConfigDialog extends StatefulWidget {
  _ConfigDialog({this.type});
  _ConfigDialogState createState() => _ConfigDialogState();
  final ValueNotifier<STREAM_TYPE> type;
  final ValueNotifier<STREAM_TYPE> _newType = ValueNotifier(STREAM_TYPE.UNKNOWN);
}

class _ConfigDialogState extends State<_ConfigDialog>{
  void initState(){
    super.initState();
    widget._newType.value = widget.type.value;
  }
  Widget build(BuildContext context){
    return SimpleDialog(
      title: Text(S.current.configStream),
      children: [
        ListTile(
          title: const Text("AAC 8k"),
          leading: Radio(
            value: STREAM_TYPE.AAC,
            groupValue: widget._newType.value,
            onChanged: (val){
              setState(() {
                widget._newType.value = val;
              });
            },
          ),
        ),
        ListTile(
          title: const Text("MP3 192k"),
          leading: Radio(
            value: STREAM_TYPE.MP3192,
            groupValue: widget._newType.value,
            onChanged: (val){
              setState(() {
                widget._newType.value = val;
              });
            },
          ),
        ),
        ListTile(
          title: const Text("MP3 320k"),
          leading: Radio(
            value: STREAM_TYPE.MP3320,
            groupValue: widget._newType.value,
            onChanged: (val){
              setState(() {
                widget._newType.value = val;
              });
            },
          ),
        ),
        SimpleDialogOption(
          child: const Text("OK"),
          onPressed: (){
            Navigator.pop(context, widget._newType.value);
          },
        )
      ],
    );
  }
}