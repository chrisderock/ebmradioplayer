import 'package:flutter/material.dart';

ThemeData getEbmTheme() {
  return ThemeData(
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
  );
}