import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:contacts_service/contacts_service.dart';
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
    initializeNotifications();
    fetchMessages();
    startSmsListener();
    // startFetch();
  }

  final StreamController<List<SmsMessage>> _messageStreamController =
      StreamController<List<SmsMessage>>.broadcast();
  Stream<List<SmsMessage>> messageStream() {
    return _messageStreamController.stream;
  }

  String messageSender = '';
  String sms = '';
  late Map<String, Contact> phoneToContact;

  void startSmsListener() {
    PlatformChannel().smsStream().listen((newSmsEvent) {
      fetchMessages();
      messageSender = newSmsEvent['senderName'];
      sms = newSmsEvent['messageBody'];
      _showNotification(messageSender, sms);
    });
  }

  Future<void> initializeNotifications() async {
    await NotificationService.initializeNotifications();
  }

  Future<void> _showNotification(String sender, String message) async {
    await NotificationService.showNotification(sender, message);
  }

  Future<void> refreshMessages() async {
    await fetchMessages();
  }

  void startFetch() {
    Timer.periodic(const Duration(hours: 1), (_) {
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
    final permission = await Permission.sms.status;
    final contactPermission = await Permission.contacts.status;
    if (permission.isGranted && contactPermission.isGranted) {
      try {
        final messages = await querySmsMessages();
        final contacts = await ContactsService.getContacts();
        final filteredMessages = filterMessagesWithinOneDay(messages, contacts);
        debugPrint('SMS inbox messages: ${filteredMessages.length}');
        phoneToContact = createPhoneToContactMap(contacts);
        for (var message in filteredMessages) {
          final contact = findContactForMessage(message);
          final senderName = contact?.displayName ?? message.address!;
          debugPrint(senderName);
          message.address = senderName;
        }
        state = filteredMessages;
        _messageStreamController.add(filteredMessages);
        return filteredMessages;
      } catch (error) {
        debugPrint('Error fetching messages: $error');
        rethrow;
      }
    } else {
      await requestPermissions();
      return await fetchMessages();
    }
  }

  Future<List<SmsMessage>> querySmsMessages() {
    final query = SmsQuery();
    return query.querySms(kinds: [SmsQueryKind.inbox]);
  }

  List<SmsMessage> filterMessagesWithinOneDay(
      List<SmsMessage> messages, List<Contact> contacts) {
    final now = DateTime.now();
    return messages.where((message) {
      final difference = now.difference(message.date!);
      return difference.inDays <= 1;
    }).toList();
  }

  Map<String, Contact> createPhoneToContactMap(List<Contact> contacts) {
    final phoneToContact = <String, Contact>{};
    for (var contact in contacts) {
      for (var phone in contact.phones ?? []) {
        final phoneNumber = phone.value!.replaceAll(RegExp(r'\D'), '');
        phoneToContact[phoneNumber] = contact;
      }
    }
    return phoneToContact;
  }

  Contact? findContactForMessage(SmsMessage message) {
    final phoneNumber = message.address!.replaceAll(RegExp(r'\D'), '');
    return phoneToContact[phoneNumber];
  }

  Future<void> requestPermissions() async {
    await Permission.sms.request();
    await Permission.contacts.request();
  }

  @override
  void dispose() {
    _messageStreamController.close();
    super.dispose();
  }
}
