import 'package:flutter/material.dart';

class EbmLatest extends StatefulWidget{
  EbmLatest({this.latest});
  final List<String> latest;
  _EbmLatest createState() => _EbmLatest();
}

class _EbmLatest extends State<EbmLatest>{
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