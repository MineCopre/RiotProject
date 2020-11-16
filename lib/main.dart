import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

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
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(53.556342, 10.021588),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

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
                color: Colors.white,
                //Column where the text and cards will stay
                child: Column(
                  children: <Widget>[
                    Container(
                      padding:
                          const EdgeInsets.only(top: 50, bottom: 50, left: 20),
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
                        padding: const EdgeInsets.all(20),
                        mainAxisSpacing: MediaQuery.of(context).size.width * 0.2,
                        crossAxisCount: 1,
                        children: <Widget>[
                        Container(
                          decoration: new BoxDecoration(
                              color: Color(0xFF2E8BC0),
                              borderRadius: new BorderRadius.circular(15)),
                          padding: const EdgeInsets.all(8),
                          child: new Center(child: new Text("Temperature")),
                        ),
                        Container(
                          decoration: new BoxDecoration(
                              color: Color(0xFF2E8BC0),
                              borderRadius: new BorderRadius.circular(15)),
                          padding: const EdgeInsets.all(8),
                          child: new Center(child: new Text("Humidity")),
                        ),
                        Container(
                            decoration: new BoxDecoration(
                                color: Color(0xFF2E8BC0),
                                borderRadius: new BorderRadius.circular(15)),
                            padding: const EdgeInsets.all(8),
                            child: GoogleMap(
                              mapType: MapType.terrain,
                              compassEnabled: true,
                              myLocationButtonEnabled: true,
                              myLocationEnabled: true,
                              initialCameraPosition: _kGooglePlex,
                              onMapCreated: (GoogleMapController controller) {
                                _controller.complete(controller);
                              },
                            ))
                      ],
                    ))
                  ],
                ))));
  }
}
