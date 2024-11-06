import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quickstep_app/controllers/movements_controller.dart';
import 'package:quickstep_app/models/movement.dart';
import 'package:quickstep_app/models/user.dart'; // Assuming User model exists
import 'package:quickstep_app/utils/colors.dart';
import 'package:quickstep_app/utils/helpers.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../models/user.dart';
import '../../widgets/app_bar_2.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final moveController = Get.find<MovementController>();

  Movement? movement;

  @override
  void initState() {
    super.initState();
    _initializeMovement();
  }

  // Separate method for initializing the movement.
  void _initializeMovement() {
    movement = moveController.movements.cast<Movement?>().firstWhere(
          (move) => moveController.currentMovementId.value == move?.id,
      orElse: () => null,
    );
  }

  // Sample list of members, remove this if you're getting it from the server
  List<Member> members = [
    Member(
      name: 'Mohsin',
      image: 'assets/images/user.jpeg', // Example URL for the image
      kmWalked: 12.5,
      role: 'Creator',
    ),
    Member(
      name: 'Ali Murtaza',
      image: 'assets/images/user2.png',
      kmWalked: 8.3,
      role: 'Active',
    ),
    Member(
      name: 'Sami',
      image: 'assets/images/user3.png',
      kmWalked: 15.2,
      role: 'Active',
    ),
    Member(
      name: 'Husnain',
      image: 'assets/images/user2.png',
      kmWalked: 6.4,
      role: 'Inactive',
    ),
  ];

  // Method to categorize users by role
  Map<String, List<Member>> categorizeUsers(List<Member> members) {
    List<Member> activeUsers = [];
    List<Member> inactiveUsers = [];
    List<Member> creators = [];

    for (var member in members) {
      if (member.role == 'Creator') {
        creators.add(member);
      } else if (member.role == 'Active') {
        activeUsers.add(member);
      } else {
        inactiveUsers.add(member);
      }
    }

    return {
      'creators': creators,
      'active': activeUsers,
      'inactive': inactiveUsers,
    };
  }

  @override
  Widget build(BuildContext context) {
    // Get the categorized users
    final usersByRole = categorizeUsers(members); // Using sample `members` here

    return Container(
      color: primary,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: primary,
            elevation: 0.0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            flexibleSpace: Hero(
              tag: "appbar-hero-custom-1",
              child: Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: const AnotherCustomAppBar(
                  title: "Members",
                ),
              ),
            ),
            toolbarHeight: 100.h,
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                // Section Header
                _buildSectionHeader("members", movement?.members.toString() ?? '0'),

                // Creator Section
                _buildRoleSection("Creator", Colors.amberAccent, usersByRole['creators']),

                // Active Section
                _buildRoleSection("Active", Colors.green.shade400, usersByRole['active']),

                // Inactive Section
                _buildRoleSection("Inactive", Colors.redAccent.shade700, usersByRole['inactive']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to build section headers
  Widget _buildSectionHeader(String title, String count) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 15.sp,
            color: primary.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          count,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        addHorizontalSpace(10),
        const Icon(Icons.group),
      ],
    );
  }

  // Method to build each role section (Creator, Active, Inactive)
  Widget _buildRoleSection(String title, Color color, List<Member>? users) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.circle,
              size: 20.sp,
              color: color,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
        addVerticalSpace(5),
        if (users != null && users.isNotEmpty)
          ...users.map((user) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _buildUserTile(user),
          )),
        if (users == null || users.isEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Text("No $title members available."),
          ),
      ],
    );
  }

  // Method to build user tile
  Widget _buildUserTile(Member member) {
    return ListTile(
      leading: CircleAvatar(
        radius: 27.r,
        backgroundColor: lightPrimary,
        child: CircleAvatar(
          radius: 22.r,
          backgroundColor: primary,
          foregroundColor: white,
          foregroundImage: AssetImage(member.image), // Changed to AssetImage
          child: Text(
            member.name[0].toUpperCase(),
          ),
        ),
      ),
      title: Text(
        member.name,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        "${member.kmWalked} km walked", // Added km walked info
        maxLines: 2,
      ),
      trailing: CircleAvatar(
        radius: 9.r,
        backgroundColor: lightPrimary,
      ),
    );
  }
}

class Member {
  final String name;
  final String image; // URL or path to the image
  final double kmWalked;
  final String role;

  Member({
    required this.name,
    required this.image,
    required this.kmWalked,
    required this.role,
  });
}
