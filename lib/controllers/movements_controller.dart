import 'dart:async';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../models/movement.dart';
import '../models/user.dart';

class MovementController extends GetxController with StateMixin<List<Movement>> {
  List<Movement> movements = RxList<Movement>([]);
  var currentMovementId = "".obs;
  List<User> currentMoveMembers = RxList<User>([]);
  List<ChatMessage> chatMessages = RxList<ChatMessage>([]);
  var currentMovingUserId = "".obs;

  // Add location services
  Location _location = Location();
  late Stream<LocationData> _locationStream;
  StreamSubscription<LocationData>? _locationSubscription;

  // Static dummy movements data with added location (Comsats Vehari coordinates)
  final dummyMovements = <Movement>[
    Movement(
      id: '1',
      title: 'Mountain Trek',
      description: 'A long hike through the mountains.',
      creator: 'John Doe',
      createdAt: DateTime.parse('2024-01-01T08:00:00Z'),
      km: 20,
      members: 5,
      role: Role.creator,
      location: LatLng(31.4629, 72.3108),  // Comsats Vehari coordinates
    ),
    Movement(
      id: '2',
      title: 'Beach Cleanup',
      description: 'A group activity to clean the beach.',
      creator: 'Jane Smith',
      createdAt: DateTime.parse('2024-02-15T09:00:00Z'),
      km: 10,
      members: 12,
      role: Role.member,
      location: LatLng( 31.4629, 72.3108),  // Comsats Vehari coordinates
    ),
    Movement(
      id: '3',
      title: 'City Cycling',
      description: 'Cycling through the city streets with friends.',
      creator: 'Alice Brown',
      createdAt: DateTime.parse('2024-03-20T10:00:00Z'),
      km: 15,
      members: 8,
      role: Role.viewer,
      location: LatLng( 31.4629,72.3108),  // Comsats Vehari coordinates
    ),
  ];


  // Start listening to location updates
  void startLocationUpdate() {
    // Check if location service is enabled
    _location.requestPermission().then((permissionStatus) {
      if (permissionStatus == PermissionStatus.granted) {
        _locationStream = _location.onLocationChanged;
        _locationSubscription = _locationStream.listen((LocationData currentLocation) {
          // You can now use currentLocation to update user's position in the movement
          print('Current location: ${currentLocation.latitude}, ${currentLocation.longitude}');
        });
      } else {
        print('Location permission denied');
      }
    });
  }

  // Stop listening to location updates
  void stopLocationUpdate() {
    _locationSubscription?.cancel();
    print('Location updates stopped');
  }

  @override
  void onInit() {
    getMovements();
    super.onInit();
  }

  getMovements() async {
    if (isClosed) return;

    // Simulating data retrieval
    await Future.delayed(Duration(seconds: 1)); // Simulating delay

    change(movements, status: RxStatus.success());
  }

  // Add a new movement (just appends to the list for now)
  addMovement(Movement movement) {
    dummyMovements.add(movement);  // Add movement to dummy list
    getMovements();  // Refresh the list
  }

  // Remove a movement by its ID (removes from the list)
  removeMovement(String id) {
    dummyMovements.removeWhere((movement) => movement.id == id);  // Remove movement by ID
    getMovements();  // Refresh the list
  }

  // Simulate user leaving a movement
  Future<bool> leaveMovement() async {
    // Assuming leaving movement is a simple update, for now we just reset the currentMovementId
    currentMovementId.value = "";
    getMovements();  // Refresh list after leaving movement
    return true;  // Simulate success
  }

  // Add a chat message
  addMessage(ChatMessage message) {
    chatMessages.add(message);  // Add message to chat list
  }

  // Mark a message as seen (updates the message in the chat list)
  void markAsSeen(ChatMessage message) {
    try {
      final index = chatMessages.indexWhere((element) =>
      element.user.id == message.user.id &&
          element.message == message.message);
      if (index != -1) {
        chatMessages[index] = message;  // Update message status
      }
    } catch (e) {
      return;
    }
  }

  @override
  void onClose() {
    // Clear all lists when the controller is closed
    currentMoveMembers.clear();
    currentMovementId.value = "";
    currentMovingUserId.value = "";
    chatMessages.clear();
    stopLocationUpdate();  // Stop location updates when controller is closed
    super.onClose();
  }
}
