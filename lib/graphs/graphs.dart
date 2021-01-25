import 'package:charts_flutter/flutter.dart' as charts;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Graph extends StatefulWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  Graph(this.seriesList, {this.animate});

  /// Create a [TimesSeriesChart] with sample data (no transitions)
  factory Graph.withSampleData() {
    List<charts.Series<dynamic, dynamic>> name = _createSampleData();

    name.forEach((element) {
      print(element.data);
    });

    return new Graph(
      name,
      //No animations for test
      animate: false,
    );
  }

  factory Graph.getTemperature(DatabaseReference ref) {
    return new Graph(_databaseTemperature(ref), animate: true);
  }

  /// Create a [TimesSeriesChart] with sample temperature data (no transitions)
  factory Graph.withSampleTemperature() {
    return new Graph(
      _temperatureSampleData(),
      //No animations for test
      animate: false,
    );
  }

  /// Create a [TimesSeriesChart] with sample humidity data (no transitions)
  factory Graph.withSampleHumidity() {
    return new Graph(
      _humiditySampleData(),
      //No animations for test
      animate: false,
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesSales, DateTime>> _createSampleData() {
    final data = [
      new TimeSeriesSales(new DateTime(2017, 9, 19), 5),
      new TimeSeriesSales(new DateTime(2017, 9, 26), 25),
      new TimeSeriesSales(new DateTime(2017, 10, 3), 100),
      new TimeSeriesSales(new DateTime(2017, 10, 10), 75),
      new TimeSeriesSales(new DateTime(2017, 10, 10), 75),
    ];

    return [
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }

  static List<charts.Series<TemperatureValues, DateTime>> _databaseTemperature(
      DatabaseReference ref) {
    List<dynamic> temps = new List();
    List<dynamic> times = new List();

    Map<dynamic, dynamic> a;
    getData(ref, a);

    a.length;
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

  /// Hard coded example for temperature
  static List<charts.Series<TemperatureValues, DateTime>>
      _temperatureSampleData() {
    final data = [
      new TemperatureValues(new DateTime(2020, 11, 23, 0, 0), 5),
      new TemperatureValues(new DateTime(2020, 11, 23, 5, 0), 7),
      new TemperatureValues(new DateTime(2020, 11, 23, 8, 30), 10),
      new TemperatureValues(new DateTime(2020, 11, 23, 16, 0), 7),
      new TemperatureValues(new DateTime(2020, 11, 23, 20, 0), -2),
      new TemperatureValues(new DateTime(2020, 11, 23, 23, 0), 7),
      new TemperatureValues(new DateTime(2020, 11, 24, 8, 0), 7),
      new TemperatureValues(new DateTime(2020, 11, 24, 14, 0), 8),
      new TemperatureValues(new DateTime(2020, 11, 24, 18, 0), 15),
      //new TemperatureValues(new DateTime(2021, 11, 24, 18, 0), 15),
    ];

    return [
      new charts.Series<TemperatureValues, DateTime>(
        id: 'Temperature',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TemperatureValues temp, _) => temp.time,
        measureFn: (TemperatureValues temp, _) => temp.temp,
        data: data,
      )
    ];
  }

  /// Hard coded example for humidity
  static List<charts.Series<HumidityValues, DateTime>> _humiditySampleData() {
    final data = [
      new HumidityValues(new DateTime(2020, 11, 23, 0, 0), 80),
      new HumidityValues(new DateTime(2020, 11, 23, 5, 0), 85),
      new HumidityValues(new DateTime(2020, 11, 23, 8, 30), 60),
      new HumidityValues(new DateTime(2020, 11, 23, 16, 0), 70),
      new HumidityValues(new DateTime(2020, 11, 23, 20, 0), 90),
      new HumidityValues(new DateTime(2020, 11, 23, 23, 0), 100),
      new HumidityValues(new DateTime(2020, 11, 24, 8, 0), 60),
      new HumidityValues(new DateTime(2020, 11, 24, 14, 0), 75),
      new HumidityValues(new DateTime(2020, 11, 24, 18, 0), 95),
      //new HumidityValues(new DateTime(2021, 11, 24, 18, 0), 85),
    ];

    return [
      new charts.Series<HumidityValues, DateTime>(
        id: 'Humidity',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (HumidityValues hum, _) => hum.time,
        measureFn: (HumidityValues hum, _) => hum.hum,
        data: data,
      )
    ];
  }

  @override
  State<StatefulWidget> createState() => _Builder(seriesList, animate);
}

void getData(DatabaseReference ref, Map<dynamic, dynamic> a) {
  ref
      .child("test")
      .child("balloons")
      .child("0")
      .child("temperature")
      .once()
      .then((DataSnapshot snapshot) {
    a = snapshot.value;
  });
}

class _Builder extends State<Graph> {
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

/// Sample time series data type
class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);

  @override
  String toString() {
    return time.toString() + " / " + sales.toString();
  }
}

/// Sample temperatures data type
class TemperatureValues {
  final DateTime time;
  final int temp;

  TemperatureValues(this.time, this.temp);

  @override
  String toString() {
    return time.toString() + " / " + temp.toString();
  }
}

/// Sample humidity data type
class HumidityValues {
  final DateTime time;
  final int hum;

  HumidityValues(this.time, this.hum);
}

String readTimeStamp(int timestamp) {
  return DateFormat('d m y HH m') //01-01-2001-01-01
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000));
}
