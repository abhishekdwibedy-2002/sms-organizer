import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smstracker/notification.dart';

final messageProvider = StreamProvider.autoDispose<List<SmsMessage>>(
  (ref) => ref.watch(messageNotifierProvider).messageStream(),
);

final messageNotifierProvider = Provider<MessageNotifier>((ref) {
  return MessageNotifier();
});

class MessageNotifier extends StateNotifier<List<SmsMessage>> {
  MessageNotifier() : super([]) {
    _initializeNotifications();
    fetchMessages();
    startFetch();
  }
  // final Shader _read;

  final StreamController<List<SmsMessage>> _messageStreamController =
      StreamController<List<SmsMessage>>();
  Stream<List<SmsMessage>> messageStream() {
    return _messageStreamController.stream;
  }

  DateTime? lastFetchedMessageTime;

  Future<void> _initializeNotifications() async {
    await NotificationService.initializeNotifications();
  }

  Future<void> _showNotification(String sender, String message) async {
    await NotificationService.showNotification(sender, message);
  }

  void startFetch() {
    Timer.periodic(const Duration(seconds: 30), (_) {
      // _messageStreamController.add(state);
      fetchMessages();
    });
  }
  
  Map<String, List<SmsMessage>> groupMessagesByHours(
      List<SmsMessage> messages) {
    final groupedMessages = <String, List<SmsMessage>>{};
    final now = DateTime.now();

    for (final message in messages) {
      final difference = now.difference(message.date!);

      if (difference.inDays < 1) {
        final hoursDifference = difference.inHours;
        final category = '$hoursDifference hours ago';
        groupedMessages[category] ??= [];
        groupedMessages[category]!.add(message);
      } else {
        groupedMessages['1 day(s) ago'] ??= [];
        groupedMessages['1 day(s) ago']!.add(message);
      }
    }

    return groupedMessages;
  }

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
          // condition to return the sms that is inside 1 day
          return difference.inDays <= 1;
        }).toList();
        debugPrint('SMS inbox messages: ${filteredMessages.length}');
        final newMessages = filteredMessages
            .where((message) => !state.any(
                      (existingmessage) => existingmessage.id == message.id,
                    )
                // condition to check the duplicate by giving them id comparision
                // message.date!.isAfter(lastFetchedMessageTime ?? DateTime(0))
                )
            .toList();
        if (newMessages.isNotEmpty) {
          _showNewMessageNotifications(newMessages);
          state = [
            ...newMessages.toList(),
            ...state,
          ];
          _messageStreamController.add(state);
          lastFetchedMessageTime = newMessages.first.date;
        }
        // state = filteredMessages;
        // _messageStreamController.add(filteredMessages);
        // _showNewMessageNotifications(filteredMessages);

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

  // show notification for new message fetched
  Future<void> _showNewMessageNotifications(List<SmsMessage> messages) async {
    for (final message in messages) {
      final sender = message.address;
      final smsText = message.body;
      await _showNotification(sender!, smsText!);
    }
  }

  @override
  void dispose() {
    _messageStreamController.close();
    super.dispose();
  }
}
