// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:veterinary_app/services/chatService.dart';
import 'package:veterinary_app/utils/chatBubble.dart';
import 'package:veterinary_app/utils/chatTextField.dart';

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
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _openCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() async {
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
      final storageRef = FirebaseStorage.instance.ref().child(imagePath);
      final uploadTask = storageRef.putData(imageBytes);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw e; // Optionally rethrow the error
    }
  }

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
    if (imagePath != null) {
      await _chatService.sendMessage(widget.receiverID, '',
          imagePath: imagePath);
      print("passed aeait");
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
                        child: _buildMessageList(),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 30.0),
                      child: _buildUserInput(context),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildMessageList() {
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
