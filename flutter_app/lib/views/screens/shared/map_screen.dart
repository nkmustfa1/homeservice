import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapScreen extends StatefulWidget {
  final Function(String, String) onLocationSelected;
  const MapScreen({super.key, required this.onLocationSelected});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  //  الموقع على صنعاء
  final LatLng _initialLocation = LatLng(15.3694, 44.1910);
  LatLng? _selectedLocation;
  final TextEditingController _searchController = TextEditingController();
  final Set<Marker> _markers = {};
  List<Map<String, dynamic>> _searchSuggestions = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _searchLocation() async {
    if (_searchController.text.isNotEmpty) {
      try {
        List<Location> locations =
            await locationFromAddress(_searchController.text);
        final List<Map<String, dynamic>> suggestions = [];

        for (var loc in locations) {
          final address =
              await _getAddressFromCoordinates(loc.latitude, loc.longitude);
          suggestions.add({
            'address': address,
            'latitude': loc.latitude,
            'longitude': loc.longitude,
          });
        }

        setState(() {
          _searchSuggestions = suggestions;
        });
      } catch (e) {
        setState(() {
          _searchSuggestions.clear();
        });
      }
    }
  }

  Future<String> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude, longitude,
          localeIdentifier: "ar");
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        return "${placemark.name}, ${placemark.locality}, ${placemark.country}";
      } else {
        return "غير معروف";
      }
    } catch (e) {
      return "خطأ في الحصول على العنوان";
    }
  }

  void _onSuggestionTap(Map<String, dynamic> suggestionData) {
    final lat = suggestionData['latitude'] as double;
    final lng = suggestionData['longitude'] as double;
    final address = suggestionData['address'] as String;

    setState(() {
      _selectedLocation = LatLng(lat, lng);
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId('selected_location'),
        position: _selectedLocation!,
        infoWindow: InfoWindow(title: address),
      ));
      _searchSuggestions.clear();
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));
  }

  void _selectLocation(LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId('selected_location'),
        position: _selectedLocation!,
        infoWindow: InfoWindow(title: 'الموقع المحدد'),
      ));
    });
  }

  void _confirmLocation() {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى تحديد موقع على الخريطة قبل المتابعة.')),
      );
      return;
    }

    widget.onLocationSelected(
      _searchController.text,
      "${_selectedLocation!.latitude}  ${_selectedLocation!.longitude}",
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('البحث عن موقع'),
        backgroundColor: Color(0xFF5464FD),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'أدخل اسم المنطقة أو العنوان',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              onChanged: (value) {
                _searchLocation();
              },
            ),
          ),
          if (_searchSuggestions.isNotEmpty)
            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: _searchSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestionData = _searchSuggestions[index];
                  return ListTile(
                    title: Text(suggestionData['address']),
                    onTap: () => _onSuggestionTap(suggestionData),
                  );
                },
              ),
            ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: _initialLocation, zoom: 14),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              markers: _markers,
              onTap: _selectLocation,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _confirmLocation,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Color(0xFF5464FD),
              ),
              child: Text("موافق"),
            ),
          ),
        ],
      ),
    );
  }
}
