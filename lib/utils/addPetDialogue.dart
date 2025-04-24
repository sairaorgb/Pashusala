// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veterinary_app/database.dart';
import 'package:veterinary_app/homePetsProvider.dart';
import 'package:veterinary_app/utils/imageProvider.dart';

class ShowPetInfoDialog extends StatefulWidget {
  final String currentUserId;
  Database db;

  ShowPetInfoDialog({
    Key? key,
    required this.currentUserId,
    required this.db,
  }) : super(key: key);

  @override
  State<ShowPetInfoDialog> createState() => _ShowPetInfoDialogState();
}

class _ShowPetInfoDialogState extends State<ShowPetInfoDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Pet Details'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: _DialogContent(
            currentUserId: widget.currentUserId,
            savePetDetailsToFirestore:
                context.read<HomepetsProvider>().savePetDetailsToFirestore,
          ),
        ),
      ),
    );
  }
}

class _DialogContent extends StatefulWidget {
  final String currentUserId;
  final Future<void> Function({
    required String petType,
    required String breed,
    required String petName,
    required int age,
    required double height,
    required double weight,
    required String userid,
  }) savePetDetailsToFirestore;

  _DialogContent({
    required this.currentUserId,
    required this.savePetDetailsToFirestore,
  });

  @override
  State<_DialogContent> createState() => _DialogContentState();
}

class _DialogContentState extends State<_DialogContent> {
  String? _selectedPetType;
  String? _selectedBreed;

  @override
  Widget build(BuildContext context) {
    final TextEditingController namecontroller = TextEditingController();
    final TextEditingController ageController = TextEditingController();
    final TextEditingController heightController = TextEditingController();
    final TextEditingController weightController = TextEditingController();

    final List<String> petTypes = ['Cat', 'Dog', 'Fish'];
    final Map<String, List<String>> petTypeToBreedsMap = {
      'Cat': ['Ragdoll', 'Persian', 'Maine coon', 'Siberian'],
      'Dog': ['Bulldog', 'Golden Retriever', 'Husky', 'Pomenarian'],
      'Fish': ['Clownfish', 'Goldfish', 'Siamese'],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                // Background color for image container
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  getImagePath(_selectedPetType ?? '', _selectedBreed ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Pet Type'),
                    value: _selectedPetType,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedPetType = value;
                        _selectedBreed =
                            null; // Reset breed when pet type changes
                      });
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
                    value: _selectedBreed,
                    onChanged: _selectedPetType != null
                        ? (String? value) {
                            setState(() {
                              _selectedBreed = value;
                            });
                          }
                        : null,
                    items: _selectedPetType != null
                        ? petTypeToBreedsMap[_selectedPetType]!
                            .map((breed) => DropdownMenuItem<String>(
                                  value: breed,
                                  child: Text(breed),
                                ))
                            .toList()
                        : null,
                    hint: Text('Select Pet Type First'),
                    disabledHint: Text('Select Pet Type First'),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        TextField(
          controller: namecontroller,
          decoration: InputDecoration(
            labelText: 'Pet Name',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
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
            labelText: 'Height (in cm)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 8),
        TextField(
          controller: weightController,
          decoration: InputDecoration(
            labelText: 'Weight (in kg)',
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
                String petType = _selectedPetType ?? '';
                String breed = _selectedBreed ?? '';
                String petName = namecontroller.text;
                int age = int.tryParse(ageController.text) ?? 0;
                double height = double.tryParse(heightController.text) ?? 0.0;
                double weight = double.tryParse(weightController.text) ?? 0.0;

                await widget.savePetDetailsToFirestore(
                  petType: petType,
                  breed: breed,
                  petName: petName,
                  age: age,
                  height: height,
                  weight: weight,
                  userid: widget.currentUserId,
                );

                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}
