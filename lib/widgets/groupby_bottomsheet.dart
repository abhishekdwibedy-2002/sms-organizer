import 'package:flutter/material.dart';

class GroupByBottomSheet extends StatelessWidget {
  const GroupByBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final groupByOptions = [
      '< 0 hours',
      '< 1 hours',
      '< 2 hours',
      '< 3 hours',
      '< 6 hours',
      '< 12 hours',
      '< 1 day ago',
    ];
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text(
              'Group SMS by',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: groupByOptions.length,
            itemBuilder: (context, index) {
              final option = groupByOptions[index];
              return ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(option),
                onTap: () => Navigator.of(context).pop(option),
              );
            },
          ),
        ],
      ),
    );
  }
}
