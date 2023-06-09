import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smstracker/widgets/message_listview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SmsQuery _query = SmsQuery();
  // List<SmsMessage> _messages = [];
  // late Timer _timer;
  late Stream<List<SmsMessage>> _messageStream;

  @override
  void initState() {
    // _fetchMessages();
    // _startTimer();
    _messageStream = _fetchMessages();
    super.initState();
  }

  // @override
  // void dispose() {
  //   _stopTimer();
  //   super.dispose();
  // }

// // Function To Fetch messages every 10 seconds
//   void _startTimer() {
//     const intervalDuration = Duration(seconds: 10);
//     _timer = Timer.periodic(intervalDuration, (_) {
//       if (mounted) {
//         _fetchMessages();
//       }
//     });
//   }

//
  // void _stopTimer() {
  //   if (_timer.isActive) {
  //     _timer.cancel();
  //   }
  // }

  Future<void> _refreshMessages() async {
    setState(() {});
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  Stream<List<SmsMessage>> _fetchMessages() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      var permission = await Permission.sms.status;
      if (permission.isGranted) {
        final messages = await _query.querySms(
          kinds: [
            SmsQueryKind.inbox,
          ],
        );
        final filteredMessages = messages.where((message) {
          var difference = DateTime.now().difference(message.date!);
          return difference.inHours < 24;
        }).toList();

        yield filteredMessages;
      } else {
        await Permission.sms.request();
      }
    }
    // var permission = await Permission.sms.status;
    // if (permission.isGranted) {
    //   final messages = await _query.querySms(
    //     kinds: [
    //       SmsQueryKind.inbox,
    //       // SmsQueryKind.sent,  // Include this if you want to show sent messages too
    //     ],
    //   );
    //   // Filter messages that are within the last 24 hours
    //   var now = DateTime.now(); //show recent time
    //   // gives the list of sms that is under 24 hours
    //   final filteredMessages = messages.where((message) {
    //     var difference = now.difference(message.date!);
    //     return difference.inHours < 24;
    //   }).toList();
    //   //
    //   debugPrint('SMS inbox messages: ${filteredMessages.length}');

    //   setState(() => _messages = filteredMessages);
    // } else {
    //   await Permission.sms.request();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Inbox Example'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshMessages(),
        child: StreamBuilder<List<SmsMessage>>(
          stream: _messageStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final messages = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return MessageListView(message: message);
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary),
                // Text(
                //   'No messages to show.\n Tap refresh button...',
                //   style: Theme.of(context).textTheme.headlineSmall,
                //   textAlign: TextAlign.center,
                // ),
              );
            }

            // return Container(
            //   padding: const EdgeInsets.all(10.0),
            //   child: _messages.isNotEmpty
            //       ? MessageListView(
            //           messages: _messages,
            //         )
            //       : Center(
            //           child: CircularProgressIndicator(
            //               color: Theme.of(context).colorScheme.primary),
            //           // Text(
            //           //   'No messages to show.\n Tap refresh button...',
            //           //   style: Theme.of(context).textTheme.headlineSmall,
            //           //   textAlign: TextAlign.center,
            //           // ),
            //         ),
            // );
          },
        ),
      ),
    );
  }
}
