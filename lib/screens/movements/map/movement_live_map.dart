import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:quickstep_app/controllers/movements_controller.dart';  // Make sure to import the controller
import 'package:quickstep_app/models/user.dart';
import 'package:quickstep_app/screens/components/warn_method.dart';
import 'package:quickstep_app/screens/movements/map/widgets/marker_custom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/movement.dart';
import 'over_map_widget.dart';
import 'widgets/circular_fab_widget.dart';

class MovementLiveMap extends StatefulWidget {
  const MovementLiveMap({
    super.key,
    required this.movement,
  });

  final Movement movement;

  @override
  State<MovementLiveMap> createState() => _MovementLiveMapState();
}

class _MovementLiveMapState extends State<MovementLiveMap> {
  GoogleMapController? mapController;
  Map<String, Marker> markers = {};
  final moveCnt = Get.find<MovementController>();
  LatLng? currentLocation;
  double zoomLevel = 18;

  // Variables for user data
  String? fullName;
  String? userId;
  String? profilePicUrl;

  @override
  void initState() {
    super.initState();
    loadUserData();  // Load the user data when the widget is initialized
    getCurrentLocation();
    moveCnt.startLocationUpdate();  // Start the location update every 20 seconds
  }

  @override
  void dispose() {
    moveCnt.stopLocationUpdate();  // Stop the location updates when the widget is disposed
    super.dispose();
  }

  // Fetch current location of the user
  getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

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

    final locationData = await location.getLocation();
    if (!mounted) return;
    setState(() {
      currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
    });

    // Listen for location updates
    location.onLocationChanged.listen((newLoc) {
      if (!mounted) return;
      setState(() {
        currentLocation = LatLng(newLoc.latitude!, newLoc.longitude!);
      });
      if (mapController != null) {
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: zoomLevel,
              target: currentLocation!,
            ),
          ),
        );
      }
    });
  }

  // Load user data from SharedPreferences
  loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullName');
      userId = prefs.getString('user_id');
      profilePicUrl = prefs.getString('profilePic');
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final leave = await warnMethod(
          context,
          title: "Leave movement",
          subtitle: "Are you sure do you want to leave this movement?",
          okButtonText: "Leave",
        );
        if (leave == true) return true;
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            if (currentLocation != null)
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: currentLocation!,
                  zoom: zoomLevel,
                ),
                compassEnabled: false,
                mapType: MapType.hybrid,
                onMapCreated: (controller) async {
                  mapController = controller;
                  // Add user marker with current location
                  await addMarker(
                    User(
                      id: userId ?? "123",
                      imgUrl: "assets/images/user.jpeg",
                      username: fullName ?? "Mohsin",
                      joinedAt: DateTime.now(),
                    ),
                    currentLocation!,
                  );
                },
                myLocationButtonEnabled: false,
                markers: markers.values.toSet(),
                onCameraMove: (position) {
                  if (!mounted) return;
                  setState(() {
                    zoomLevel = position.zoom;
                  });
                },
              ),
            if (currentLocation == null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Loading current location..."),
                  ],
                ),
              ),
            OverMapWidget(
              membersLength: widget.movement.members,
              cnt: moveCnt, // This can be replaced with actual controller logic
              onSendMessage: (message) {
                // Replace with actual message sending functionality
              },
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: mapController != null
            ? CircularFabWidget(gMapController: mapController!, id: '1',)
            : null,
      ),
    );
  }

  // Adding marker for the user
  addMarker(User user, LatLng location) async {
    var marker = await customMarker(
      MoveUser(
        user: user.id == userId // Example check for current user
            ? User(
          id: user.id,
          imgUrl: user.imgUrl,
          username: "You", // Example label for the user
          joinedAt: null,
        )
            : user,
        location: location,
      ),
    );
    if (!mounted) return;
    setState(() {
      markers[user.id] = marker;
    });
  }
}
