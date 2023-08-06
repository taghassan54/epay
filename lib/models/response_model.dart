import 'dart:convert';

import 'package:epay/logger_helper.dart';
import 'package:epay/models/ticket_model.dart';

class ResponseModel {
  final String status;
  final String deviceID;
  final String indicator;
  final String message;
  final TicketModel? ticket;

  // Add more fields if needed.

  ResponseModel({
    required this.status,
    required this.deviceID,
    required this.indicator,
    required this.message,
    required this.ticket,
    // Add more constructor parameters if needed.
  });

  factory ResponseModel.fromList(List<String> list) {
    TicketModel? ticket;
    var status=list[0]
        .replaceAll("", "")
        .replaceAll("", '')
        .replaceAll(" ", "")
        .trim();
    var indicator =list[2]
        .replaceAll("", "")
        .replaceAll("", '')
        .replaceAll(" ", "")
        .trim();

    var message =list.length > 3? list[3]
        .replaceAll("", "")
        .replaceAll("", '')
        .trim():'-';

    String? decodedString;
    if(status=='047'){
      List<int> decodedBytes = base64.decode(list[2]);
      decodedString= utf8.decode(decodedBytes);
      ticket= TicketModel.fromString(decodedString);
    }


      LoggerHelper.logWarning("list $list");


    if(list.length >5 && list[3].endsWith('Processing...001')){
      message =list[6].replaceAll("", "")
          .replaceAll("", '')
          .trim();
    }



    if(list.length >6 && list[3].endsWith('002')){
      message =list[6].replaceAll("", "")
          .replaceAll("", '')
          .replaceAll(" ", "")
          .trim();
      status ="002";
    }

    if(list.length >6 && list[3].endsWith('062')){
      message =list[6].replaceAll("", "")
          .replaceAll("", '')
          .replaceAll(" ", "")
          .trim();
    }


    return ResponseModel(
      status: status,
      deviceID: list[1]
          .replaceAll("", "")
          .replaceAll("", '')
          .replaceAll(" ", "")
          .trim(),
      indicator: indicator,
      message: message,
      ticket:ticket
      // Map additional fields to list indices.
    );
  }
}
