import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/place.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
      latitude: 37.422,
      longitude: -122.084,
      address: '',
    ),
  });
  final PlaceLocation location;
  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  LatLng? _pickedLocation;
  void _selectLocation(dynamic tapPosn, LatLng posn) {
    setState(() {
      _pickedLocation = posn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Your Location'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop(_pickedLocation);
              },
              icon: const Icon(Icons.save))
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(widget.location.latitude, widget.location.longitude),
          initialZoom: 15,
          onTap: _selectLocation,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.google.com/vt/lyrs=m&hl={hl}&x={x}&y={y}&z={z}',
            additionalOptions: const {'hl': 'en'},
            subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
          ),
          if (_pickedLocation != null)
            MarkerLayer(markers: [
              Marker(
                point: _pickedLocation ??
                    LatLng(
                      widget.location.latitude,
                      widget.location.longitude,
                    ),
                child: const Icon(
                  Icons.location_on,
                  size: 25,
                  color: Colors.red,
                ),
              )
            ])
        ],
      ),
    );
  }
}
