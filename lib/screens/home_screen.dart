import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smstracker/widgets/message_listview.dart';
import 'package:smstracker/providers/message_provider.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> refreshMessages() async {
      await ref.read(messageNotifierProvider).refreshMessages();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SMS Organizer',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        
      ),
      body: LiquidPullToRefresh(
        color: Theme.of(context).colorScheme.secondaryContainer,
        showChildOpacityTransition: true,
        onRefresh: refreshMessages,
        child: Builder(
          builder: (context) {
            final smsMessages = ref.watch(messageProvider);
            return smsMessages.when(
                data: (sms) {
                  final groupedMessages = ref
                      .read(messageNotifierProvider)
                      .groupMessagesByHours(sms);
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
                              final isExpanded = ref
                                  .read(expandedIndexProvider)
                                  .contains(index);
                              return MessageListView(
                                message: message,
                                isExpanded: isExpanded,
                              );
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
                loading: () {
                  debugPrint('Loading...');
                  return Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary),
                  );
                });
          },
        ),
      ),
    );
  }
}
