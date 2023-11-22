import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';

import '/providers/handle_user_place_provider.dart';
import '../models/place.dart';
import '../widgets/image_input.dart';
import '../widgets/location_input.dart';

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddNewPlaceScreenState();
}

class _AddNewPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final _titleController = TextEditingController();
  File? _selectedImg;
  PlaceLocation? _selectedLocation;

  Future<List> getLocationAddress(double lat, double lng) async {
    List<Placemark> placeMark = await placemarkFromCoordinates(lat, lng);
    return placeMark;
  }

  void _setPlace(double lat, double lng) async {
    final addressData = await getLocationAddress(lat, lng);

    final String street = addressData[0].street;
    final String postalcode = addressData[0].postalCode;
    final String locality = addressData[0].locality;
    final String country = addressData[0].country;
    final String address = '$street, $postalcode, $locality, $country';

    _selectedLocation = PlaceLocation(latitude: lat, longitude: lng, address: address);
  }

  void _savePlace() {
    final enteredTitle = _titleController.text;
    if (enteredTitle.isEmpty || _selectedImg == null || _selectedLocation == null) {
      return;
    }
    ref.read(handleUserPlaceProvider.notifier).addPlace(enteredTitle, _selectedImg!, _selectedLocation!);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Place"),
      ),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            TextFormField(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              decoration: InputDecoration(
                label: Text(
                  "Title",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ),
              controller: _titleController,
            ),
            const SizedBox(
              height: 15,
            ),
            ImageInput(
              onPickedImage: (File image) {
                _selectedImg = image;
              },
            ),
            const SizedBox(
              height: 15,
            ),
            LocationInput(
              selectedLocation: _setPlace,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: _savePlace,
                  //minWidth: 20,
                  color: const Color.fromARGB(140, 26, 214, 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Add Place",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
