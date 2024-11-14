import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'dart:async';

import 'package:intl/intl.dart';

class CallLogView extends StatefulWidget {
  const CallLogView({super.key});

  @override
  State<CallLogView> createState() => _CallLogViewState();
}

class _CallLogViewState extends State<CallLogView> {
  List<CallLogEntry> _callLogs = [];

  @override
  void initState() {
    super.initState();
    _fetchCallLogs();
  }

  Future<void> _fetchCallLogs() async {
    try {
      Iterable<CallLogEntry> entries = await CallLog.get();
      setState(() {
        _callLogs = entries.toList();
      });
    } catch (e) {
      print("Error fetching call logs: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Call Log"),
      ),
      body: _callLogs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _callLogs.length,
        itemBuilder: (context, index) {
          CallLogEntry log = _callLogs[index];
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
            subtitle: Text('${log.duration} seconds'),
            trailing: Text(
              DateFormat('dd-MM-yyyy hh:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(log.timestamp ?? 0),
              ),
            ),
          );
        },
      ),
    );
  }
}
