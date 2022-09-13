import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:iotignite_mqtt_client/manager/iot_ignite_rest_manager.dart';
import 'package:iotignite_mqtt_client/model/data.dart';
import 'package:iotignite_mqtt_client/model/node_inventory_response.dart';
import 'package:iot_ignite_smart_monitoring_client/ThingsPage.dart';
import 'package:iotignite_mqtt_client/model/sensor_data_response.dart';


class DataPage extends StatefulWidget {
  final String deviceName;
  final String sensorName;
  const DataPage({Key? key, required this.sensorName, required this.deviceName}) : super(key: key);

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {

  Timer? timerRefreshData;
  Timer? timerRefreshToken;

  List<List<Data>> sensorDataList = [];

  @override
  void initState() {

    Timer.run(() async {
      var data = await sensorDataResp();
      print("Refreshed sensor datas");
      setState((){
        sensorDataList = data;
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

  Future<NodeInventoryResponse?> nodeInventoryResponse() async {
    NodeInventoryResponse respNode = await IotIgniteRESTLib.getAuthenticatedInstance().getDeviceNodeInventory(widget.deviceName);
    return respNode;
  }

  Future<List<List<Data>>> sensorDataResp() async {

    List<List<Data>> nodeList = [];
    List<Data> thingList = [];

    NodeInventoryResponse? respNode = await nodeInventoryResponse();

    for (var node in respNode!.extras.nodes) {
      for(var thing in node.things){

        SensorDataResponse respSensor =
        await IotIgniteRESTLib.getAuthenticatedInstance().getLastData(widget.deviceName, node.nodeId, thing.id);

        thingList.add(respSensor.data);
      }
      nodeList.add(thingList);
    }
    return nodeList;
  }

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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sensorName.toString()),
      ),
      body: sensorDataList.isNotEmpty ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 500,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: sensorDataList.length,
                        itemBuilder: (context, index){
                          return ListView.builder(
                              shrinkWrap: true,
                              itemCount: sensorDataList[index].length,
                              itemBuilder: (context, innerIndex){
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    child:
                                    Column(
                                      children: [
                                        Text(sensorDataList[index][innerIndex].data),
                                      ],
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
      ): const Center(child: CircularProgressIndicator()),
    );
  }


}
