import 'package:charts_flutter/flutter.dart' as charts;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GraphsPres extends StatefulWidget {
  GraphsPres();

  @override
  State<StatefulWidget> createState() => _BuilderTemp();
}

class _BuilderTemp extends State<GraphsPres> {
  List<String> data;
  List<String> dataCut;
  List<charts.Series<dynamic, DateTime>> sortedData;
  List<String> splitString;
  List<PressureValues> fData;
  List<String> newList;
  var _ref;

  _BuilderTemp();

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
        .child('pressure/')
        .once();

    data = [];
    dataCut = [];
    splitString = [];
    fData = [];
    newList = [];
    sortedData = [];

    getAllPres();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(
                MediaQuery.of(context).size.height * 0.15), //Adaptive height
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

  List<charts.Series<PressureValues, DateTime>> setChartList(
      List<String> data) {
    for (int i = 0; i < data.length - 1; i += 2) {
      fData.add(new PressureValues(
          new DateTime.fromMillisecondsSinceEpoch(
              double.parse(data[i + 1]).round() * 1000),
          double.parse(data[i]).round()));
    }

    return [
      new charts.Series<PressureValues, DateTime>(
        id: 'Pressure',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (PressureValues temp, _) => temp.time,
        measureFn: (PressureValues temp, _) => temp.pres,
        data: fData,
      )
    ];
  }

  void getAllPres() {
    getPresDb().then((strings) => {
          this.setState(() {
            this.data = strings;
            print(data);

            dataCut = getData(data);

            sortedData = setChartList(dataCut);
          })
        });

    //print(data);
  }

  Future<List<String>> getPresDb() async {
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

class PressureValues {
  final DateTime time;
  final int pres;

  PressureValues(this.time, this.pres);

  @override
  String toString() {
    return time.toString() + " / " + pres.toString();
  }
}
