import 'dart:convert';

import 'package:epay/logger_helper.dart';
import 'package:epay/models/response_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:epay/epay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _epayPlugin =
      Epay(deviceId: 'EKIOSK01', ip: '172.16.0.239', port: 6666);
  List<String> messages = [];

  String? transaction;
  String? transactionStatus;
  String? title = 'ECR Demo';
  ResponseModel? response;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _epayPlugin.receiveDataFromServerStream?.stream
        .listen((ResponseModel event) {
      // messages.add("$event");

      setState(() {
        response = event;
        messages.add("");
        messages.add("#####################################");
        messages.add("status : ${event.status}");
        messages.add("#####################################");
        messages.add("message : ${event.message}");
        messages.add("#####################################");
        messages.add("indicator : ${event.indicator}");
        messages.add("#####################################");
        messages.add("deviceID : ${event.deviceID}");

        if (event.ticket != null) {
          messages.add("#####################################");
          messages.add("ticket status : ${event.ticket?.status}");
          messages.add("ticket currency : ${event.ticket?.currency}");
          messages.add("ticket amount : ${event.ticket?.amount}");
          messages.add("ticket code : ${event.ticket?.code}");
          messages
              .add("ticket transaction Id : ${event.ticket?.transactionId}");
          messages.add(
              "ticket card : ${event.ticket?.card} / ${event.ticket?.cardType}");
        }
        messages.add("#####################################");
        messages.add("");
      });
      return;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _epayPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('$title'),
          actions: [
            if (response?.ticket != null && response?.message == '0') ...[
              ElevatedButton(
                  onPressed: () {
                    _epayPlugin.confirmTicket(
                        transaction: response?.ticket?.transactionId);
                  },
                  child: Text("Confirm ${response?.ticket?.transactionId}")),
              ElevatedButton(
                  onPressed: () {
                    _epayPlugin.rejectTicket(
                        transaction: response?.ticket?.transactionId);
                  },
                  child: Text("Reject ${response?.ticket?.transactionId}"))
            ],
            if (response?.ticket != null && response?.message == '1')
              const Text("Confirmed",
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 22)),
            if (response?.ticket != null && response?.message == '2')
              const Text("Rejected",
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 22)),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: () {
                _epayPlugin.sale(amount: 50000);
              },
              child: const Icon(Icons.money),
            ),
            const SizedBox(
              width: 5.0,
            ),
            FloatingActionButton(
              onPressed: () {
                _epayPlugin.getLastTicket();
              },
              child: const Icon(Icons.account_balance_sharp),
            ),
            const SizedBox(
              width: 5.0,
            ),
            FloatingActionButton(
              onPressed: () {
                _epayPlugin.getDeviceInfo();
              },
              child: const Icon(Icons.check_circle_outline),
            ),
            const SizedBox(
              width: 5.0,
            ),
            FloatingActionButton(
              onPressed: () {
                _epayPlugin.getTerminalStatus();
              },
              child: const Icon(Icons.connecting_airports),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: messages.reversed.map((e) => Text(e)).toList(),
          ),
        ),
      ),
    );
  }
}
