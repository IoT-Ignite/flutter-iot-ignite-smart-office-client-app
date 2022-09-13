import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iotignite_mqtt_client/manager/iot_ignite_rest_manager.dart';
import 'package:iotignite_mqtt_client/model/device_response.dart';
import 'package:iotignite_mqtt_client/model/pages.dart';
import 'package:iot_ignite_smart_monitoring_client/ThingsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key}) : super(key: key);

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {

  String? email;
  String? password;
  bool? rememberMe;
  late DeviceResponse deviceResp = DeviceResponse([], [], Pages(0,0,0,0)); // empty object

  Future<DeviceResponse> deviceResponse() async {
    DeviceResponse respDevice = await IotIgniteRESTLib.getAuthenticatedInstance().getDeviceInfo();
    return respDevice;
  }

  // When going back from the bottom back button
  Future<bool> backButton(BuildContext context) async {
    var sp = await SharedPreferences.getInstance();

    if(rememberMe == false){
      sp.remove("email");
      sp.remove("password");
    }

    IotIgniteRESTLib.getAuthenticatedInstance().signOut();

    SystemNavigator.pop(); // exit from the app

    return true;
  }


  Future<void> dataRead() async{
    var sp = await SharedPreferences.getInstance();

    setState(() {
      email = sp.getString("email") ?? "no name";
      password = sp.getString("password") ?? "no key";
      rememberMe = sp.getBool("remember_me") ?? false;
    });
  }

  Future<void> exit() async{
    var sp = await SharedPreferences.getInstance();

    if(rememberMe == false){
      sp.remove("email");
      sp.remove("password");
    }

    IotIgniteRESTLib.getAuthenticatedInstance().signOut();

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));
  }

  @override
  void initState() {

    dataRead();

    Timer.run(() async {
      var data = await deviceResponse();
      print("Refreshed devices");
      setState((){
        deviceResp = data;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device List"),
        actions: [
          IconButton(
              onPressed: (){
                exit();
              },
              icon: Icon(Icons.exit_to_app)),
        ],
      ),
      body: deviceResp.content.isNotEmpty ? WillPopScope(
        onWillPop: () => backButton(context),
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: deviceResp.content.length,
            itemBuilder: (context, index){
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ThingsPage(deviceName: deviceResp.content[index].deviceId),),);
                  },
                  child: Card(
                    child:
                    Column(
                      children: [
                        Text(deviceResp.content[index].deviceId),
                        Text(deviceResp.content[index].label == "" ? deviceResp.content[index].model : deviceResp.content[index].label),
                        //Text(deviceResp.content[index].model),
                      ],
                    ),
                  ),
                ),
              );
            }
        ),
      ): const Center(
          child: CircularProgressIndicator()
      ),
    );
  }
}
