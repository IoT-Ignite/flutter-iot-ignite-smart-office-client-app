import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:iotignite_mqtt_client/manager/iot_ignite_rest_manager.dart';
import 'package:iotignite_mqtt_client/model/data.dart';
import 'package:iotignite_mqtt_client/model/sensor_data_response.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:gradient_borders/gradient_borders.dart';

class DataPage extends StatefulWidget {
  final String deviceName;
  final String sensorName;
  final String nodeName;
  const DataPage({Key? key, required this.sensorName, required this.nodeName, required this.deviceName}) : super(key: key);

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {

  Timer? timerRefreshData;
  Timer? timerRefreshToken;

  late SensorDataResponse sensorResp = SensorDataResponse("", Data("", "", "", 0, "", "", 0));

  @override
  void initState() {

    Timer.run(() async {
      var data = await sensorDataResp();
      print("Refreshed sensor datas");
      setState((){
        sensorResp = data!;
      });
    });

    timerRefreshData = RefreshSensorData();

    timerRefreshToken = IotIgniteRESTLib.getAuthenticatedInstance().RefreshToken();

    super.initState();
  }

  @override
  void dispose() {
    timerRefreshData?.cancel();
    timerRefreshToken?.cancel();

    super.dispose();
  }


  Future<SensorDataResponse?> sensorDataResp() async {
    SensorDataResponse respSensor = await IotIgniteRESTLib.getAuthenticatedInstance().getLastData(widget.deviceName, widget.nodeName, widget.sensorName);
    return respSensor;
  }

  Timer RefreshSensorData() {
    const tenSec = Duration(seconds:10);
    return Timer.periodic(tenSec, (Timer t) async {
      var data = await sensorDataResp();
      print("Refreshed sensor datas not init");
      setState((){
        sensorResp = data!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sensorName.toString()),
      ),
      body: sensorResp.data.deviceId != "" ? Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 0,
                color: Colors.orange[50],
                shape: const GradientOutlineInputBorder(
                  gradient: LinearGradient(colors: [Colors.lightBlueAccent, Colors.lightGreenAccent ]),
                  width: 2,
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                child: SizedBox(
                  width: 350,
                  height: 200,
                  child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("DEVICE:",
                          style: TextStyle(fontFamily: 'SignikaNegative', fontSize: 20, color: Colors.indigo, fontWeight: FontWeight.bold),),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Text(widget.sensorName,
                            style: TextStyle(fontFamily: 'SignikaNegative', fontSize: 20, color: Colors.indigo[300], fontWeight: FontWeight.bold),),
                          ),
                          const Text("DATA:",
                            style: TextStyle(fontFamily: 'SignikaNegative', fontSize: 20, color: Colors.indigo, fontWeight: FontWeight.bold),),
                          Text(sensorResp.data.data == "" ? "NO DATA" : sensorResp.data.data,
                          style: TextStyle(fontFamily: 'SignikaNegative', fontSize: 25, color: Colors.green[600], fontWeight: FontWeight.bold),),
                        ],
                      ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ): Center(
        child: LoadingAnimationWidget.fourRotatingDots(
            color: Colors.orangeAccent,
            size: 60
        ),
      ),
    );
  }
}
