import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:intl/intl.dart';

class MessageListView extends StatelessWidget {
  const MessageListView({
    super.key,
    required this.message,
  });

  final SmsMessage message;

  @override
  Widget build(BuildContext context) {
    var limitMessageBody = message.body!.length <= 80
        ? message.body
        : '${message.body!.substring(0, 80)}...';
    // Format the date to display only the time
    var formattedTime = _formatDateTime(message.date!);
    // DateFormat.Hm().format(message.date!);
    return Card(
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ListTile(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  '${message.sender}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                formattedTime,
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          // title: Text('${message.sender}'),
          // trailing: Text(formattedTime),
          subtitle: Text(limitMessageBody!, maxLines: 2),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    var now = DateTime.now();
    var difference = now.difference(dateTime);

    if (difference.inHours < 24) {
      return DateFormat.Hm().format(dateTime);
    } else {
      return DateFormat.yMd().format(dateTime);
    }
  }
}
