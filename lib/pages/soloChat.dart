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
import 'package:veterinary_app/utils/slotBoolkingDialogue.dart';
import 'package:veterinary_app/homePetsProvider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final String receiverName;

  final String receiverID;
  final String switchValue;
  final String recieverRole;

  ChatPage({
    super.key,
    required this.receiverName,
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
          actions: widget.recieverRole == "doctor"
              ? [
                  IconButton(
                    icon: Icon(Icons.more_vert,
                        color: Theme.of(context).colorScheme.tertiary),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.calendar_today),
                                title: Text('Book Appointment'),
                                onTap: () {
                                  Navigator.pop(context);
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return BookingDialog(
                                        items: [],
                                        doctorName: widget.receiverName,
                                        doctorId: widget.receiverID,
                                      );
                                    },
                                  );
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.verified_user),
                                title: Text('Schedule Pet Verification'),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => PetVerificationDialog(
                                      doctorId: widget.receiverID,
                                      doctorName: widget.receiverName,
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.pets),
                                title: Text('Accept Pet Under Doctor'),
                                onTap: () {
                                  // TODO: Implement accept pet logic
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ]
              : null,
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
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    List<String> ids = [currentUserId, widget.receiverID];
    ids.sort();
    String chatRoomId = ids.join('_');

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data?.docs ?? [];

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(context, messages[index]);
          },
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

class PetVerificationDialog extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  const PetVerificationDialog({
    Key? key,
    required this.doctorId,
    required this.doctorName,
  }) : super(key: key);

  @override
  State<PetVerificationDialog> createState() => _PetVerificationDialogState();
}

class _PetVerificationDialogState extends State<PetVerificationDialog> {
  Map<String, dynamic>? selectedPet;
  String? selectedAddressLabel;
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final pets = context.read<HomepetsProvider>().petList;
    final addresses = context.read<HomepetsProvider>().savedAddress;

    return AlertDialog(
      backgroundColor: const Color(0xFFF4F7F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(16),
      content: SizedBox(
        height: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Schedule Pet Verification",
              style: GoogleFonts.secularOne(
                fontSize: 22,
                color: const Color(0xFF9CAF88),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButton<Map<String, dynamic>>(
              value: selectedPet,
              hint: const Text("Select a Pet"),
              isExpanded: true,
              items: pets.map((item) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: item,
                  child: Text(
                    item["name"] ?? "Unnamed",
                    style: GoogleFonts.secularOne(fontSize: 19),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedPet = value);
              },
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedAddressLabel,
              hint: const Text("Select Address"),
              isExpanded: true,
              items: addresses.keys.map((label) {
                return DropdownMenuItem<String>(
                  value: label,
                  child: Text(
                    label,
                    style: GoogleFonts.secularOne(fontSize: 19),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedAddressLabel = value);
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              title: Text(
                selectedDate == null
                    ? "Select Date"
                    : DateFormat('yyyy-MM-dd').format(selectedDate!),
                style: GoogleFonts.secularOne(fontSize: 18),
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: now,
                  lastDate: now.add(Duration(days: 30)),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9CAF88),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              ),
              onPressed: (selectedPet != null &&
                      selectedAddressLabel != null &&
                      selectedDate != null)
                  ? () => _confirmVerification(context)
                  : null,
              child: const Text(
                "Confirm",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _confirmVerification(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');
      final addresses = context.read<HomepetsProvider>().savedAddress;
      final address = addresses[selectedAddressLabel]?['address'] ?? '';

      final requestData = {
        'typeOfRequest': 'pet_verification',
        'petId': selectedPet!['petId'],
        'petName': selectedPet!['name'],
        'userId': user.uid,
        'userName': user.displayName ?? 'Unknown User',
        'date': selectedDate,
        'address': address,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'animalType': selectedPet!["animalType"] ?? "Unknown",
        'breed': selectedPet!["breed"] ?? "Unknown"
      };

      await FirebaseFirestore.instance
          .collection('doctors_data')
          .doc(widget.doctorId)
          .collection('requests')
          .add(requestData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet verification request sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
