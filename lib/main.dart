import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final MqttClient client = MqttClient('broker.emqx.io', '');

  void connect() async {
    client.logging(on: false);
    client.keepAlivePeriod = 60;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    print('Client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      print('Client exception: $e');
      client.disconnect();
    } on SocketException catch (e) {
      print('Socket exception: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Client connected');
    } else {
      print(
          'Client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      exit(-1);
    }

    const subTopic = 'topic/sub_test';
    print('Subscribing to the $subTopic topic');
    client.subscribe(subTopic, MqttQos.atMostOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message!);
      print('Received message:$pt from topic: ${c[0].topic}>');
    });
  }

  void onDisconnected() {
    print('Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print('Solicited disconnection');
    }
    exit(-1);
  }

  void onConnected() {
    print('Client connection was successful');
  }

  void onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  void pong() {
    print('Ping response client callback invoked');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('MQTT Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement the button functionality.
                },
                child: Text('Cream 1'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement the button functionality.
                },
                child: Text('Cream 2'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement the button functionality.
                },
                child: Text('Cream 3'),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Amount of Cream 1 in mg',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Amount of Cream 2 in mg',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Amount of Cream 3 in mg',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  connect();
                },
                child: Text('Connect to MQTT Broker'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
