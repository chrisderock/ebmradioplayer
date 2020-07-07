import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EbmSocial extends StatefulWidget{
  _EbmSocial createState() => _EbmSocial();
}

class _EbmSocial extends State<EbmSocial>{
  _visitWeb(String url) async {
    if(await canLaunch(url)){
      await launch(url);
    }
  }
  Widget build(BuildContext context){
    return Container(
      height: 300,
      child: ListView(
        children: [
          ListTile(
            leading: Image(image: AssetImage('assets/facebook.png')),
            title: Text("Facebook"),
            onTap: (){
              _visitWeb('https://facebook.com/groups/ebm.radio/');
            },
          ),
          ListTile(
            leading: Image(image: AssetImage('assets/flickr.png')),
            title: Text("Flickr"),
            onTap: (){
              _visitWeb('https://flickr.com/photos/154224693@N07');
            },
          ),
          ListTile(
            leading: Image(image: AssetImage('assets/instagram.png')),
            title: Text("Instagram"),
            onTap: (){
              _visitWeb('https://www.instagram.com/ebm_radio/');
            },
          ),
          ListTile(
            leading: Image(image: AssetImage('assets/telegram.png')),
            title: Text("Telegram"),
            onTap: (){
              _visitWeb('https://t.me/ebm_radio');
            },
          ),
          ListTile(
            leading: Image(image: AssetImage('assets/twitter.png')),
            title: Text("Twitter"),
            onTap: (){
              _visitWeb('https://twitter.com/ebm_radio');
            },
          )
        ],
      ),
    );
  }
}