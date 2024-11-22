enum CallType { incoming, outgoing, missed }

class CallLogEntry {
  final String? userId; // User ID to associate call log with a specific user
  final String? name; // Name of the contact (if available)
  final String? number; // Phone number
  final CallType callType; // Call type: incoming, outgoing, or missed
  final int? duration; // Duration of the call in seconds
  final int? timestamp; // Call timestamp in milliseconds since epoch

  CallLogEntry({
    required this.userId,
    required this.name,
    required this.number,
    required this.callType,
    required this.duration,
    required this.timestamp,
  });

  // Factory method to create a CallLogEntry from Firestore data
  factory CallLogEntry.fromMap(Map<String, dynamic> data) {
    return CallLogEntry(
      userId: data['userId'],
      name: data['name'],
      number: data['number'],
      callType: CallType.values[data['callType']],
      duration: data['duration'],
      timestamp: data['timestamp'],
    );
  }

  // Convert CallLogEntry to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'number': number,
      'callType': callType.index, // Store enum as an integer
      'duration': duration,
      'timestamp': timestamp,
    };
  }
}
