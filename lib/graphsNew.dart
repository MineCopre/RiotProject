import 'dart:convert';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GraphsTemp extends StatefulWidget {
  List<charts.Series> seriesList;
  final bool animate;

  GraphsTemp({this.seriesList, this.animate});

  @override
  State<StatefulWidget> createState() => _BuilderTemp(seriesList, animate);
}

class _BuilderTemp extends State<GraphsTemp> {
  List<charts.Series> seriesList;
  final bool animate;
  Query _ref;

  _BuilderTemp(this.seriesList, this.animate);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);

    _ref = FirebaseDatabase.instance
        .reference()
        .child('clusters')
        .child('hamburg_stadtpark')
        .child('balloons')
        .child('ttgo')
        .orderByChild('temperature');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(
                MediaQuery.of(context).size.height * 0.25), //Adaptive height
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
        body: new Container(
            padding: EdgeInsets.all(20),
            child: FirebaseAnimatedList(
              query: _ref,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                print(snapshot.value);

                List<String> data = getData(snapshot.value);
                int i = 0;
                data.forEach((element) {
                  print(i.toString() + ": " + element);
                  i++;
                });

                return null;
              },
            )));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  List<charts.Series<TemperatureValues, DateTime>> func() {
    final data = [
      new TemperatureValues(new DateTime(2020, 11, 23, 0, 0), 5),
      new TemperatureValues(new DateTime(2020, 11, 23, 5, 0), 7),
    ];

    return [
      new charts.Series<TemperatureValues, DateTime>(
          id: 'Temperature',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (TemperatureValues temp, _) => temp.time,
          measureFn: (TemperatureValues temp, _) => temp.temp,
          data: data //data,
          )
    ];
  }

  List<String> getData(dynamic data) {
    List<String> splitString = data.toString().split(" ");

    splitString.removeWhere((element) =>
        element.contains("value") || element.contains("timestamp"));

    final exp = RegExp(r'[-+]?\d*\.\d+|\d+');
    List<String> newList = [];

    splitString.forEach((element) {
      //newList.add(element.replaceAll(new RegExp(r'[^0-9][^\d.]'), ''));
      newList.add(exp.firstMatch(element).group(0));
    });

    return newList;
  }
}

class TemperatureValues {
  final DateTime time;
  final int temp;

  TemperatureValues(this.time, this.temp);
}

class DatabaseService {
  static Future<List<charts.Series>> getTemps() async {
    Query needsSnapshot = await FirebaseDatabase.instance
        .reference()
        .child('hamburg_stadtpark')
        .child('balloons')
        .child('ttgo')
        .orderByChild('temperature');

    return null;
  }
}

class GraphsNew extends StatefulWidget {
  List<charts.Series> seriesList;
  final bool animate;

  GraphsNew(this.seriesList, {this.animate});

  @override
  State<StatefulWidget> createState() => _Builder(seriesList, animate);
}

class _Builder extends State<GraphsNew> {
  final List<charts.Series> seriesList;
  final bool animate;

  _Builder(this.seriesList, this.animate);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(
                MediaQuery.of(context).size.height * 0.25), //Adaptive height
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
        body: new Container(
            padding: EdgeInsets.all(20),
            child: new charts.TimeSeriesChart(
              seriesList,
              animate: animate,
              behaviors: [
                new charts.PanAndZoomBehavior(),
                new charts.SeriesLegend()
              ],
              // Optionally pass in a [DateTimeFactory] used by the chart. The factory
              // should create the same type of [DateTime] as the data provided. If none
              // specified, the default creates local date time.
              dateTimeFactory: const charts.LocalDateTimeFactory(),
            )));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }
}
