import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class CurrentLocation extends StatefulWidget {
  const CurrentLocation({super.key});

  @override
  _CurrentLocationState createState() => _CurrentLocationState();
}

class _CurrentLocationState extends State<CurrentLocation> {
  LatLng? currentLocation;
  MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
    Future.delayed(Duration(seconds: 3)).then((v) {
      setState(() {
        mapController.move(currentLocation!, 13.0);
      });
    });
  }

  // Function to recenter map to current location
  void _recenterMap() {
    if (currentLocation != null) {
      mapController.move(currentLocation!, 13.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Location"),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () => mapController.move(mapController.center, mapController.zoom + 1),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () => mapController.move(mapController.center, mapController.zoom - 1),
          ),
        ],
      ),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentLocation!,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: currentLocation!,
                    builder: (ctx) => GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Container(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Latitude: ${currentLocation!.latitude}, '
                                  'Longitude: ${currentLocation!.longitude}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: Duration(seconds: 1),
                        child: Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 40.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _recenterMap,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
