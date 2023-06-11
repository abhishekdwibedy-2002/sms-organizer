import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smstracker/widgets/groupby_bottomsheet.dart';
import 'package:smstracker/widgets/message_listview.dart';
import 'package:smstracker/providers/message_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void showGroupByOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return AnimatedContainer(
          duration: const Duration(
            milliseconds: 600,
          ),
          curve: Curves.easeInOut,
          height: MediaQuery.of(context).size.height * 0.6,
          child: const GroupByBottomSheet(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> refreshMessages() async {
      await ref.read(messageNotifierProvider).fetchMessages();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SMS Organizer',
          style: TextStyle(
            fontSize: 22,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () => showGroupByOptions(context),
            icon: const Icon(Icons.filter_list_sharp),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshMessages,
        child: Builder(
          builder: (context) {
            final smsMessages = ref.watch(messageProvider);
            return smsMessages.when(
              data: (sms) {
                final groupedMessages =
                    ref.read(messageNotifierProvider).groupMessagesByHours(sms);

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: groupedMessages.length,
                  itemBuilder: (context, index) {
                    final entry = groupedMessages.entries.elementAt(index);
                    final hourDiff = entry.key;
                    final messages = entry.value;
                    return Column(
                      children: [
                        Text(hourDiff),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return MessageListView(message: message);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              error: (error, stackTrace) => Text(
                error.toString(),
              ),
              loading: () => Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary),
              ),
            );
          },
        ),
      ),
    );
  }

  // groupMessagesByHours(List<SmsMessage> sms) {}
}
