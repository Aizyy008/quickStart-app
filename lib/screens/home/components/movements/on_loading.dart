import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnLoadingStories extends StatelessWidget {
  const OnLoadingStories({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      itemBuilder: ((context, index) {
        return Container(
          width: 105.w,
          margin: EdgeInsets.only(right: 10.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Add a placeholder or image loading widget
              ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: Image.asset(
                  index == 1 ? 'assets/images/map.jpeg' : index ==2 ? 'assets/images/map1.jpeg' : index ==3 ?
                  'assets/images/map2.jpeg' : index ==4 ? 'assets/images/map3.jpeg' : "assets/images/map3.jpeg", // Replace with your image asset
                  width: 100.w,
                  height: 100.w,
                  fit: BoxFit.cover,
                ),
              ),
              // Optional: Add a loading spinner or indicator over the image
              Positioned(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
