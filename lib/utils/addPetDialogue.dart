// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore_for_file: prefer_const_constructors

class ShowPetInfoDialog extends StatelessWidget {
  final String currentUserId;
  final VoidCallback onPetAdded;

  const ShowPetInfoDialog({
    Key? key,
    required this.currentUserId,
    required this.onPetAdded,
  }) : super(key: key);

  // Function to save data to Firestore
  Future<void> savePetDetailsToFirestore({
    required String petType,
    required String breed,
    required int age,
    required double height,
    required double weight,
    required String userid,
  }) async {
    try {
      // Reference to your Firestore collection
      CollectionReference pets = FirebaseFirestore.instance
          .collection('users_data')
          .doc(userid)
          .collection('petsOwned');

      // Adding data
      await pets.add({
        'petType': petType,
        'breed': breed,
        'age': age,
        'height': height,
        'weight': weight,
      });

      print('Pet details saved successfully!');
    } catch (e) {
      print('Error saving pet details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Show the dialog when the button is pressed
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Enter Pet Details'),
              content: SingleChildScrollView(
                child: Container(
                  width: 400,
                  child: _DialogContent(
                    currentUserId: currentUserId,
                    onPetAdded: onPetAdded,
                    savePetDetailsToFirestore: savePetDetailsToFirestore,
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Container(
        height: 30,
        width: 140,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(6)),
        child: Center(
          child: Text(
            "Add Pet  +",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 22, color: Colors.blue),
          ),
        ),
      ),
    );
  }
}

class _DialogContent extends StatelessWidget {
  final String currentUserId;
  final VoidCallback onPetAdded;
  final Future<void> Function({
    required String petType,
    required String breed,
    required int age,
    required double height,
    required double weight,
    required String userid,
  }) savePetDetailsToFirestore;

  _DialogContent({
    required this.currentUserId,
    required this.onPetAdded,
    required this.savePetDetailsToFirestore,
  });

  @override
  Widget build(BuildContext context) {
    String? selectedPetType;
    String? selectedBreed;
    final TextEditingController ageController = TextEditingController();
    final TextEditingController heightController = TextEditingController();
    final TextEditingController weightController = TextEditingController();

    final List<String> petTypes = ['Dog', 'Cat', 'Bird', 'Fish'];
    final List<String> breeds = ['Labrador', 'Persian', 'Parrot', 'Goldfish'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/logo.png', // Replace with your image asset
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Pet Type'),
                    value: selectedPetType,
                    onChanged: (value) {
                      selectedPetType = value;
                    },
                    items: petTypes
                        .map((type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Breed'),
                    value: selectedBreed,
                    onChanged: (value) {
                      selectedBreed = value;
                    },
                    items: breeds
                        .map((breed) => DropdownMenuItem<String>(
                              value: breed,
                              child: Text(breed),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        TextField(
          controller: ageController,
          decoration: InputDecoration(
            labelText: 'Age',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 8),
        TextField(
          controller: heightController,
          decoration: InputDecoration(
            labelText: 'Height',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 8),
        TextField(
          controller: weightController,
          decoration: InputDecoration(
            labelText: 'Weight',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Collect values from text fields and dropdowns
                String petType = selectedPetType ?? '';
                String breed = selectedBreed ?? '';
                int age = int.tryParse(ageController.text) ?? 0;
                double height = double.tryParse(heightController.text) ?? 0.0;
                double weight = double.tryParse(weightController.text) ?? 0.0;

                // Save to Firebase
                await savePetDetailsToFirestore(
                  petType: petType,
                  breed: breed,
                  age: age,
                  height: height,
                  weight: weight,
                  userid: currentUserId,
                );

                // Close the dialog
                Navigator.of(context).pop();
                onPetAdded();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}
