import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:riot_projekt/graphs.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HAW 20/21 RIOT OS Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Balloon Control Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final fb = FirebaseDatabase.instance;
  final myController = TextEditingController();
  final name = 'Name';
  var retrievedName;
  var temperature;
  var humidity;
  var indexTemp;

  List<String> listTemp = new List();

  @override
  Widget build(BuildContext context) {
    final ref = fb.reference();
    listTemp.add("Helloooo");
    ref
        .child("test")
        .child("balloons")
        .child("balloon0")
        .child("temperature")
        .limitToLast(1)
        .once()
        .then((DataSnapshot data) {});

    print(listTemp.first + " + " + listTemp.length.toString());
    ref
        .child("test")
        .child("balloons")
        .child("balloon0")
        .child("temperature")
        .limitToLast(1)
        .once()
        .then((DataSnapshot data) {
      setState(() {
        temperature = data.value["value"];
      });
    });

    ref.child("humidity").once().then((DataSnapshot data) {
      //print(data.value);
      //print(data.key);
      setState(() {
        humidity = data.value;
      });
    });

    return MaterialApp(
        title: 'Balloon Control',
        home: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(
                    MediaQuery.of(context).size.height *
                        0.25), //Adaptive height
                child: AppBar(
                    backgroundColor: Color(0xFF2E8BC0),
                    //backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    flexibleSpace: Container(
                      child: Image.asset(
                        'assets/images/balloon.png',
                      ),
                      padding: const EdgeInsets.all(30),
                    ))),
            //Full background for balloon image
            body: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                color: Colors.white,
                //Column where the text and cards will stay
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(
                          top: 20, bottom: 0, left: 20, right: 10),
                      child: AutoSizeText(
                        'Real-Time Data: ',
                        style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 25),
                        minFontSize: 20,
                        maxLines: 1,
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    new Expanded(
                        //Each "card" is wrapped by a container
                        child: GridView.count(
                      scrollDirection: Axis.horizontal,
                      primary: false,
                      padding: const EdgeInsets.all(10),
                      mainAxisSpacing: MediaQuery.of(context).size.width * 0.15,
                      crossAxisCount: 1,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Graphs.withSampleTemperature()));
                            print("Temperature\n");
                            var dateTime = new DateTime.now();
                            print(dateTime);
                          },
                          child: Container(
                            decoration: new BoxDecoration(
                                color: Color(0xFFB1D4E0),
                                //color: Colors.red,
                                borderRadius: new BorderRadius.circular(15)),
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(children: <TextSpan>[
                                    TextSpan(
                                        text: "Temperature\n\n",
                                        style: TextStyle(
                                            fontFamily: "Roboto",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Color(0xFF0C2D48))),
                                    TextSpan(
                                      text: "$temperatureº",
                                      style: TextStyle(
                                          fontFamily: "Roboto",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                          color: Color(0xFF0C2D48)),
                                    )
                                  ])),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Graphs.withSampleHumidity()));
                            print("Humidity");
                          },
                          child: Container(
                            decoration: new BoxDecoration(
                                color: Color(0xFFB1D4E0),
                                //color: Colors.red,
                                borderRadius: new BorderRadius.circular(15)),
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(children: <TextSpan>[
                                    TextSpan(
                                        text: "Humidity\n\n",
                                        style: TextStyle(
                                            fontFamily: "Roboto",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Color(0xFF0C2D48))),
                                    TextSpan(
                                      text: "$humidity%",
                                      style: TextStyle(
                                          fontFamily: "Roboto",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                          color: Color(0xFF0C2D48)),
                                    )
                                  ])),
                            ),
                          ),
                        )
                      ],
                    ))
                  ],
                ))));
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }
}

String readTimeStamp(int timestamp) {
  var now = DateTime.now();
  var format = DateFormat('HH:mm a');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  var diff = now.difference(date);
}
