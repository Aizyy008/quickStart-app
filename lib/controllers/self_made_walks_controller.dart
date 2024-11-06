import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/self_made_walk.dart';

enum StateAction { idle, loading, added, removed }

class WalksController extends GetxController {
  // Static list of walks in memory (instead of using Hive)
  List<SelfMadeWalk> walks = RxList(<SelfMadeWalk>[]);
  var currentState = StateAction.idle.obs;

  // Simulate fetching walks (static data for now)
  void getWalks() {
    // Static data of walks for demonstration
    walks = [
      SelfMadeWalk(
        id: 1,
        creatorId: 'user1',
        initialPosition: LatLng(37.7749, -122.4194),
        coordinates: [LatLng(37.7749, -122.4194), LatLng(37.7750, -122.4184)],
        destinationPosition: LatLng(37.7750, -122.4184),
        title: 'Morning Walk',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        endedAt: DateTime.now(),
      ),
      SelfMadeWalk(
        id: 2,
        creatorId: 'user2',
        initialPosition: LatLng(34.0522, -118.2437),
        coordinates: [LatLng(34.0522, -118.2437), LatLng(34.0530, -118.2430)],
        destinationPosition: LatLng(34.0530, -118.2430),
        title: 'Evening Walk',
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        endedAt: DateTime.now(),
      ),
    ];
  }

  // Add a new walk
  Future<void> addWalk(SelfMadeWalk walk) async {
    currentState.value = StateAction.loading;
    await Future.delayed(Duration(seconds: 1)); // Simulating network delay
    walks.add(walk);
    currentState.value = StateAction.added;
  }

  // Remove a walk
  Future<void> removeWalk(SelfMadeWalk walk) async {
    currentState.value = StateAction.loading;
    await Future.delayed(Duration(seconds: 1)); // Simulating network delay
    walks.removeWhere((walkA) => walkA.id == walk.id);
    currentState.value = StateAction.removed;
  }
}
