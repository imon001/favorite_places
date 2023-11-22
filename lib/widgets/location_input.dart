import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:latlong2/latlong.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:location/location.dart';

import 'package:favorite_place/models/place.dart';
import 'package:favorite_place/screens/map_screen.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.selectedLocation});

  final Function selectedLocation;
  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  late final MapController mapController;
  var _isGettingLocation = false;

  @override
  void initState() {
    mapController = MapController();
    super.initState();
  }

  Future<List> getLocationAddress(double lat, double lng) async {
    setState(() {
      _isGettingLocation = true;
    });
    List<Placemark> placeMark = await placemarkFromCoordinates(lat, lng);
    return placeMark;
  }

  Future<void> _savePlace(double lat, double lng) async {
    final addressData = await getLocationAddress(lat, lng);
    final String street = addressData[0].street;
    final String postalcode = addressData[0].postalCode;
    final String locality = addressData[0].locality;
    final String country = addressData[0].country;
    final String address = '$street, $postalcode, $locality, $country';

    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: lat,
        longitude: lng,
        address: address,
      );
      _isGettingLocation = false;
    });

    widget.selectedLocation(_pickedLocation!.latitude, _pickedLocation!.longitude);
  }

  void _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;
    if (lat == null || lng == null) {
      return;
    }
    _savePlace(lat, lng);
  }

  Future<void> _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (ctx) => const MapScreen(),
    ));
    if (pickedLocation == null) {
      return;
    }

    _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      "No location chosen",
      style: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );

    if (_pickedLocation != null) {
      previewContent = FlutterMap(
        mapController: mapController,
        options: MapOptions(
            interactiveFlags: InteractiveFlag.none,
            initialZoom: 13,
            initialCenter: LatLng(
              _pickedLocation!.latitude,
              _pickedLocation!.longitude,
            )),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.google.com/vt/lyrs=m&hl={hl}&x={x}&y={y}&z={z}',
            additionalOptions: const {'hl': 'en'},
            subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(_pickedLocation!.latitude, _pickedLocation!.longitude),
                child: const Icon(
                  Icons.location_on,
                  size: 25,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (_isGettingLocation) {
      previewContent = SizedBox(
        width: 40,
        child: LoadingIndicator(
          indicatorType: Indicator.lineSpinFadeLoader,
          colors: [Theme.of(context).colorScheme.onPrimary],
          strokeWidth: 2,
          pathBackgroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(border: Border.all(width: 1, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.5)), borderRadius: BorderRadius.circular(10)),
          height: 180,
          width: double.infinity,
          alignment: Alignment.center,
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              onPressed: _getCurrentLocation,
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  Text(
                    "Get Current Location",
                    //  overflow: TextOverflow.ellipsis,
                    //   maxLines: 1,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              onPressed: _selectOnMap,
              child: Row(
                children: [
                  Icon(
                    Icons.map,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  Text(
                    "Select On Map",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
