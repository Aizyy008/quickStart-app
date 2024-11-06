import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../controllers/movements_controller.dart';
import '../../../../models/movement.dart';
import 'movement_story_card.dart';
import 'on_loading.dart';

class FeaturedMovements extends StatefulWidget {
  const FeaturedMovements({
    Key? key,
  }) : super(key: key);

  @override
  State<FeaturedMovements> createState() => _FeaturedMovementsState();
}

class _FeaturedMovementsState extends State<FeaturedMovements> {
  final movementController = Get.put(MovementController());

  @override
  void initState() {
    // Fetch static movements from the controller
    movementController.getMovements();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150.h,
      child: movementController.obx(
            (state) {
          if (state == null || state.isEmpty) {
            // Return the loading indicator if no data is available
            return const OnLoadingStories();
          }

          // Sort movements by creation date
          final moves = List<Movement>.from(state);
          moves.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: moves.length,
            itemBuilder: ((context, index) {
              return MovementStoryCard(
                movement: moves[index],
                mounted: mounted,
              );
            }),
          );
        },
        onLoading: const OnLoadingStories(),
        onEmpty: const OnLoadingStories(),
        onError: (error) => Text("$error"),
      ),
    );
  }
}
