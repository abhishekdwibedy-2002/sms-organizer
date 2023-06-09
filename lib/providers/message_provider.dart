import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messageProvider = FutureProvider.autoDispose<List<SmsMessage>>(
  (ref) => ref.watch(messageNotifierProvider).fetchMessages(),
);

final messageNotifierProvider = Provider<MessageNotifier>((ref) {
  return MessageNotifier();
});

class MessageNotifier extends StateNotifier<List<SmsMessage>> {
  MessageNotifier() : super([]);

  Future<List<SmsMessage>> fetchMessages() async {
    final query = SmsQuery();
    final permission = await Permission.sms.status;
    if (permission.isGranted) {
      try {
        final messages = await query.querySms(
          kinds: [
            SmsQueryKind.inbox,
          ],
        );
        // Perform any additional filtering or sorting if needed
        var now = DateTime.now(); //show recent time
        final filteredMessages = messages.where((message) {
          var difference = now.difference(message.date!);
          // condition to return the sms that is inside 1 day and 25 hours ( 1 day 1 hours)
          return difference.inDays < 1 ||
              (difference.inDays == 1 && difference.inHours <= 1);
        }).toList();
        debugPrint('SMS inbox messages: ${filteredMessages.length}');
        state = filteredMessages;
        return filteredMessages;
      } catch (error) {
        debugPrint('Error fetching messages: $error');
        rethrow;
      }
    } else {
      await Permission.sms.request();
      throw 0;
    }
  }
}
