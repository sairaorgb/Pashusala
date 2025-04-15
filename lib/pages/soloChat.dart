// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:veterinary_app/pages/pagenav.dart';
import 'package:veterinary_app/services/chatService.dart';
import 'package:veterinary_app/utils/chatBubble.dart';
import 'package:veterinary_app/utils/chatTextField.dart';
import 'dart:io';

class ChatPage extends StatefulWidget {
  final String receiverName;
  final String receiverEmail;
  final String receiverID;
  final String switchValue;
  final String recieverRole;

  ChatPage({
    super.key,
    required this.receiverName,
    required this.receiverEmail,
    required this.receiverID,
    required this.switchValue,
    required this.recieverRole,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();

  FocusNode chatFocusNode = FocusNode();
  File? _image;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _openCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() async {
        _image = File(image.path);
        _imageBytes = await image.readAsBytes();
        var imageUrl = await uploadImage(_imageBytes!,
            'chat_images/${DateTime.now().millisecondsSinceEpoch}.png');
        sendMessage(imagePath: imageUrl);
        print("competed sed messfe");
      });
    }
  }

  Future<String> uploadImage(Uint8List imageBytes, String imagePath) async {
    try {
      // Get reference to the storage location
      final storageRef = FirebaseStorage.instance.ref().child(imagePath);

      // Upload the image
      final uploadTask = storageRef.putData(imageBytes);

      // Wait for the upload to complete
      final snapshot = await uploadTask.whenComplete(() => null);

      // Get the download URL after upload is complete
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Return the download URL
      return downloadUrl;
    } catch (e) {
      // Handle any errors
      print('Error uploading image: $e');
      throw e; // Optionally rethrow the error
    }
  }

  // Future<String?> uploadImage(Uint8List imageBytes, String imagePath) async {
  //   print('🧪 Starting testStorageConnectionVerbose');

  //   await FirebaseAppCheck.instance.getToken(true).then((token) {
  //     print("🔥 App Check Token: $token");
  //   }).catchError((error) {
  //     print("❌ Failed to get App Check token: $error");
  //   });

  //   try {
  //     const bucketName = 'veternary-cfcc8.firebasestorage.app';
  //     final storage = FirebaseStorage.instanceFor(bucket: bucketName);
  //     final rootRef = storage.ref();

  //     try {
  //       final url =
  //           await FirebaseStorage.instance.ref("cat.jpeg").getDownloadURL();
  //       print("✅ URL: $url");
  //     } catch (e) {
  //       print("❌ Error: $e");
  //     }

  //     // Try downloading a specific file
  //     final catRef = storage.ref().child('cat.jpeg');
  //     print('📥 Trying to get download URL for cat.jpeg...');
  //     final downloadUrl = await catRef.getDownloadURL();
  //     print('✅ Download URL: $downloadUrl');
  //   } on FirebaseException catch (e) {
  //     print('❌ FirebaseException');
  //     print('🔸 Code: ${e.code}');
  //     print('🔸 Message: ${e.message}');
  //   } catch (e, stackTrace) {
  //     print('💥 Unexpected Error: $e');
  //     print(stackTrace);
  //   }
  // }

  @override
  void initState() {
    super.initState();

    chatFocusNode.addListener(() {
      if (chatFocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });

    Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    chatFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  void sendMessage({String? imagePath}) async {
    print("reachd send msg");
    if (imagePath != null) {
      print("reched condition loop");
      await _chatService.sendMessage(widget.receiverID, '',
          imagePath: imagePath);
      print("passed aeait");
      _image = null;
      _imageBytes = null;
    }

    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);

      _messageController.clear();
    }
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.tertiary),
          leading: Padding(
            padding: const EdgeInsets.all(6.0),
            child: CircleAvatar(
              backgroundImage: (widget.recieverRole == "doctor")
                  ? AssetImage('assets/images/greenuserdp.jpg')
                  : AssetImage('assets/images/userdp.jpg'),
              maxRadius: 9, // Adjust the radius as needed
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => pageNav(
                        CurrentPageIndex: 3,
                        SwitchValue:
                            (widget.switchValue == "true") ? true : false,
                        CurrentUserId: FirebaseAuth.instance.currentUser!.uid)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.logout_outlined,
                  color: (widget.recieverRole == "doctor")
                      ? Colors.green.shade900
                      : Colors.blue.shade900,
                ),
              ),
            )
          ],
          backgroundColor: Colors.blue.shade50,
          title: Text(
            widget.receiverName,
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: (widget.recieverRole == "doctor")
                    ? Colors.green.shade900
                    : Colors.blue.shade900,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // Full screen background image
              Positioned.fill(
                child: (widget.recieverRole == "doctor")
                    ? Image.asset(
                        'assets/images/doctorchatbg.jpeg',
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/chatbg.jpg',
                        fit: BoxFit.cover,
                      ),
              ),
              // Main content column
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Optional app bar or header space
                    SizedBox(height: kToolbarHeight),

                    // Message list with flexible space
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        child:
                            _buildMessageList(), // Note the method name without asterisk
                      ),
                    ),

                    // User input area
                    Container(
                      margin: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 30.0),
                      child: _buildUserInput(
                          context), // Note the method name without asterisk
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildMessageList() {
    // String senderId = _authService.getCurrentUser()!.uid;
    String senderId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("error");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("loading...");
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 0.0),
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(context, doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(BuildContext context, DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser =
        data["senderID"] == FirebaseAuth.instance.currentUser?.uid;

    return Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        ChatBubble(
          isCurrentUser: isCurrentUser,
          data: data,
          messageId: doc.id,
          userId: data["senderID"],
          recieverRole: widget.recieverRole,
        ),
      ],
    );
  }

  Widget _buildUserInput(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ChatTextField(
            role: widget.recieverRole,
            controller: _messageController,
            hintText: "type a message",
            obscureText: false,
            focusNode: chatFocusNode,
          ),
        ),
        const SizedBox(width: 5.0),
        CircleAvatar(
          backgroundColor: (widget.recieverRole == "doctor")
              ? Colors.green.shade100
              : Colors.blue.shade100,
          child: IconButton(
            onPressed: _openCamera,
            icon: Icon(
              Icons.camera_alt_sharp,
              color: (widget.recieverRole == "doctor")
                  ? Colors.green.shade900
                  : Colors.blue.shade900,
            ),
          ),
        ),
        CircleAvatar(
          backgroundColor: (widget.recieverRole == "doctor")
              ? Colors.green.shade100
              : Colors.blue.shade100,
          child: IconButton(
            onPressed: sendMessage,
            icon: Icon(
              Icons.arrow_upward,
              color: (widget.recieverRole == "doctor")
                  ? Colors.green.shade900
                  : Colors.blue.shade900,
            ),
          ),
        ),
      ],
    );
  }
}
