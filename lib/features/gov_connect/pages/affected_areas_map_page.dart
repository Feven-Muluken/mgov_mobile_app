import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Initial location centered on Bahir Dar (approximate coordinates based on the image)
const LatLng _kBahirDarCenter = LatLng(11.5937, 37.3917);

// --- Affected Areas Map Widget ---

class AffectedAreasMapPage extends StatefulWidget {
  const AffectedAreasMapPage({super.key});

  @override
  State<AffectedAreasMapPage> createState() => _AffectedAreasMapPageState();
}

class _AffectedAreasMapPageState extends State<AffectedAreasMapPage> {
  final Set<Circle> _affectedCircles = {};
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    _loadAffectedAreas();
  }

  // Define the circles (affected areas) based on the image
  void _loadAffectedAreas() {
    setState(() {
      _affectedCircles.add(
        Circle(
          circleId: const CircleId('highlyAffected1'),
          center: const LatLng(11.600, 37.395), // Center of the red circle 1
          radius: 400, // Radius in meters
          fillColor: Colors.red.withOpacity(0.3), // Red with transparency
          strokeColor: Colors.red,
          strokeWidth: 2,
        ),
      );
      _affectedCircles.add(
        Circle(
          circleId: const CircleId('highlyAffected2'),
          center: const LatLng(11.585, 37.408), // Center of the red circle 2
          radius: 350,
          fillColor: Colors.red.withOpacity(0.3),
          strokeColor: Colors.red,
          strokeWidth: 2,
        ),
      );
      _affectedCircles.add(
        Circle(
          circleId: const CircleId('slightlyAffected'),
          center: const LatLng(11.590, 37.388), // Center of the yellow circle
          radius: 550,
          fillColor: Colors.orange.withOpacity(0.3), // Orange/Yellow with transparency
          strokeColor: Colors.orange,
          strokeWidth: 2,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // Google Map Widget
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: const CameraPosition(
              target: _kBahirDarCenter,
              zoom: 13.5, // Zoom level to fit the affected areas
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            // The key part: adding the circles to the map
            circles: _affectedCircles,
            // To match the image style, you might want to remove UI elements
            zoomControlsEnabled: false, 
            mapToolbarEnabled: false,
          ),

          // Legend Widget (Top Overlay)
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: _buildLegend(),
          ),
        ],
      ),
    );
  }

  // --- AppBar Widget ---
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Affected Areas By Emergency',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_border, color: Colors.grey),
          onPressed: () {
            // Handle bookmark action
          },
        ),
      ],
    );
  }

  // --- Legend Widget ---
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Highly Affected
          _buildLegendItem(Colors.red, 'Highly affected'),
          const SizedBox(width: 20),
          // Slightly Affected
          _buildLegendItem(Colors.orange, 'Slightly affected'),
        ],
      ),
    );
  }

  // --- Legend Item Helper ---
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}

