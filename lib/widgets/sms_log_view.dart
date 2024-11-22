import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/sms_model.dart';

class SmsLogView extends StatefulWidget {
  const SmsLogView({super.key});

  @override
  State<SmsLogView> createState() => _SmsLogViewState();
}

class _SmsLogViewState extends State<SmsLogView> {
  final CollectionReference smsLogsRef =
  FirebaseFirestore.instance.collection('smsLogs');


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Log'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: smsLogsRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No SMS logs found"));
          }

          // Map Firestore data to a list of SmsLog objects
          final smsLogs = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return SmsLog.fromMap(data);
          }).toList();

          return ListView.builder(
            itemCount: smsLogs.length,
            itemBuilder: (context, index) {
              final log = smsLogs[index];
              return ListTile(
                title: Text(log.address ?? 'No address'),
                subtitle: Text(log.body ?? 'No body'),
                trailing: Text(
                  log.timestamp != null
                      ? DateFormat('dd-MM-yyyy hh:mm a').format(
                    DateTime.fromMillisecondsSinceEpoch(log.timestamp!),
                  )
                      : 'No timestamp',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
