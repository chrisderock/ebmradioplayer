import 'package:ebmradioplayer/gui/ebm_latest.dart';
import 'package:ebmradioplayer/gui/ebm_news.dart';
import 'package:ebmradioplayer/gui/ebm_player.dart';
import 'package:ebmradioplayer/gui/ebm_social.dart';
import 'package:ebmradioplayer/gui/ebm_wishform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';
//import 'package:localstorage/localstorage.dart';

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
        accentColor: Colors.green,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          color: Colors.black,
          textTheme: TextTheme(
              bodyText1: TextStyle(color: Colors.green),
              bodyText2: TextStyle(color: Colors.green),
              button: TextStyle(color: Colors.green),
              subtitle1: TextStyle(color: Colors.green),
              subtitle2: TextStyle(color: Colors.green),
            headline1: TextStyle(color: Colors.green),
            headline2: TextStyle(color: Colors.green),
            headline3: TextStyle(color: Colors.green),
            headline4: TextStyle(color: Colors.green),
            headline5: TextStyle(color: Colors.green),
            headline6: TextStyle(color: Colors.green, fontSize: 20.0),
            caption: TextStyle(color: Colors.green),
          ),
          actionsIconTheme: IconThemeData(
            color: Colors.green
          )
        ),
        primaryTextTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.green),
          bodyText2: TextStyle(color: Colors.green),
          button: TextStyle(color: Colors.green),
          subtitle1: TextStyle(color: Colors.green),
          subtitle2: TextStyle(color: Colors.green)
        ),
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.green),
          bodyText2: TextStyle(color: Colors.green),
          button: TextStyle(color: Colors.green),
            subtitle1: TextStyle(color: Colors.green),
            subtitle2: TextStyle(color: Colors.green)
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.green),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.black,
          textTheme: ButtonTextTheme.accent,
          shape: Border.all(
            width: 2.0,
            color: Colors.green
          )
        )
      ),
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
  /// the configuration for the stream url
  // final ValueNotifier<STREAM_TYPE> _type = ValueNotifier(STREAM_TYPE.UNKNOWN);
  /// for storing the stream type
  // final LocalStorage _localStorage = LocalStorage("ebmradioplayer");
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
  /// init the player page
  void initState() {
    super.initState();
    _widgets = <Widget>[
      EbmNews(
        newsFeed: widget._feedUrl,
        webUrl: widget._homeUrl,
      ),
      EbmWishform(
        sendUrl: widget._wishSendUrl,
      ),
      EbmSocial(

      ),
      EbmLatest(
        latest: widget._latest,
      )
    ];
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
          /*actions: [ /// the configuration menu
            PopupMenuButton(
              onSelected: (res){
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
          ],*/
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                EbmPlayer(
                  latest: widget._latest,
                  //streamType: widget._type,
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