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

  // Convert to bytes for BLE transmission
  // Format: [notificationId(4 bytes), nameLength(1 byte), messageLength(1 byte), nameBytes, messageBytes]
  List<int> toBytes() {
    final nameBytes = customerName.codeUnits;
    final messageBytes = message.codeUnits;
    
    final byteData = ByteData(6 + nameBytes.length + messageBytes.length);
    byteData.setUint32(0, notificationId, Endian.little);
    byteData.setUint8(4, nameBytes.length);
    byteData.setUint8(5, messageBytes.length);
    
    final result = byteData.buffer.asUint8List();
    result.setAll(6, nameBytes);
    result.setAll(6 + nameBytes.length, messageBytes);
    
    return result;
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
