import 'dart:typed_data';

class NotificationData {
  final String customerName;
  final String message;
  final DateTime timestamp;
  final int notificationId;

  NotificationData({
    required this.customerName,
    required this.message,
    required this.timestamp,
    required this.notificationId,
  });

  factory NotificationData.fromBytes(List<int> bytes) {
    // Parse bytes: [notificationId(4 bytes), nameLength(1 byte), messageLength(1 byte), nameBytes, messageBytes]
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    final notificationId = byteData.getUint32(0, Endian.little);
    final nameLength = byteData.getUint8(4);
    final messageLength = byteData.getUint8(5);
    
    final nameBytes = bytes.sublist(6, 6 + nameLength);
    final messageBytes = bytes.sublist(6 + nameLength, 6 + nameLength + messageLength);
    
    return NotificationData(
      notificationId: notificationId,
      customerName: String.fromCharCodes(nameBytes),
      message: String.fromCharCodes(messageBytes),
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'notificationId': notificationId,
    };
  }
}
