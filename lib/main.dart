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

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  int markerCount = 1;
  static LatLng _latLng;
  BitmapDescriptor redMarker;

  var retrievedName;
  var _temperature;
  var _humidity;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ref = fb.reference();
    ref.child("Temperature").once().then((DataSnapshot data) {
      setState(() {
        _temperature = data.value;
      });
    });
    ref.child("Humidity").once().then((DataSnapshot data) {
      setState(() {
        _humidity = data.value;
      });
    });
    ref.child("mapY").once().then((DataSnapshot data) {
      setState(() {
        double lng = data.value;
        ref.child("mapX").once().then((DataSnapshot data) {
          setState(() {
            _latLng = LatLng(data.value, lng);
          });
        });
      });
    });

    //Map functions

    Completer<GoogleMapController> _controller = Completer();

    Future _changeDefaultMarker(LatLng latlng) async {
      setState(() {
        final MarkerId markerId = MarkerId("DefaultMarker");
        print(markers.length.toString());
        Marker marker = Marker(
          markerId: markerId,
          position: latlng,
          draggable: true,
          icon: BitmapDescriptor.defaultMarker,
        );
        markers[markerId] = marker;
      });
    }

    Future _secondTypeMarker(LatLng latlng) async{
      setState(() {
        final MarkerId markerId = MarkerId(markers.length.toString());
        print(markers.length.toString());
        Marker marker = Marker(
          markerId: markerId,
          position: latlng,
          draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(250),
        );
        markers[markerId] = marker;
      });
    }

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
                height: MediaQuery.of(context).size.height * 0.8,
                color: Colors.white,
                //Column where the text and cards will stay
                child: Column(
                  children: <Widget>[
                    new Container(
                      padding: const EdgeInsets.only(
                          top: 20, bottom: 0, left: 20, right: 10),
                      child: AutoSizeText(
                        'MAP: ',
                        style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 25),
                        minFontSize: 20,
                        maxLines: 1,
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    new Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Color(0xFF2E8BC0),
                            borderRadius: BorderRadius.circular(15)),
                        child: _latLng == null
                            ? Container(
                                child: Center(
                                  child: Text(
                                    'LOADING MAP...',
                                    style: TextStyle(fontFamily: 'Roboto', color: Colors.white, fontSize: 25),
                                  ),
                                ),
                              )
                            : GoogleMap(
                                mapType: MapType.terrain,
                                myLocationEnabled: true,
                                myLocationButtonEnabled: true,
                                initialCameraPosition: CameraPosition(
                                  target: _latLng,
                                  zoom: 14.4746,
                                ),
                                onMapCreated: (GoogleMapController controller) {
                                  _controller.complete(controller);
                                  _changeDefaultMarker(_latLng);
                                },
                                compassEnabled: true,
                                tiltGesturesEnabled: false,
                                onTap: (_latLng) {
                                  _changeDefaultMarker(_latLng);
                                },
                                onLongPress: (_latLng){
                                  _secondTypeMarker(_latLng);
                                },
                                markers: Set<Marker>.of(markers.values),
                              )),
                  ],
                ))));
    /*return MaterialApp(
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
                            Container(
                              decoration: new BoxDecoration(
                                  color: Color(0xFF2E8BC0),
                                  //color: Colors.red,
                                  borderRadius: new BorderRadius.circular(15)),
                              padding: const EdgeInsets.all(8),
                              child: new Center(
                                child:
                                new Text('Temperature\n $_temperature ºC'),
                              ),
                            ),
                            Container(
                              decoration: new BoxDecoration(
                                  color: Color(0xFF2E8BC0),
                                  borderRadius: new BorderRadius.circular(15)),
                              padding: const EdgeInsets.all(8),

                              child: new Center(
                                  child: new Text('Humidity\n $_humidity  %')),
                            ),
                          ],
                        )
                    ),
                    Container(
                        decoration: new BoxDecoration(
                            color: Color(0xFF2E8BC0),
                            borderRadius: new BorderRadius.circular(15)),
                        padding: const EdgeInsets.all(0.1),
                        child: GoogleMap(
                          mapType: MapType.terrain,
                          compassEnabled: true,
                          myLocationButtonEnabled: true,
                          myLocationEnabled: true,
                          initialCameraPosition: _kGooglePlex,
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                        )
                    )
                  ],
                )

            )
        )
    );*/
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }
}
