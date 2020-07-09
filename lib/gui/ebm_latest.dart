import 'package:flutter/material.dart';

class EbmLatest extends StatefulWidget{
  EbmLatest({this.latest, this.lastChanged});
  final List<String> latest;
  final ValueNotifier lastChanged;
  _EbmLatest createState() => _EbmLatest();
}

class _EbmLatest extends State<EbmLatest>{
  void initState(){
    super.initState();
    widget.lastChanged.addListener(() {
      setState(() {
        print("tach");
      });
    });
  }
  Widget build(BuildContext context){
    return Container(
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
    );
  }
}