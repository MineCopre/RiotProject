import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Height extends StatefulWidget {
  Height();

  @override
  State<StatefulWidget> createState() => _Height();
}

class _Height extends State<Height> {
  int height = 5;
  int min = 1;
  int max = 10;

  _Height();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
          alignment: Alignment.center,
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
          child: Column(
            children: <Widget>[
              Container(
                  child: AutoSizeText(
                'Height Adjustment:',
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.07,
                    color: Color(0xFF0C2D48)),
                maxLines: 1,
              )),
              //Upwards Button
              Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.09),
                child: FlatButton(
                    shape: CircleBorder(),
                    color: Color(0xFFB1D4E0),
                    textColor: Color(0xFF0C2D48),
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.033),
                    onPressed: () {
                      setState(() {
                        if (height < max) {
                          height++;
                        } else {
                          showToast();
                        }
                      });
                    },
                    child: Icon(Icons.keyboard_arrow_up_rounded,
                        color: Color(0xFF0C2D48),
                        size: MediaQuery.of(context).size.width * 0.2)),
              ),
              //Middle Text
              Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.03,
                      bottom: MediaQuery.of(context).size.height * 0.03),
                  child: AutoSizeText(
                    '$height\m',
                    style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.07,
                        color: Color(0xFF0C2D48)),
                    maxLines: 1,
                  )),
              Container(
                  child: FlatButton(
                      shape: CircleBorder(),
                      color: Color(0xFFB1D4E0),
                      textColor: Color(0xFF0C2D48),
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.033),
                      onPressed: () {
                        setState(() {
                          if (height > min) {
                            height--;
                          } else {
                            showToast();
                          }
                        });
                      },
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF0C2D48),
                          size: MediaQuery.of(context).size.width * 0.2)))
              //Downwards Button
            ],
          ),
        ));
  }

  showToast() {
    String msg;
    if (height == max) {
      msg = 'Maximum Height Reached.';
    } else {
      msg = 'Minimum Height Reached.';
    }

    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }
}
