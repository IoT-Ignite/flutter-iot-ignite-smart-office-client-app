import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:iotignite_mqtt_client/manager/iot_ignite_rest_manager.dart';
import 'package:iotignite_mqtt_client/model/device_response.dart';
import 'package:iotignite_mqtt_client/view/things_page.dart';
import 'package:iotignite_mqtt_client/model/pages.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key}) : super(key: key);

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {

  late DeviceResponse deviceResp = DeviceResponse([], [], Pages(0,0,0,0));

  Future<DeviceResponse> deviceResponse() async {

    DeviceResponse respDevice = await IotIgniteRESTLib.getAuthenticatedInstance().getDeviceInfo();

    return respDevice;
  }


  @override
  void initState() {

    Timer.run(() async {
      var data = await deviceResponse();
      print("Refreshed humidity");
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
                //exit();
              },
              icon: Icon(Icons.exit_to_app)),
        ],
      ),
      body: deviceResp.content.isNotEmpty ? ListView.builder(
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
                      Text(deviceResp.content[index].label),
                      Text(deviceResp.content[index].model),
                    ],
                  ),
                ),
              ),
            );
          }
      ): const Center(
          child: CircularProgressIndicator()
      ),
    );
  }
}
