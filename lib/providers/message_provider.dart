import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smstracker/notification.dart';
import 'package:smstracker/platformchannel.dart';

final expandedIndexProvider = Provider<List<int>>((ref) => []);

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
    startSmsListener();
  }
  // final Shader _read;

  final StreamController<List<SmsMessage>> _messageStreamController =
      StreamController<List<SmsMessage>>();
  Stream<List<SmsMessage>> messageStream() {
    return _messageStreamController.stream;
  }

  DateTime? lastFetchedMessageTime;
  String messageSender = '';
  String sms = '';

  void startSmsListener() {
    PlatformChannel().smsStream().listen((newSmsEvent) {
      fetchMessages();
      messageSender = newSmsEvent['senderNumber'];
      sms = newSmsEvent['messageBody'];
      _showNotification(messageSender, sms);
    });
  }

  Future<void> _initializeNotifications() async {
    await NotificationService.initializeNotifications();
  }

  Future<void> _showNotification(String sender, String message) async {
    await NotificationService.showNotification(sender, message);
  }

  Future<void> refreshMessages() async {
    state = [];
    _messageStreamController.add(state);
    lastFetchedMessageTime = null;
    await fetchMessages();
  }

  void startFetch() {
    Timer.periodic(const Duration(seconds: 30), (_) {
      // _messageStreamController.add(state);
      fetchMessages();
    });
  }

  // function which takes a list of SmsMessage objects and
  // groups them by hours based on their timestamp.
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
        final filteredMessages = messages.where((message) {
          var now = DateTime.now(); //show recent time
          var difference = now.difference(message.date!);
          // condition to return the sms that is inside 1 day
          return difference.inDays <= 1;
        }).toList();
        debugPrint('SMS inbox messages: ${filteredMessages.length}');
        state = filteredMessages;
        _messageStreamController.add(filteredMessages);
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

  @override
  void dispose() {
    _messageStreamController.close();
    super.dispose();
  }
}
