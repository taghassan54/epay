import 'dart:convert';

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
  final _epayPlugin = Epay(deviceId: 'EKIOSK01',ip: '172.16.0.239', port: 6666);
  List<String> messages = [];

  String? transaction;
  String? transactionStatus;
  String? title='ECR Demo';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _epayPlugin.receiveDataFromServerStream?.stream.listen((event) {
      // messages.add("$event");

      setState(() {
        messages.add("");
        messages.add("$event");
        messages.add("#####################################");
        messages.add("");
      });

      List<String> result = event.toString().split("|");
//
      print("result[0] ${result[0].replaceAll('', '')}");
      if (result[0].replaceAll('', '') == "047") {
        List<int> decodedBytes = base64.decode(result[2]);

        setState(() {
          messages.add(result[0]);
          messages.add(result[1]);
          messages.add(result[3]);
          messages.add("******************************");
        });
        String decodedString = utf8.decode(decodedBytes);
        List<String> decodedStrings = decodedString.split("|");
        decodedStrings.forEach((element) {
          if (element.isNotEmpty) {
            setState(() {
              messages.add(element);
            });
          }
        });

        if (kDebugMode) {
          print("$decodedStrings");
          print("transaction Id : ${decodedStrings[7]}");
          print("transaction Status : ${result[3]}");
        }

        setState(() {
          transaction = decodedStrings[7]
              .replaceAll("", "")
              .replaceAll("", '')
              .replaceAll(" ", "")
              .trim();
          transactionStatus = result[3]
              .replaceAll("", "")
              .replaceAll("", "")
              .replaceAll(" ", "")
              .trim();
        });
      }

      if (result[0].replaceAll('', '') == "001"||result[0].replaceAll('', '') == "002") {

        setState(() {
          title=result[3].replaceAll("", "")
              .replaceAll("", '')
              .replaceAll(" ", "")
              .trim();
        });

      }

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
      home: Scaffold(
        appBar: AppBar(
          title:  Text(
              '$title'),
          actions: [
            if (transaction != null && transactionStatus == '0') ...[
              ElevatedButton(
                  onPressed: () {
                    _epayPlugin.confirmTicket(transaction: transaction);
                  },
                  child: Text("Confirm $transaction")),
              ElevatedButton(
                  onPressed: () {
                    _epayPlugin.rejectTicket(transaction: transaction);
                  },
                  child: Text("Reject $transaction"))
            ],
            if (transactionStatus == '1') const Text("Confirmed",textAlign: TextAlign.center,style: TextStyle(fontSize: 22
            )),
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
            const SizedBox(width: 5.0,),
            FloatingActionButton(
              onPressed: () {
                _epayPlugin.getLastTicket();
              },
              child: const Icon(Icons.account_balance_sharp),
            ),
            const SizedBox(width: 5.0,),
            FloatingActionButton(
              onPressed: () {
                _epayPlugin.getDeviceInfo();
              },
              child: const Icon(Icons.check_circle_outline),
            ),
            const SizedBox(width: 5.0,),
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
