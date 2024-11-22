class SmsLog {
  final String? userId; // Optional: To link SMS to a specific user
  final String? address; // The sender's phone number or address
  final String? body; // The message content
  final int? timestamp; // The timestamp of the message
  final String? type; // Message type (e.g., inbox, sent)

  SmsLog({
    required this.userId,
    required this.address,
    required this.body,
    required this.timestamp,
    required this.type,
  });

  // Factory method to create SmsLog from a Firebase document
  factory SmsLog.fromMap(Map<String, dynamic> data) {
    return SmsLog(
      userId: data['userId'],
      address: data['address'],
      body: data['body'],
      timestamp: data['timestamp'],
      type: data['type'],
    );
  }

  // Convert SmsLog to a map for Firebase storage
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'address': address,
      'body': body,
      'timestamp': timestamp,
      'type': type,
    };
  }
}
