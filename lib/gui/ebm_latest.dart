import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

class EbmLatest extends StatefulWidget{
  EbmLatest({this.latest, this.lastChanged});
  final List<String> latest;
  final ValueNotifier lastChanged;
  _EbmLatest createState() => _EbmLatest();
}

class _EbmLatest extends State<EbmLatest> with WidgetsBindingObserver{
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.lastChanged.addListener(() {
      setState(() {
        print("tach");
      });
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
        // widget.lastChanged.notifyListeners();
      });
    }
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("didChangeAppLifecycleState");
    if(state == AppLifecycleState.resumed){
      _loadLatestFromBackground();
    }  }
  Widget build(BuildContext context){
    return AudioServiceWidget(
      child: Container(
          height: 280,
          child: Column(
              children: [
                Text("Latest Tracks"),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.latest.length,
                    itemBuilder: (BuildContext ctxt, int index){
                      return new Text(
                        widget.latest[index],
                        textAlign: TextAlign.center,
                      );
                    }
                ),
              ]
          )
      ),
    );
  }
}