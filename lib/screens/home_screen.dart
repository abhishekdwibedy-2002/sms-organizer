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
    final messages = ref.watch(messageProvider);

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
        onRefresh: () => ref.refresh(messageProvider.future),
        child: messages.when(
          data: (sms) {
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: sms.length,
              itemBuilder: (context, index) {
                final message = sms[index];
                return MessageListView(message: message);
              },
            );
          },
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
