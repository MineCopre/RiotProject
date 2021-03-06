import 'package:charts_flutter/flutter.dart' as charts;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GraphsHum extends StatefulWidget {
  final dynamic dbKey;
  GraphsHum(this.dbKey);

  @override
  State<StatefulWidget> createState() => _BuilderTemp(dbKey);
}

class _BuilderTemp extends State<GraphsHum> {
  List<String> data;
  List<String> dataCut;
  List<charts.Series<dynamic, DateTime>> sortedData;
  List<String> splitString;
  List<HumidityValues> fData;
  List<String> newList;
  var _ref;
  final dynamic dbKey;

  _BuilderTemp(this.dbKey);

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
        .child(dbKey)
        .child('balloons/')
        .child('ttgo/')
        .child('humidity/')
        .once();

    data = [];
    dataCut = [];
    splitString = [];
    fData = [];
    newList = [];
    sortedData = [];

    getAllHums();
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
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width * 0.07),
                ))),
        body: new Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
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

  List<charts.Series<HumidityValues, DateTime>> setChartList(
      List<String> data) {
    for (int i = 0; i < data.length - 1; i += 2) {
      fData.add(new HumidityValues(
          new DateTime.fromMillisecondsSinceEpoch(
              double.parse(data[i + 1]).round() * 1000),
          double.parse(data[i]).round()));
    }

    return [
      new charts.Series<HumidityValues, DateTime>(
        id: 'Humidity',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (HumidityValues hum, _) => hum.time,
        measureFn: (HumidityValues hum, _) => hum.hum,
        data: fData,
      )
    ];
  }

  void getAllHums() {
    getHumsDb().then((strings) => {
          this.setState(() {
            this.data = strings;
            print(data);

            dataCut = getData(data);

            sortedData = setChartList(dataCut);
          })
        });

    //print(data);
  }

  Future<List<String>> getHumsDb() async {
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

class HumidityValues {
  final DateTime time;
  final int hum;

  HumidityValues(this.time, this.hum);

  @override
  String toString() {
    return time.toString() + " / " + hum.toString();
  }
}
