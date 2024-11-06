import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/helpers.dart';
import 'components/movements/featured_walks_listview.dart';
import 'components/walks/self_made_walks_listview.dart';
import 'components/walks/start_walk_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onExploreMore});
  final VoidCallback onExploreMore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text( "Home", style: TextStyle(
            color: Colors.white
          ),),
        ),
backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hey 👋,\nExplore what's new today?",
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            const FeaturedMovements(),
            SizedBox(height: 12.h),
            Center(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: ElevatedButton.icon(
                  onPressed: onExploreMore,
                  icon: const Icon(Icons.arrow_back, color: Colors.white,),
                  label: const Text("Explore more",style: TextStyle(
                    color: Colors.white
                  ),),
                ),
              ),
            ),

            addVerticalSpace(10),
            const SelfMadeWalksWidget(),
            addVerticalSpace(10),
            const StartWalkingButton(),
          ],
        ),
      ),
    );
  }
}
