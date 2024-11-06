import 'package:google_maps_flutter/google_maps_flutter.dart';  // For LatLng

enum Role { viewer, creator, member }

class Movement {
  String id;
  String title;
  String description;
  String creator;
  int km;
  int members;
  DateTime createdAt;
  Role role;
  LatLng? location; // Adding an optional location field (latitude, longitude)

  Movement({
    required this.id,
    required this.title,
    required this.description,
    required this.members,
    required this.creator,
    required this.createdAt,
    required this.km,
    required this.role,
    this.location, // Optional location
  });

  // Factory method to create a Movement from JSON
  factory Movement.fromJSON(dynamic json) {
    return Movement(
      id: json["_id"],
      title: json["title"],
      description: json["description"],
      members: json["actors"].length,
      creator: json["creator"],
      createdAt: DateTime.parse(json["createdAt"]),
      km: 17,  // Default km value, you can adjust as necessary
      role: Role.member, // Default role
      location: json["location"] != null
          ? LatLng(json["location"]["latitude"], json["location"]["longitude"])
          : null, // If location is available, parse it
    );
  }
}
