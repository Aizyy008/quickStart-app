import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../models/self_made_walk.dart';
import '../../../movements/map/widgets/warn_dialog.dart';
import 'map_self_made_walk.dart';

class SelfMadeWalksWidget extends StatelessWidget {
  const SelfMadeWalksWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample data for walks (this should ideally come from a controller or an API)
    final walks = <SelfMadeWalk>[
      SelfMadeWalk(
        id: 1,
        creatorId: '101',
        title: 'Walk near COMSATS Vehari - Park Road',
        createdAt: DateTime.now().subtract(Duration(hours: 3)),
        endedAt: DateTime.now().subtract(Duration(hours: 2)),
        initialPosition: LatLng(30.0438, 72.6534), // Near COMSATS Vehari
        destinationPosition: LatLng(30.0402, 72.6555), // Nearby park area
        coordinates: [
          LatLng(30.0438, 72.6534),
          LatLng(30.0415, 72.6540),
          LatLng(30.0402, 72.6555),
        ],
      ),
      SelfMadeWalk(
        id: 2,
        creatorId: '102',
        title: 'Walk along the University Road',
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        endedAt: DateTime.now().subtract(Duration(hours: 1, minutes: 30)),
        initialPosition: LatLng(30.0425, 72.6500), // COMSATS main entrance
        destinationPosition: LatLng(30.0388, 72.6551), // Near the university hostel
        coordinates: [
          LatLng(30.0425, 72.6500),
          LatLng(30.0410, 72.6520),
          LatLng(30.0388, 72.6551),
        ],
      ),
      SelfMadeWalk(
        id: 3,
        creatorId: '103',
        title: 'COMSATS to City Center Walk',
        createdAt: DateTime.now().subtract(Duration(hours: 4)),
        endedAt: DateTime.now().subtract(Duration(hours: 3, minutes: 30)),
        initialPosition: LatLng(30.0430, 72.6490), // Near COMSATS Vehari
        destinationPosition: LatLng(30.0465, 72.6405), // City Center Vehari
        coordinates: [
          LatLng(30.0430, 72.6490),
          LatLng(30.0445, 72.6460),
          LatLng(30.0465, 72.6405),
        ],
      ),
      SelfMadeWalk(
        id: 4,
        creatorId: '104',
        title: 'Walk to College Road',
        createdAt: DateTime.now().subtract(Duration(hours: 5)),
        endedAt: DateTime.now().subtract(Duration(hours: 4, minutes: 30)),
        initialPosition: LatLng(30.0395, 72.6545), // Near COMSATS entrance
        destinationPosition: LatLng(30.0370, 72.6585), // College Road
        coordinates: [
          LatLng(30.0395, 72.6545),
          LatLng(30.0380, 72.6560),
          LatLng(30.0370, 72.6585),
        ],
      ),
      SelfMadeWalk(
        id: 5,
        creatorId: '105',
        title: 'Evening Stroll - COMSATS Campus',
        createdAt: DateTime.now().subtract(Duration(hours: 6)),
        endedAt: DateTime.now().subtract(Duration(hours: 5, minutes: 30)),
        initialPosition: LatLng(30.0450, 72.6510), // COMSATS Campus Entrance
        destinationPosition: LatLng(30.0420, 72.6540), // Near cafeteria
        coordinates: [
          LatLng(30.0450, 72.6510),
          LatLng(30.0435, 72.6525),
          LatLng(30.0420, 72.6540),
        ],
      ),
    ];

    return Column(
      children: [
        _buildHeader(walks),
        _buildWalksList(walks, context),
      ],
    );
  }

  Widget _buildHeader(List<SelfMadeWalk> walks) {
    return Row(
      children: [
        Text(
          "Self-made Walks",
          style: TextStyle(fontSize: 18.sp, color: Colors.grey.shade700, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        if (walks.isNotEmpty)
          Text(
            walks.length.toString(),
            style: TextStyle(fontSize: 18.sp, color: Colors.blue, fontWeight: FontWeight.w700),
          ),
        if (walks.isNotEmpty) Icon(Icons.travel_explore, size: 22.sp, color: Colors.blue),
      ],
    );
  }

  Widget _buildWalksList(List<SelfMadeWalk> walks, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.h),
      height: walks.isNotEmpty ? 190.h : null,
      child: walks.isEmpty
          ? _buildNoWalksMessage()
          : ListView.builder(
        itemCount: walks.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final walk = walks[index];
          return _buildWalkCard(walk, context);
        },
      ),
    );
  }

  Widget _buildNoWalksMessage() {
    return Padding(
      padding: EdgeInsets.all(18.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, size: 30.sp, color: Colors.blue),
          SizedBox(height: 20),
          Text("No walks saved yet, Click start walking below", textAlign: TextAlign.center, style: TextStyle(fontSize: 15.sp)),
        ],
      ),
    );
  }

  Widget _buildWalkCard(SelfMadeWalk walk, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.grey)],
        borderRadius: BorderRadius.circular(8.r),
        image: const DecorationImage(image: AssetImage("assets/images/map.jpeg"), fit: BoxFit.cover),
      ),
      width: 190.w,
      margin: EdgeInsets.only(right: 15.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.r, horizontal: 15.w),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(8.r)),
        child: Column(
          children: [
            _buildWalkTime(walk),
            _buildWalkTitle(walk),
            _buildActionButtons(walk, context),
          ],
        ),
      ),
    );
  }

  Widget _buildWalkTime(SelfMadeWalk walk) {
    return Container(
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.8), borderRadius: BorderRadius.circular(12.r), boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 50, offset: Offset(-2, -2))]),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.5.h),
      child: Text(timeago.format(walk.createdAt), style: TextStyle(fontSize: 12.sp, color: Colors.white)),
    );
  }

  Widget _buildWalkTitle(SelfMadeWalk walk) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        walk.title,
        textAlign: TextAlign.center,
        maxLines: 2,
        style: TextStyle(color: Colors.white, fontSize: 16.sp, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildActionButtons(SelfMadeWalk walk, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            Map<String, LatLng> points = {
              "origin": walk.initialPosition,
              "destination": walk.destinationPosition,
            };
            // Navigate to the map page (Dummy example)
            Navigator.push(context, MaterialPageRoute(builder: (_) => SelfMadeWalkMap(points: points, walk: walk, mode: SelfMadeWalkMapMode.idle, startedAt: DateTime.now())));
          },
          style: ElevatedButton.styleFrom(minimumSize: Size.zero, padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 7.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r))),
          child: const Text("View Travel", style: TextStyle(
            color: Colors.white
          ),),
        ),
        ElevatedButton(
          onPressed: () async {
            final leave = await showDialog<bool>(
              context: context,
              barrierColor: Colors.black26,
              builder: (context) => const WarnDialogWidget(
                title: "Delete Travel",
                subtitle: "Are you sure do you want to delete this travel?",
                okButtonText: "Delete",
              ),
            );
            if (leave == true) {
              // Remove the walk from the list
              // In a real app, this would be done by updating state or via a controller.
            }
          },
          style: ElevatedButton.styleFrom(minimumSize: Size.zero, padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r))),
          child: Icon(Icons.delete, size: 22.sp, color: Colors.white,),
        ),
      ],
    );
  }
}
