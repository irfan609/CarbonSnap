import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lcos/constants.dart';
import 'package:location/location.dart';
import 'package:dio/dio.dart';
import 'package:geodesy/geodesy.dart' as geo;

class Maps extends StatefulWidget {
  const Maps({Key? key}) : super(key: key);

  @override
  State<Maps> createState() => _MapsState();
}

class CustomMarker {
  String markerId;
  LatLng position;
  Color markerColor;
  String title;
  String snippet;
  String date;
  String time;
  List<String> photos;
  String description;

  CustomMarker({
    required this.markerId,
    required this.position,
    required this.markerColor,
    required this.title,
    required this.snippet,
    required this.date,
    required this.time,
    required this.photos,
    required this.description,
  });
}

class _MapsState extends State<Maps> {
  GoogleMapController? _controller;
  Location currentLocation = Location();
  final Set<Marker> _markers = {};
  late CustomMarker _selectedMarker = CustomMarker(
      markerId: 'default',
      position: LatLng(0.0, 0.0),
      markerColor: Colors.red,
      title: '',
      snippet: '',
      date: '',
      time: '',
      photos: [],
      description: '');
  bool _showLeftBar = false;
  double leftBarWidth = 0.0;
  LatLng? userLocation;
  final geo.Geodesy geodesy = geo.Geodesy();
  double calculateDistance(LatLng start, LatLng end) {
    return (geodesy.distanceBetweenTwoGeoPoints(
      geo.LatLng(start.latitude, start.longitude),
      geo.LatLng(end.latitude, end.longitude),
    ) as double);
  }

  void _onMarkerTapped(MarkerId markerId) async {
    Marker tappedMarker = _markers.firstWhere(
      (marker) => marker.markerId == markerId,
      orElse: () => Marker(markerId: MarkerId('default')),
    );

    if (tappedMarker.markerId != MarkerId('default')) {
      // Check if user location is available
      if (userLocation != null) {
        // Calculate the distance between user location and selected marker
        double distance =
            calculateDistance(userLocation!, tappedMarker.position);
        print('Distance to selected marker: $distance meters');
      }

      // Fetch additional information using markerId
      try {
        Response response = await Dio().get(
          'https://us-central1-lcos-app-2e724.cloudfunctions.net/app/marker/${tappedMarker.markerId.value}',
        );
        Map<String, dynamic> markerInfo = response.data;

        // Set selected marker and show left bar
        setState(() {
          _selectedMarker = CustomMarker(
            markerId: tappedMarker.markerId.value,
            position: LatLng(markerInfo['position']['latitude'],
                markerInfo['position']['longitude']),
            markerColor: getMarkerColor(markerInfo['category']),
            title: markerInfo['title'] ?? '',
            snippet: markerInfo['snippet'] ?? '',
            date: markerInfo['date'] ?? '',
            time: markerInfo['time'] ?? '',
            photos: List<String>.from(markerInfo['photos'] ?? []),
            description: markerInfo['description'] ?? '',
          );
          _showLeftBar = true;
          leftBarWidth = MediaQuery.of(context).size.width / 2;
        });
      } catch (error) {
        print('Error fetching marker data: $error');
      }
    }
  }

  Color getMarkerColor(int category) {
    switch (category) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.grey;
      default:
        return Colors.red; // Default color for unknown categories
    }
  }

  void _onMapTapped() {
    setState(() {
      _showLeftBar = false;
      leftBarWidth = 0.0;
    });
  }

  void addMarkers(BuildContext context) async {
    try {
      Response response = await Dio().get(
          'https://us-central1-lcos-app-2e724.cloudfunctions.net/app/marker');
      List<dynamic> markerData = response.data;

      for (var data in markerData) {
        _markers.add(Marker(
          draggable: true,
          flat: true,
          markerId: MarkerId(data['markerId']),
          position: LatLng(
            data['position']['latitude'],
            data['position']['longitude'],
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            getHueFromColor(getMarkerColor(data['category'])),
          ),
          onTap: () => _onMarkerTapped(MarkerId(data['markerId'])),
          infoWindow: InfoWindow(
            title: data['title'] ?? '', // Set title to empty string if null
            snippet:
                data['snippet'] ?? '', // Set snippet to empty string if null
          ),
        ));
      }

      setState(() {});
    } catch (error) {
      print('Error fetching marker data: $error');
    }
  }

  double getHueFromColor(Color color) {
    double hue =
        BitmapDescriptor.hueRed; // Default to red if unable to determine hue
    if (color == Colors.green) {
      hue = BitmapDescriptor.hueGreen;
    } else if (color == Colors.yellow) {
      hue = BitmapDescriptor.hueYellow;
    } else if (color == Colors.blue) {
      hue = BitmapDescriptor.hueAzure;
    } else if (color == Colors.orange) {
      hue = BitmapDescriptor.hueOrange;
    }
    return hue;
  }

  void getLocation() async {
    var location = await currentLocation.getLocation();
    setState(() {
      userLocation =
          LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0);
      _controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: userLocation!,
        zoom: 12.0,
      )));
      _markers.add(Marker(
        draggable: true,
        flat: true,
        infoWindow: const InfoWindow(title: 'Your Current Location'),
        markerId: const MarkerId('Home'),
        position: userLocation!,
        icon:
            BitmapDescriptor.defaultMarkerWithHue(getHueFromColor(Colors.red)),
      ));
    });
  }

  Widget buildLeftBar(BuildContext context) {
    String distanceText = ''; // Variable to store the distance text

    // Check if user location and selected marker position are available
    if (userLocation != null && _selectedMarker.position != null) {
      // Calculate the distance between user location and selected marker
      double distance =
          calculateDistance(userLocation!, _selectedMarker.position);
      distanceText = 'Distance: ${distance.toStringAsFixed(2)} meters';
    }

    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5.0),
            Text(
              _selectedMarker.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            SizedBox(height: 5.0),
            Text(
              '${_selectedMarker.date}',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12.0,
                  color: Colors.blue),
            ),
            Text(
              '${_selectedMarker.time}',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12.0,
                  color: Colors.blue),
            ),
            // Display distance text if available
            if (_selectedMarker.photos.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.0),
                  ..._selectedMarker.photos.map((photo) {
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Image.network(
                        photo,
                        width: double.infinity,
                      ),
                    );
                  }).toList(),
                ],
              ),
            Text(' ${_selectedMarker.description}'),
            // Add more widgets here if needed to enable scrolling
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Pass the context to addMarkers
    addMarkers(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: true,
            initialCameraPosition: const CameraPosition(
              target: LatLng(4.104928648976427, 102.10616917684835),
              zoom: 7.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            markers: _markers,
            onTap: (_) => _onMapTapped(),
          ),
          AnimatedPositioned(
            left: _showLeftBar ? 0.0 : -leftBarWidth,
            top: 0,
            bottom: 0,
            width: leftBarWidth,
            duration: Duration(milliseconds: 100),
            child: buildLeftBar(context),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        child: const Icon(
          Icons.location_searching,
          color: Colors.white,
        ),
        onPressed: () {
          getLocation();
        },
      ),
    );
  }
}
