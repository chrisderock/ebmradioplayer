import 'package:flutter/material.dart';
import 'package:ebmradioplayer/generated/l10n.dart';

class EbmWishform extends StatefulWidget {
  EbmWishform({
    this.sendUrl
  });
  final String sendUrl;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _songController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _greetingsController = TextEditingController();
  _EbmWishform createState() => _EbmWishform();
}

class _EbmWishform extends State<EbmWishform>{
  _sendWish(BuildContext ctx) async {
    String qry = Uri.encodeFull(
      widget.sendUrl +
        '?name=' + widget._nameController.text +
        '&song=' + widget._songController.text +
        '&interpret=' + widget._artistController.text +
        '&gruesse=' + widget._greetingsController.text
    );
    print(qry);
    String resp = "";// await HttpUtils.getForString(qry);
    Scaffold.of(ctx).showSnackBar(SnackBar(
      content: Text(
        resp == "1" ? S.current.wishSent : S.current.wishError
      ),
    ));
  }
  Widget build(BuildContext context){
    return Container(
      height: 300,
      child: Column(
        children: [
          Text(S.current.makeAWish),
          TextField(
            controller: widget._nameController,
            decoration: InputDecoration(
              hintText: S.current.enterYourName
            ),
            scrollPadding: EdgeInsets.all(80.0),
          ),
          TextField(
            controller: widget._songController,
            decoration: InputDecoration(
              hintText: S.current.enterASong
            ),
            scrollPadding: EdgeInsets.all(80.0),
          ),
          TextField(
            controller: widget._artistController,
            decoration: InputDecoration(
              hintText: S.current.enterArtist
            ),
            scrollPadding: EdgeInsets.all(80.0),
          ),
          TextField(
            controller: widget._greetingsController,
            decoration: InputDecoration(
              hintText: S.current.greetings
            ),
            scrollPadding: EdgeInsets.all(80.0),
            textInputAction: TextInputAction.send,
            onEditingComplete: (){
              _sendWish(context);
            },
          ),
          RaisedButton(
            child: Text(S.current.send),
            onPressed: (){
              _sendWish(context);
            },
          )
        ],
      ),
    );
  }
}