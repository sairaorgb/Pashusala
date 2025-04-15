import 'package:flutter/material.dart';
import 'package:veterinary_app/services/chatService.dart';
import 'package:veterinary_app/utils/chatText.dart';

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isCurrentUser;
  final String messageId;
  final String userId;
  final String recieverRole;

  ChatBubble(
      {super.key,
      required this.isCurrentUser,
      required this.data,
      required this.messageId,
      required this.userId,
      required this.recieverRole});

  void _showOptions(BuildContext context, String messageId, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  Icons.flag,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                title: ChatText(
                  text: 'report',
                  size: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _reportMessage(context, messageId, userId);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.block,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                title: ChatText(
                  text: 'block user',
                  size: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _blockuser(context, userId);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(
                  color:
                      Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                title: ChatText(
                  text: 'close',
                  size: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                onTap: () => Navigator.pop(context),
              )
            ],
          ),
        );
      },
    );
  }

  void _reportMessage(BuildContext context, String messageId, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ChatText(
          text: 'report message',
          size: 15,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.surface,
        ),
        content: ChatText(
          text: 'are you sure you want to report this message?',
          size: 15,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.surface,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ChatText(
              text: 'no',
              size: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          TextButton(
            onPressed: () {
              ChatService().reportUser(messageId, userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: ChatText(
                    text: 'message reported',
                    size: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              );
            },
            child: ChatText(
              text: 'yes, report',
              size: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.surface,
            ),
          )
        ],
      ),
    );
  }

  void _blockuser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ChatText(
          text: 'block user',
          size: 15,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.surface,
        ),
        content: ChatText(
          text: 'are you sure you want to block this user?',
          size: 15,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.surface,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ChatText(
              text: 'no',
              size: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          TextButton(
            onPressed: () {
              ChatService().blockUser(userId);
              Navigator.pop(context); // FYI: Dismiss the dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: ChatText(
                    text: 'user blocked',
                    size: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              );
              Navigator.pop(context); // FYI: Dismiss the page
            },
            child: ChatText(
              text: 'yes, block',
              size: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.surface,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (!isCurrentUser) {
          _showOptions(context, messageId, userId);
        }
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: (recieverRole == "doctor")
              ? Colors.green.shade900
              : Colors.blue.shade900,
        ),
        margin: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            (data["message"] != '')
                ? ChatText(
                    text: data["message"],
                    size: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade50,
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                          height: 300,
                          child: Image.network(
                            data["imagePath"],
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return CircularProgressIndicator();
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.error);
                            },
                          )),
                    ),
                  ),
            // const SizedBox(height: 2.0),
            // ChatText(
            //   text: "",
            //   size: 10,
            //   fontWeight: FontWeight.w300,
            //   color: isCurrentUser
            //       ? Theme.of(context).colorScheme.tertiaryContainer
            //       : Theme.of(context).colorScheme.inversePrimary,
            // ),
          ],
        ),
      ),
    );
  }
}
