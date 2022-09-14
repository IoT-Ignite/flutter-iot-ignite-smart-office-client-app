import 'dart:async';
import 'dart:core';
import 'package:iot_ignite_smart_monitoring_client/DataPage.dart';
import 'package:iotignite_mqtt_client/manager/iot_ignite_rest_manager.dart';
import 'package:iotignite_mqtt_client/model/extras.dart';
import 'package:iotignite_mqtt_client/model/node_inventory_response.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class ThingsPage extends StatefulWidget {
  final String deviceName;
  const ThingsPage({Key? key, required this.deviceName}) : super(key: key);

  @override
  State<ThingsPage> createState() => _ThingsPageState();
}

class _ThingsPageState extends State<ThingsPage> {

  Timer? timerRefreshData;
  Timer? timerRefreshToken;

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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceName.toString()),
      ),
      body: tempWidget(

      ),
    );
  }

  Center tempWidget(){
    if(sensorResp.code == ""){
      return loadingWidget();
    } else if(sensorResp.code == "200") {
      return nodeListWidget();
    } else {
      return const Center(child: Text("NO SENSOR",
          style: TextStyle(fontFamily: 'SignikaNegative', fontSize: 25, color: Colors.indigo, fontWeight: FontWeight.bold),));
    }
  }

  Center loadingWidget() {
    return Center(
      child: LoadingAnimationWidget.fourRotatingDots(
          color: Colors.orangeAccent,
          size: 60
      ),
    );
  }

  Center nodeListWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 575,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      itemCount: sensorResp.extras.nodes.length,
                      itemBuilder: (context, index){
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: sensorResp.extras.nodes[index].things.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, innerIndex){
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  tileColor: Colors.green[50],
                                  leading: const Icon(Icons.device_thermostat),
                                  title: Text(sensorResp.extras.nodes[index].nodeId + " / " + sensorResp.extras.nodes[index].things[innerIndex].id),
                                  subtitle: Text(sensorResp.extras.nodes[index].things[innerIndex].type),
                                  trailing: const Icon(Icons.keyboard_arrow_right),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(13)),),
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => DataPage(nodeName: sensorResp.extras.nodes[index].nodeId ,sensorName: sensorResp.extras.nodes[index].things[innerIndex].id, deviceName: widget.deviceName,),),);
                                  },
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
    );
  }
}
