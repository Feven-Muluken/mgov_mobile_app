import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationMapPage extends StatefulWidget {
  final String locationName;
  final double latitude;
  final double longitude;
  final String? address;

  const LocationMapPage({
    super.key,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  @override
  State<LocationMapPage> createState() => _LocationMapPageState();
}

class _LocationMapPageState extends State<LocationMapPage> {
  GoogleMapController? mapController;
  late LatLng _location;

  @override
  void initState() {
    super.initState();
    _location = LatLng(widget.latitude, widget.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.locationName,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: _location,
          zoom: 15.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        markers: {
          Marker(
            markerId: MarkerId(widget.locationName),
            position: _location,
            infoWindow: InfoWindow(
              title: widget.locationName,
              snippet: widget.address ?? '${widget.latitude}, ${widget.longitude}',
            ),
          ),
        },
        zoomControlsEnabled: true,
        mapToolbarEnabled: false,
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}





