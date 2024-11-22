import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/call_log_model.dart';

class CallLogView extends StatefulWidget {
  const CallLogView({super.key});

  @override
  State<CallLogView> createState() => _CallLogViewState();
}

class _CallLogViewState extends State<CallLogView> {
  // Firestore collection reference
  final CollectionReference callLogsRef =
  FirebaseFirestore.instance.collection('call_logs');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Call Log"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: callLogsRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No call logs found"));
          }

          // Convert Firestore data to a list of call logs
          final callLogs = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return CallLogEntry(
              name: data['name'],
              number: data['number'],
              callType: CallType.values[data['callType']],
              duration: data['duration'],
              timestamp: data['timestamp'], userId: data['userId'],
            );
          }).toList();

          return ListView.builder(
            itemCount: callLogs.length,
            itemBuilder: (context, index) {
              final log = callLogs[index];
              return ListTile(
                leading: Icon(
                  log.callType == CallType.incoming
                      ? Icons.call_received
                      : log.callType == CallType.outgoing
                      ? Icons.call_made
                      : Icons.call_missed,
                  color: log.callType == CallType.missed ? Colors.red : Colors.green,
                ),
                title: Text(log.name ?? log.number ?? 'Unknown'),
                subtitle: Text('${log.duration ?? 0} seconds'),
                trailing: Text(
                  log.timestamp != null
                      ? DateFormat('dd-MM-yyyy hh:mm a').format(
                    DateTime.fromMillisecondsSinceEpoch(log.timestamp!),
                  )
                      : 'Unknown time',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
