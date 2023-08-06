class TicketModel {
  final String code;
  final String deviceId;
  final String transactionId;
  final String currency;
  final String card;
  final String cardType;
  final double amount;
  final String status;

  // Add more fields as needed

  TicketModel({
    required this.code,
    required this.currency,
    required this.card,
    required this.cardType,
    required this.deviceId,
    required this.transactionId,
    required this.status,
    required this.amount,
    // Initialize additional fields here
  });

  factory TicketModel.fromString(String encodedData) {
    List<String> dataFields = encodedData.split('|');

    // if (dataFields.length < 77) {
    //   throw Exception('Invalid encoded data format');
    // }

    dataFields = dataFields.where((element) => element.isNotEmpty).toList();

    // Add more fields parsing as needed

    return TicketModel(
      code: dataFields[0],
      deviceId: dataFields[1],
      amount: double.parse(dataFields[2]),
      currency: dataFields[5],
      card: dataFields[6],
      transactionId: dataFields[7],
      status: dataFields[11],
      cardType: dataFields[17],
      // Provide values for additional fields here
    );
  }
}
