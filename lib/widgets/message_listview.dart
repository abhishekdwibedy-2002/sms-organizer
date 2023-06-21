// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// import 'package:url_launcher/url_launcher.dart';

class MessageListView extends StatefulWidget {
  const MessageListView({
    super.key,
    required this.message,
    required this.isExpanded,
    // required this.onTapping,
  });

  final SmsMessage message;
  final bool isExpanded;
  // final VoidCallback onTapping;

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  @override
  Widget build(BuildContext context) {
    String messageBody = widget.message.body!;
    var limitMessageBody = messageBody.length <= 80
        ? widget.message.body
        : '${widget.message.body!.substring(0, 80)}...';
    String? fullMessageBody =
        widget.isExpanded ? messageBody : limitMessageBody;
    // Format the date to display only the time
    var formattedTime = _formatDateTime(widget.message.date!);
    // DateFormat.Hm().format(message.date!);
    return Stack(
      children: [
        Card(
          elevation: 5.0,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ListTile(
              onTap: () {
                String body = widget.message.body!;
                String title = widget.message.sender!;
                DateTime time = widget.message.date!;
                detailedSMS(body, title, time);
                // widget.onTapping;
              },
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${widget.message.sender}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
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
              subtitle: Text(
                widget.isExpanded ? messageBody : fullMessageBody!,
                maxLines: widget.isExpanded ? null : 2,
              ),
            ),
          ),
        ),
      ],
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

  Future<void> detailedSMS(String body, String senderName, DateTime dateTime) {
    String? otpCode = getCode(body);
    bool isOtpMessage = otpCode != null;

    // RegExp phoneRegex = RegExp(r'(\b\d{10,12}\b)');
    // makingPhoneCall(String phoneNumber) async {
    //   var url = Uri.parse('tel:$phoneNumber');
    //   if (await canLaunchUrl(url)) {
    //     await launchUrl(url);
    //   } else {
    //     throw 'Could not launch $url';
    //   }
    // }

    // RegExp link = RegExp(
    //     r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+');
    // launch(Uri link) async {
    //   if (await canLaunchUrl(link)) {
    //     await launchUrl(link);
    //   } else {
    //     throw 'Could not launch $link';
    //   }
    // }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  senderName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Text(
                DateFormat.Hm().format(dateTime),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          content: SelectableText(
            body,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isOtpMessage)
                  ElevatedButton(
                    onPressed: () {
                      _copyToClipboard(otpCode);
                      Navigator.of(context).pop();
                      _showCopiedSnackbar();
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.copy_outlined),
                        Text(otpCode),
                      ],
                    ),
                  ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String? getCode(String sms) {
    RegExp regex = RegExp(r'(\b\d{4,6}\b)');
    final Match? match = regex.firstMatch(sms);
    debugPrint(match?.group(0));
    return match?.group(0);
  }

  void _copyToClipboard(String? text) {
    if (text != null) {
      Clipboard.setData(ClipboardData(text: text));
      debugPrint('OTP Copied: $text');
    }
  }

  void _showCopiedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP copied successfully...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
