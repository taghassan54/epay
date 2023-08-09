import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:epay/logger_helper.dart';
import 'package:epay/models/response_model.dart';
import 'package:epay/models/ticket_model.dart';
import 'package:flutter/foundation.dart';

import 'epay_platform_interface.dart';

class Epay {
  final String ip;
  final String deviceId;
  final int port;

  Epay({required this.ip, required this.port, required this.deviceId});

  StreamController<ResponseModel>? receiveDataFromServerStream =
      StreamController<ResponseModel>();

  Future<String?> getPlatformVersion() {
    return EpayPlatform.instance.getPlatformVersion();
  }

  void sale({required amount}) {
    send("$deviceId|010||$amount|||||EN||");
  }

  void getLastTicket() {
    send("$deviceId|047|");
  }

  void confirmTicket({required transaction}) {
    send("$deviceId|030|$transaction|1");
  }

  void rejectTicket({required transaction}) {
    send("$deviceId|030|$transaction|0");
  }

  void getDeviceInfo() {
    send("003");
  }

  void getTerminalStatus() {
    send("$deviceId|040|");
  }

  send(String data) {
    connectToTCPServer().then((socket) {
      if (socket != null) {
        sendDataOverTCP(socket, data).then((_) {
          if (kDebugMode) {
            LoggerHelper.logInfo('Data sent successfully!');
          }
          receiveDataFromServer(socket);
        });
      } else {
        if (kDebugMode) {
          LoggerHelper.logInfo('socket is null ');
        }
      }
    });
  }

  Future<Socket?> connectToTCPServer() async {
    try {
      // Replace 'your_server_address' with the actual server IP address or domain.
      final socket =
          await Socket.connect(ip, port, timeout: const Duration(seconds: 15),);

      // Perform operations with the socket, e.g., send data, listen for data, etc.
      if (kDebugMode) {
        LoggerHelper.logInfo("socket connected");
      }
      // sendDataOverTCP(socket);
      // Close the socket when done.
      //

      return socket;
    } catch (e) {
      if (kDebugMode) {
        LoggerHelper.logInfo('Error while connecting to the server: $e');
      }
    }
    return null;
  }

  Future<void> sendDataOverTCP(Socket socket, String data) async {
    try {
      final dataToSend = utf8.encode(data);

      var isSent = await sendBytes(dataToSend, socket);
      if (kDebugMode) {
        LoggerHelper.logInfo("isSent $isSent");
      }
      socket.close();
    } catch (e) {
      socket.close();
      if (kDebugMode) {
        LoggerHelper.logInfo('Error while sending data: $e');
      }
    }
  }

  Future<bool> sendBytes(List<int> data, Socket socket) async {
    List<int> array = List<int>.filled(data.length + 3, 0);
    array[0] = 2;
    array.setRange(1, data.length + 1, data);
    array[data.length + 1] = 3;
    array[data.length + 2] = 10;

    if (kDebugMode) {
      LoggerHelper.logInfo("Sending ${array.length}: $array");
    }

    try {
      // Send data
      socket.add(array);
      if (kDebugMode) {
        LoggerHelper.logInfo("socket address : ${socket.address}");
      }
      if (kDebugMode) {
        LoggerHelper.logInfo("socket port : ${socket.port}");
      }
      socket.write("003");
      // Close the socket after sending
      socket.close();

      return true;
    } catch (e) {
      if (kDebugMode) {
        LoggerHelper.logInfo("Error sending data: $e");
      }
      return false;
    }
  }

  void receiveDataFromServer(Socket socket) {
    socket.listen(
      (List<int> data) {
        final receivedData = utf8.decode(data);
        LoggerHelper.logInfo('Received data from server: $receivedData');

        List<String> result = receivedData.toString().split("|");

        ResponseModel responseModel = ResponseModel.fromList(result);

        switch (responseModel.status) {
          case "047":
            if(responseModel.ticket!=null&&responseModel.ticket?.transactionId!=null&&responseModel.message=='0') {
              confirmTicket(transaction: "${responseModel.ticket?.transactionId}");
            }
            // LoggerHelper.logInfo("crruncy ${responseModel.ticket?.currency}");
            break;
          case "001":
            // LoggerHelper.logInfo(
            //     "indicator : ${responseModel.indicator} | message : ${responseModel.message}");
            break;
          case "002":
            // LoggerHelper.logInfo(
            //     "indicator : ${responseModel.indicator} | message : ${responseModel.message}");
            break;
          case "040":
            break;
          case "062":
            break;
          case "010":
            getLastTicket();
            break;
          case "030":
            getLastTicket();
            break;

        }

        receiveDataFromServerStream?.add(responseModel);
      },
      onError: (error) {
        if (error is SocketException && error.osError?.errorCode == 32) {
          // Handle Broken Pipe error here.
          if (kDebugMode) {
            LoggerHelper.logInfo(
                'Broken pipe error: The server closed the connection.');
          }
        } else if (error is SocketException &&
            error.osError?.errorCode == 104) {
          // Handle Connection reset by peer error here.
          if (kDebugMode) {
            LoggerHelper.logInfo(
                'Connection reset by peer: The server forcibly closed the connection.');
          }
        } else {
          // Handle other socket errors here.
          if (kDebugMode) {
            LoggerHelper.logInfo('Error while receiving data: $error');
          }
        }
        socket.close();
      },
      onDone: () {
        LoggerHelper.logInfo('Connection closed by server.');
        socket.close();
      },
    );
  }
}
