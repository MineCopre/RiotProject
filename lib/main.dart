import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:riot_projekt/graphs.dart';
import 'package:riot_projekt/graphsNew.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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

  // This class is the configuration for the state. It holds the v  alues (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final fb = FirebaseDatabase.instance;
  Map<MarkerId, Marker> _clustersMarkers = <MarkerId, Marker>{};
  Map<CircleId, Circle> _clustersCircles = <CircleId, Circle>{};
  MarkerId _activeMarker;
  CircleId _activeCircle;
  LatLng _initialLatLng;

  var retrievedName;
  var temperature;
  dynamic humidity;
  var indexTemp;

  @override
  Widget build(BuildContext context) {
    final ref = fb.reference();

    ref.child("humidity").once().then((DataSnapshot data) {
      //print(data.value);
      //print(data.key);

      setState(() {
        humidity = data.value;
      });
    });

    ref.child("mapY").once().then((DataSnapshot data) {
      setState(() {
        double lng = data.value;
        ref.child("mapX").once().then((DataSnapshot data) {
          setState(() {
            _initialLatLng = LatLng(data.value, lng);
          });
        });
      });
    });

    //Map functions

    Completer<GoogleMapController> _controller = Completer();

    _changeMarkerAndCircleType(
        LatLng center, CircleId circleId, CircleId activeCircleId) {
      setState(() {
        MarkerId markerId = MarkerId(circleId.value.toString());
        MarkerId activeMarkerId = MarkerId(activeCircleId.value.toString());

        //Create markers
        Marker activeMarker = Marker(
          markerId: markerId,
          position: center,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          consumeTapEvents: false,
        );

        Marker marker = Marker(
            markerId: _activeMarker,
            position: _clustersMarkers[_activeMarker].position,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
            consumeTapEvents: true,
            onTap: () {
              _changeMarkerAndCircleType(
                  _clustersMarkers[activeMarkerId].position,
                  activeCircleId,
                  _activeCircle);
            });

        //Create circles
        Circle activeCircle = Circle(
            circleId: circleId,
            center: center,
            radius: 800,
            fillColor: Colors.red.withOpacity(0.3),
            strokeWidth: 3);

        Circle circle = Circle(
            circleId: _activeCircle,
            center: _clustersCircles[_activeCircle].center,
            radius: 800,
            fillColor: Colors.cyan.withOpacity(0.3),
            strokeWidth: 3,
            consumeTapEvents: true,
            onTap: () {
              _changeMarkerAndCircleType(
                  _clustersCircles[activeCircleId].center,
                  activeCircleId,
                  _activeCircle);
            });

        _clustersCircles.remove(circleId);
        _clustersCircles[circleId] = activeCircle;

        _clustersMarkers.remove(markerId);
        _clustersMarkers[markerId] = activeMarker;

        _clustersCircles.remove(_activeCircle);
        _clustersCircles[_activeCircle] = circle;

        _clustersMarkers.remove(_activeMarker);
        _clustersMarkers[_activeMarker] = marker;

        _activeCircle = activeCircle.circleId;
        _activeMarker = activeMarker.markerId;
      });
    }

    Future _addClusterMarker(LatLng center) async {
      setState(() {
        MarkerId markerId = MarkerId(_clustersMarkers.length.toString());
        if (_activeMarker != null) {
          Marker marker = Marker(
              markerId: markerId,
              position: center,
              draggable: true,
              consumeTapEvents: true,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueCyan),
              onTap: () {
                _changeMarkerAndCircleType(
                    center, CircleId(markerId.value.toString()), _activeCircle);
              });
          _clustersMarkers[markerId] = marker;
        } else {
          Marker marker = Marker(
            markerId: markerId,
            position: center,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            consumeTapEvents: false,
          );
          _clustersMarkers[markerId] = marker;
          _activeMarker = markerId;
        }
      });
    }

    Future _addClusterCircle(LatLng center) async {
      setState(() {
        _addClusterMarker(center);
        CircleId circleId = CircleId(_clustersCircles.length.toString());
        if (_activeCircle != null) {
          Circle circle = Circle(
              circleId: circleId,
              center: center,
              radius: 800,
              fillColor: Colors.cyan.withOpacity(0.3),
              strokeWidth: 3,
              consumeTapEvents: true,
              onTap: () {
                _changeMarkerAndCircleType(center, circleId, _activeCircle);
              });
          _clustersCircles[circleId] = circle;
        } else {
          Circle circle = Circle(
              circleId: circleId,
              center: center,
              radius: 800,
              fillColor: Colors.red.withOpacity(0.3),
              strokeWidth: 3);
          _clustersCircles[circleId] = circle;
          _activeCircle = circleId;
        }
      });
    }

    return MaterialApp(
        title: 'Balloon Control',
        home: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(
                    MediaQuery.of(context).size.height *
                        0.15), //Adaptive height
                child: AppBar(
                    backgroundColor: Color(0xFF2E8BC0),
                    //backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    flexibleSpace: Container(
                      child: Image.asset(
                        'assets/images/miniloon.png',
                      ),
                      //padding: const EdgeInsets.all(30),
                      padding: const EdgeInsets.only(
                          bottom: 20, top: 30, left: 30, right: 30),
                    ))),
            //Full background for balloon image
            body: Container(
                //height: MediaQuery.of(context).size.height * 0.65,
                color: Colors.white,
                //Column where the text and cards will stay
                child: Column(children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(15),
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
                      //Each "card" is wrapped by each container
                      child: GridView.count(
                    scrollDirection: Axis.horizontal,
                    primary: false,
                    //padding: const EdgeInsets.all(30),
                    padding: const EdgeInsets.only(
                        bottom: 30,
                        top: 15,
                        left: 15,
                        right:
                            30), //Left must be equal to padding in container above to line up with the text
                    mainAxisSpacing: MediaQuery.of(context).size.width * 0.15,
                    crossAxisCount: 1,
                    children: <Widget>[
                      FutureBuilder(
                          future: ref
                              .child("hamburg_stadtpark")
                              .child("avg_temp")
                              .once(),
                          builder:
                              (context, AsyncSnapshot<DataSnapshot> snapshot) {
                            if (snapshot.hasData) {
                              /*
                              Map<dynamic, dynamic> values =
                                  snapshot.data.value;

                              if (values == null) {
                                temperature = "No Data";
                              } else {
                                values.forEach((key, value) {
                                  //print(readTimeStamp(value["time"]));
                                  temperature = value["value"];
                                });
                         }
                              */
                              temperature = snapshot.data.value;
                              return new GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              //Graph.withSampleData()));
                                              GraphsTemp()));
                                },
                                child: Container(
                                  decoration: new BoxDecoration(
                                      color: Color(0xFFB1D4E0),
                                      //color: Colors.red,
                                      borderRadius:
                                          new BorderRadius.circular(15)),
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
                                                fontSize: 25,
                                                color: Color(0xFF0C2D48)),
                                          )
                                        ])),
                                  ),
                                ),
                              );
                            }
                            return CircularProgressIndicator();
                          }),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Graph.withSampleHumidity()));
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
                                        fontSize: 25,
                                        color: Color(0xFF0C2D48)),
                                  )
                                ])),
                          ),
                        ),
                      )
                    ],
                  )),
                  Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Color(0xFFB1D4E0),
                          borderRadius: BorderRadius.circular(15)),
                      child: _initialLatLng == null
                          ? Container(
                              alignment: Alignment.bottomCenter,
                              child: Center(
                                child: Text(
                                  'LOADING MAP...',
                                  style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0C2D48),
                                      fontSize: 25),
                                ),
                              ),
                            )
                          : Center(
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Align(
                                      //heightFactor: 0.3,
                                      //widthFactor: 2.5,
                                      child: GoogleMap(
                                    mapType: MapType.terrain,
                                    initialCameraPosition: CameraPosition(
                                      target: _initialLatLng,
                                      zoom: 14.4746,
                                    ),
                                    onMapCreated:
                                        (GoogleMapController controller) {
                                      _controller.complete(controller);
                                      //_getAllClusters();
                                    },
                                    compassEnabled: true,
                                    tiltGesturesEnabled: false,
                                    onTap: (latLng) {},
                                    onLongPress: (latLng) {
                                      _addClusterCircle(latLng);
                                    },
                                    markers:
                                        Set<Marker>.of(_clustersMarkers.values),
                                    circles:
                                        Set<Circle>.of(_clustersCircles.values),
                                  ))),
                            )),
                ]))));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    super.dispose();
  }
}
