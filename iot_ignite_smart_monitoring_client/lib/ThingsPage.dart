import 'dart:async';
import 'dart:core';
import 'package:iot_ignite_smart_monitoring_client/DataPage.dart';
import 'package:iotignite_mqtt_client/manager/iot_ignite_rest_manager.dart';
import 'package:iotignite_mqtt_client/model/data.dart';
import 'package:iotignite_mqtt_client/model/extras.dart';
import 'package:iotignite_mqtt_client/model/node_inventory_response.dart';
import 'package:iotignite_mqtt_client/model/sensor_data_response.dart';
import 'package:flutter/material.dart';
import 'package:iotignite_mqtt_client/model/things.dart';


class ThingsPage extends StatefulWidget {
  final String deviceName;
  const ThingsPage({Key? key, required this.deviceName}) : super(key: key);

  @override
  State<ThingsPage> createState() => _ThingsPageState();
}

class _ThingsPageState extends State<ThingsPage> {

  Timer? timerRefreshData;
  Timer? timerRefreshToken;

  //List<List<Data>> sensorDataList = [];

  //   late DeviceResponse deviceResp = DeviceResponse([], [], Pages(0,0,0,0)); // empty object

  late NodeInventoryResponse sensorResp = NodeInventoryResponse("", "", "", Extras([]));

  @override
  void initState() {

    Timer.run(() async {
      var data = await nodeInventoryResponse();
      print("Refreshed sensors init");
      setState((){
        sensorResp = data!;
      });
    });
/*
    // for the first time to work
    Timer.run(() async {
      var data = await sensorDataResp();
      print("Refreshed sensor datas init");
      setState((){
        sensorDataList = data;
      });
    });
*/
    //timerRefreshData = RefreshSensorData();

    timerRefreshToken = IotIgniteRESTLib.getAuthenticatedInstance().RefreshToken();

    super.initState();
  }

  @override
  void dispose() {
    timerRefreshData?.cancel();
    timerRefreshToken?.cancel();

    super.dispose();
  }

  Future<NodeInventoryResponse?> nodeInventoryResponse() async {
    NodeInventoryResponse respNode = await IotIgniteRESTLib.getAuthenticatedInstance().getDeviceNodeInventory(widget.deviceName);
    return respNode;
  }
/*
  Future<List<Things>> sensorDataResp() async {

    List<List<Things>> nodeList = [];
    List<Things> thingList = [];

    NodeInventoryResponse? respNode = await nodeInventoryResponse();

    for (var node in respNode!.extras.nodes) {
      for(var thing in node.things){

        //SensorDataResponse respSensor = await IotIgniteRESTLib.getAuthenticatedInstance().getLastData(widget.deviceName, node.nodeId, thing.id);
        //thingList.add(respSensor.data);

        thingList.add(thing);
      }
      //nodeList.add(thingList);

    }
    return thingList;
  } */
/*
  Timer RefreshSensorData() {
    const tenSec = Duration(seconds:10);
    return Timer.periodic(tenSec, (Timer t) async {
      var data = await sensorDataResp();
      print("Refreshed sensor datas not init");
      setState((){
        sensorDataList = data;
      });
    });
  }
*/
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceName.toString()),
      ),
      body: sensorResp.extras.nodes.isNotEmpty ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 500,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: sensorResp.extras.nodes.length,
                        itemBuilder: (context, index){
                          return ListView.builder(
                              shrinkWrap: true,
                              itemCount: sensorResp.extras.nodes[index].things.length,
                              itemBuilder: (context, innerIndex){
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => DataPage(sensorName: sensorResp.extras.nodes[index].things[innerIndex].id, deviceName: widget.deviceName,),),);
                                    },
                                    child: Card(
                                      child:
                                      Column(
                                        children: [
                                          Text(sensorResp.extras.nodes[index].things[innerIndex].id),
                                          /*
                                          Text(sensorDataList[index][innerIndex].deviceId),
                                          Text(sensorDataList[index][innerIndex].data),
                                          Text(sensorDataList[index][innerIndex].nodeId),
                                          Text(sensorDataList[index][innerIndex].sensorId),
                                          Text(sensorDataList[index][innerIndex].command),
                                          Text(sensorDataList[index][innerIndex].cloudDate.toString()),*/
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                          );
                        }
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ): Center(child: CircularProgressIndicator()),
    );
  }
}
