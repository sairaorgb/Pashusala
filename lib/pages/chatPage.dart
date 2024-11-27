// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:veterinary_app/pages/soloChat.dart';
import 'package:veterinary_app/services/chatService.dart';
import 'package:veterinary_app/utils/chatText.dart';

class chatModule extends StatelessWidget {
  final String currentUserId;
  final String switchValue;
  chatModule(
      {super.key, required this.currentUserId, required this.switchValue});

  final ChatService _chatService = ChatService();
  @override
  Widget build(BuildContext context) {
    return _buildUserList();
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUserStreamExcludingBlocked(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.error,
                color: Theme.of(context).colorScheme.tertiary,
                size: 75,
              ),
              const SizedBox(height: 5.0),
              ChatText(
                text: 'an error ocurred',
                size: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(height: 2.0),
              ChatText(
                text: "sorry for that. please, try again",
                size: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.tertiary,
              )
            ]),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          );
        }

        if (snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mood_bad,
                  color: Theme.of(context).colorScheme.tertiary,
                  size: 75,
                ),
                const SizedBox(height: 5.0),
                ChatText(
                  text: 'no users found',
                  size: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(height: 2.0),
                ChatText(
                  text: "no users",
                  size: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.tertiary,
                )
              ],
            ),
          );
        }

        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != "") {
      return UserTile(
        userName: userData["name"],
        userEmail: userData["email"],
        userRole: userData["role"],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                switchValue: switchValue,
                receiverName: userData["name"],
                receiverEmail: userData["email"],
                receiverID: userData["uid"],
                recieverRole: userData['role'],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}

class UserTile extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userRole;
  final void Function()? onTap;

  const UserTile({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            // color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: (userRole == "doctor")
                          ? AssetImage('assets/images/greenuserdp.jpg')
                          : AssetImage('assets/images/userdp.jpg'),
                      maxRadius: 22, // Adjust the radius as needed
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChatText(
                          text: userName[0].toUpperCase() +
                              userName.substring(1).toLowerCase(),
                          size: 20,
                          fontWeight: FontWeight.w600,
                          color: (userRole == "doctor")
                              ? Colors.green.shade900
                              : Colors.blue.shade900,
                          // color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const SizedBox(height: 1.0),
                        ChatText(
                          text: userEmail,
                          size: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          // color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15.0,
                  // color: Theme.of(context).colorScheme.tertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
