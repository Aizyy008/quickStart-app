import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quickstep_app/auth_wrapper.dart';
import 'package:quickstep_app/screens/movements/map/movement_live_map.dart';
import 'package:quickstep_app/services/hive_service.dart';
import 'package:quickstep_app/utils/colors.dart';
import 'package:quickstep_app/utils/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'controllers/movements_controller.dart';
import 'models/movement.dart';
import 'screens/authentication/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize MovementController using Get.put()
  Get.put(MovementController());
  //Running flutter application
  runApp(const AppWidget());
}

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 850),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Quick Step Application',
          color: primary,
          theme: MyThemes.theme,
          home: child,
        );
      },
      child: WelcomeScreen(),
    );
  }
}
