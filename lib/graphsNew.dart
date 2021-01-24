import 'dart:collection';
import 'dart:convert';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class GraphsTemp extends StatefulWidget {
  final bool animate;
  GraphsTemp({this.animate});

  @override
  State<StatefulWidget> createState() => _BuilderTemp(animate);
}

class _BuilderTemp extends State<GraphsTemp> {
  List<String> data;
  List<String> dataCut;
  List<charts.Series<dynamic, DateTime>> sortedData;
  List<String> splitString;
  List<TemperatureValues> fData;
  List<String> newList;
  final bool animate;
  var _ref;

  _BuilderTemp(this.animate);

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
        .child('clusters/')
        .child('hamburg_stadtpark/')
        .child('balloons/')
        .child('ttgo/')
        .child('temperature/')
        .once();

    data = [];
    dataCut = [];
    splitString = [];
    fData = [];
    newList = [];
    sortedData = [];

    getAllTemps();
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
              sortedData,
              animate: false,
              behaviors: [
                new charts.PanAndZoomBehavior(),
                new charts.SeriesLegend()
              ],
              // Optionally pass in a [DateTimeFactory] used by the chart. The factory
              // should create the same type of [DateTime] as the data provided. If none
              // specified, the default creates local date time.
              dateTimeFactory: const charts.LocalDateTimeFactory(),
              /*FirebaseAnimatedList(
                          query: _ref,
                          itemBuilder: (BuildContext context, DataSnapshot snapshot,
                              Animation<double> animation, int index) {
                            print(snapshot.value);
                            data = getData(snapshot.value);
              
                            sortedData = setChartList(data, animate);
              
                            return new Container(
                              height: 200,
                              width: 200,
                              child: new charts.TimeSeriesChart(
                                setChartList(data, animate),
                                animate: animate,
                                behaviors: [
                                  new charts.PanAndZoomBehavior(),
                                  new charts.SeriesLegend()
                                ],
                                // Optionally pass in a [DateTimeFactory] used by the chart. The factory
                                // should create the same type of [DateTime] as the data provided. If none
                                // specified, the default creates local date time.
                                dateTimeFactory: const charts.LocalDateTimeFactory(),
                              ),
                            );
                          },
                        ),*/
            )));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  List<String> getData(List<String> localData) {
    splitString = localData.toString().split(" ");

    splitString.removeWhere((element) =>
        element.contains("value") || element.contains("timestamp"));

    final exp = RegExp(r'[-+]?\d*\.\d+|\d+');

    if (splitString != null) {
      splitString.forEach((element) {
        try {
          if (newList != null) {
            newList.add(exp.firstMatch(element).group(0));
          }
        } catch (Exception) {
          print("Ex. caught");
        }
      });
    }

    return newList;
  }

  List<charts.Series<TemperatureValues, DateTime>> setChartList(
      List<String> data) {
    for (int i = 0; i < data.length - 1; i += 2) {
      fData.add(new TemperatureValues(
          new DateTime.fromMillisecondsSinceEpoch(
              double.parse(data[i + 1]).round() * 1000),
          double.parse(data[i]).round()));
    }

    return [
      new charts.Series<TemperatureValues, DateTime>(
        id: 'Temperature',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TemperatureValues temp, _) => temp.time,
        measureFn: (TemperatureValues temp, _) => temp.temp,
        data: fData,
      )
    ];
  }

  void getAllTemps() {
    getTempsDb().then((strings) => {
          this.setState(() {
            this.data = strings;
            print(data);

            dataCut = getData(data);

            sortedData = setChartList(dataCut);
          })
        });

    print(data);

    //dataCut = getData(data);

    //sortedData = setChartList(dataCut);

/*
    final dataTV = [
      new TemperatureValues(new DateTime(2020, 11, 23, 0, 0), 5),
      new TemperatureValues(new DateTime(2020, 11, 23, 5, 0), 7),
      new TemperatureValues(new DateTime(2020, 11, 23, 8, 30), 10),
      new TemperatureValues(new DateTime(2020, 11, 23, 16, 0), 7),
      new TemperatureValues(new DateTime(2020, 11, 23, 20, 0), -2),
      new TemperatureValues(new DateTime(2020, 11, 23, 23, 0), 7),
      new TemperatureValues(new DateTime(2020, 11, 24, 8, 0), 7),
      new TemperatureValues(new DateTime(2020, 11, 24, 14, 0), 8),
      new TemperatureValues(new DateTime(2020, 11, 24, 18, 0), 15),
    ];

    sortedData = [
      new charts.Series<TemperatureValues, DateTime>(
        id: 'Temperature',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TemperatureValues temp, _) => temp.time,
        measureFn: (TemperatureValues temp, _) => temp.temp,
        data: dataTV,
      )
    ];
    */
  }

  Future<List<String>> getTempsDb() async {
    DataSnapshot dataSnapshot = await _ref;
    List<String> strList = [];
    if (dataSnapshot.value != null) {
      List<dynamic> val = dataSnapshot.value;
      //print(dataSnapshot.value);
      val.forEach((element) {
        strList.add(element.toString());
      });
    }

    return strList;
  }
}

class TemperatureValues {
  final DateTime time;
  final int temp;

  TemperatureValues(this.time, this.temp);

  @override
  String toString() {
    return time.toString() + " / " + temp.toString();
  }
}

String readTimeStamp(int timestamp) {
  return DateFormat('d m y HH m') //01-01-2001-01-01
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000));
}

/*
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
*/
