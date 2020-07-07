import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:ebmradioplayer/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import 'package:webfeed/webfeed.dart';

class EbmNews extends StatefulWidget {
  EbmNews({
    this.webUrl,
    this.newsFeed
  });
  _EbmNews createState() => _EbmNews();
  final List<String> _newsItems = List<String>();
  final String webUrl;
  final String newsFeed;
}

class _EbmNews extends State<EbmNews>{
  void initState(){
    super.initState();
    _feed();
    Timer.periodic(Duration(hours: 1),(timer){
      _feed();
    });
  }
  _feed() async {
    var feed = await HttpUtils.getForString(widget.newsFeed);
    var rss = RssFeed.parse(feed);
    setState(() {
      int i = 0;
      widget._newsItems.clear();
      rss.items.forEach((element) {
        if(i++ < 11) {
          print(element.title);
          widget._newsItems.add(element.title);
        }
      });
    });
  }
  _visitWeb(String url) async {
    if(await canLaunch(url)){
      await launch(url);
    }
  }
  Widget build(BuildContext context){
    return Container(
        height: 280,
      child: Column(
      children: [
        Text("News"),
        ListView.builder(
          shrinkWrap: true,
            itemCount: widget._newsItems.length,
            itemBuilder: (BuildContext ctxt, int index){
              return new Text(
                widget._newsItems[index],
                textAlign: TextAlign.center,
              );
            }
        ),
        RaisedButton(
          child: Text(S.current.ourWebsite),
          onPressed: (){
            _visitWeb(widget.webUrl);
          },
        )
      ]
      )
    );
  }
}