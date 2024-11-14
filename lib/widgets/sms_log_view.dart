import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

class SmsLogView extends StatefulWidget {
  const SmsLogView({super.key});

  @override
  State<SmsLogView> createState() => _SmsLogViewState();
}

class _SmsLogViewState extends State<SmsLogView> {
  final Telephony telephony = Telephony.instance;
  List<SmsMessage> smsMessages = [];

  @override
  void initState() {
    super.initState();
    _fetchSmsLogs();
  }

  // Fetch SMS logs
  Future<void> _fetchSmsLogs() async {
    try {
      List<SmsMessage> messages = await telephony.getInboxSms();
      setState(() {
        smsMessages = messages;
      });
    } catch (e) {
      print("Error fetching SMS messages: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Log'),
      ),
      body: smsMessages.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Show a loading spinner while fetching
          : ListView.builder(
        itemCount: smsMessages.length,
        itemBuilder: (context, index) {
          SmsMessage sms = smsMessages[index];
          return ListTile(
            title: Text(sms.address ?? 'No address'),
            subtitle: Text(sms.body ?? 'No body'),
            trailing: Text(sms.date?.toString() ?? 'No timestamp'),
          );
        },
      ),
    );
  }
}
