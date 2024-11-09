import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';

class CallLogListPage extends StatefulWidget {
  @override
  _CallLogListPageState createState() => _CallLogListPageState();
}

class _CallLogListPageState extends State<CallLogListPage> {
  Iterable<CallLogEntry> _callLogs = [];

  @override
  void initState() {
    super.initState();
    _fetchCallLogs();
  }

  Future<void> _fetchCallLogs() async {
    try {
      final Iterable<CallLogEntry> callLogs = await CallLog.get();
      setState(() {
        _callLogs = callLogs;
      });
    } catch (e) {
      print('Failed to get call logs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Call Log List')),
      body: _callLogs.isNotEmpty
          ? ListView.builder(
        itemCount: _callLogs.length,
        itemBuilder: (context, index) {
          final call = _callLogs.elementAt(index);
          return ListTile(
            title: Text(call.name ?? 'Unknown'),
            subtitle: Text('${call.number} - ${call.callType}'),
            trailing: Text('${call.duration} sec'),
          );
        },
      )
          : Center(child: Text('No call log data available')),
    );
  }
}
