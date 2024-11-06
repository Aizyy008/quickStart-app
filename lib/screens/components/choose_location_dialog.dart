import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/movement.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';
import '../movements/map/movement_live_map.dart';

class ChooseLocationDialog extends StatefulWidget {
  const ChooseLocationDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<ChooseLocationDialog> createState() => _ChooseLocationDialogState();
}

class _ChooseLocationDialogState extends State<ChooseLocationDialog> {
  LatLng? currentLocation;
  LatLng? choosenLocation;

  Map<String, Marker> markers = {};

  void getCurrentLocation() async {
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
    setState(() {
      currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
    });

    location.onLocationChanged.listen((newLoc) {
      if (!mounted) return;
      setState(() {
        currentLocation = LatLng(
          newLoc.latitude!,
          newLoc.longitude!,
        );
      });
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 10.0,
      backgroundColor: white,
      insetPadding: EdgeInsets.symmetric(horizontal: 22.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Choose Location".toUpperCase(),
              style: TextStyle(
                fontSize: 14.5.sp,
                color: primary.withOpacity(0.8),
                fontWeight: FontWeight.w700,
              ),
            ),
            addVerticalSpace(10),
            SizedBox(
              height: 320.h,
              child: Stack(
                children: [
                  Container(
                    color: Colors.grey.shade300,
                    child: currentLocation != null
                        ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: currentLocation!,
                        zoom: 16,
                      ),
                      mapType: MapType.hybrid,
                      onMapCreated: (controller) async {
                        addMarker(
                          "current-location",
                          currentLocation!,
                          "My Current Location - Last known",
                          "If this is not your right current location close this dialog and try again",
                        );
                      },
                      onTap: (newLoc) {
                        setState(() {
                          choosenLocation = newLoc;
                        });
                        addMarker(
                          "choosen-location",
                          choosenLocation!,
                          "Choosen Location",
                          "Tap on the map where you want to go",
                        );
                      },
                      markers: markers.values.toSet(),
                    )
                        : null,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                style: const TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                cursorColor: lightPrimary,
                                decoration: InputDecoration(
                                  hintText: "Type search",
                                  fillColor: white,
                                  filled: true,
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15.w,
                                  ),
                                  suffixIcon: Material(
                                    color: Colors.transparent,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.search,
                                        size: 25.sp,
                                      ),
                                      color: primary,
                                      onPressed: () {},
                                    ),
                                  ),
                                  suffixIconConstraints:
                                  BoxConstraints(maxHeight: 40.h),
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.r),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.r),
                                    borderSide: BorderSide(
                                      width: 2,
                                      color: grey400,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.r),
                                    borderSide: const BorderSide(
                                      width: 2,
                                      color: lightPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 100.h,
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: SingleChildScrollView(
                            child: Column(
                              children:
                              <int>[].map<Widget>(buildPlaceTile).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (currentLocation != null)
              Container(
                color: lightPrimary,
                padding: EdgeInsets.all(8.r),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 25.sp,
                      color: Colors.grey.shade600,
                    ),
                    addHorizontalSpace(5),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Current location: ${currentLocation?.latitude},${currentLocation?.longitude}",
                          ),
                          if (choosenLocation != null)
                            Text(
                              "Choosen location: ${choosenLocation?.latitude},${choosenLocation?.longitude}",
                            )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            addVerticalSpace(10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      popPage(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary.withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                    ),
                    child: const Text("CANCEL", style: TextStyle(

                      color: Colors.white
                    ),),
                  ),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        print("onPressed method called");  // Check if onPressed is triggered

                        if (choosenLocation == null) {
                          print("No chosen location available");
                          return;
                        }

                        print("Chosen location: $choosenLocation");

                        Map<String, LatLng> points = {
                          "origin": currentLocation!,
                          "destination": choosenLocation!,
                        };

                        print("Origin: ${currentLocation!}");
                        print("Destination: ${choosenLocation!}");

                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String? fullName = await prefs.getString("fullName");

                        print("Full Name from SharedPreferences: $fullName");

                        // Create a new Movement object
                        Movement movement = Movement(
                          id: "123", // Example ID
                          title: "New Walk", // Title for the movement
                          description: "Movement is healthy for life",
                          creator: fullName!,  // Full name from SharedPreferences
                          km: 5, // Example distance in kilometers
                          members: 10, // Example number of members
                          createdAt: DateTime.now(), // Current time as creation date
                          role: Role.creator, // Example role, adjust accordingly
                        );

                        print("Movement object created: $movement");

                        // Navigate to MovementLiveMap and pass the Movement object
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovementLiveMap(movement: movement),
                          ),
                        );

                        print("Navigation to MovementLiveMap triggered");
                      },

                      icon: const Icon(Icons.arrow_back, color: Colors.white,),
                      label: const Text("SELECT", style: TextStyle(

                          color: Colors.white
                      ),),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  addMarker(String id, LatLng location, String title, String desc) async {
    Marker marker = Marker(
      markerId: MarkerId(id),
      position: location,
      infoWindow: InfoWindow(
        title: title,
        snippet: desc,
      ),
    );

    setState(() {
      markers[id] = marker;
    });
  }

  Widget buildPlaceTile(int item) {
    return Container(
      color: Colors.green,
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.only(bottom: 5),
      child: Text("Bruce $item"),
    );
  }
}
