import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickstep_app/screens/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:intl/intl.dart';
import '../../../controllers/auth.dart';
import '../../../models/account.dart';
import '../../../services/auth_service.dart';
import '../../../utils/colors.dart';
import '../../../utils/helpers.dart';
import '../../components/top_snackbar.dart';
import '../signup/components/create_account.dart';
import '../signup/signup_page.dart';
import 'signin_input_field.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({
    Key? key,
  }) : super(key: key);

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final auth = Get.put(AuthState());
  IsLoading _isLoading = IsLoading.idle;
  String? email;
  String? password;

  Future<void> saveAuthData(Account account) async {
    final prefs = await SharedPreferences.getInstance();

    // Get the current date and format it to 'yyyy-MM-dd'
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await prefs.setString('user_id', account.userId);
    await prefs.setString('email', account.email); // Save email
    await prefs.setString('username', account.username); // Save username
    await prefs.setString('profilePic', account.profilePic); // Save profile picture
    await prefs.setString('created_at', currentDate); // Save the current date in 'yyyy-MM-dd' format
  }


  void _sign() async {
    print("sign in method called");
    SharedPreferences prefs = await SharedPreferences.getInstance();

// Fetch values from SharedPreferences
    String? userId = prefs.getString('user_id');
    String? email = prefs.getString('email');
    String? username = prefs.getString('username');
    String? profilePic = prefs.getString('profilePic');
    String? createdAt = prefs.getString('created_at');

// Print fetched values
    print("Fetched from SharedPreferences: "
        "user_id=$userId, "
        "email=$email, "
        "username=$username, "
        "profile_pic=$profilePic, "
        "created_at=$createdAt");

    if (email == null || password == null || email!.isEmpty || password!.isEmpty) {
      showMessage(
        message: "Please enter all fields.",
        title: "Error",
      );
    }

    setState(() {
      _isLoading = IsLoading.loading;
    });
    
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString("password");

    // If email and password match what's in SharedPreferences, proceed without API call
    if (savedEmail == email && savedPassword == password) {
      final profile = await getProfileFromPrefs(email, password); // Fetch profile from SharedPreferences

      if (profile?["data"] != null) {
        showMessage(
          message: "Welcome back, $savedEmail",
          title: "Logged in successfully",
          type: MessageType.success,
        );

        setState(() {
          _isLoading = IsLoading.success;
        });
// Get the current date and format it to 'yyyy-MM-dd'
        String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        // Pass profile values to Account instance
        await saveAuthData(
          Account(
            userId: profile!["data"]["_id"] ?? "0",
            fullName: profile["data"]["fullName"],
            email: profile["data"]["email"],
            username: profile["data"]["username"],
            profilePic: profile["data"]["imgUrl"],
            createdAt: DateTime.parse(profile["data"]["created_at"] ?? currentDate),
          ),
        );

        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(onExploreMore: (){})));
        Future.delayed(
          const Duration(milliseconds: 400),
              () => auth.isSignedIn.value = true,
        );
      } else {
        // Clear SharedPreferences if profile data is missing
        showMessage(
          message: "Profile not found, please sign in again.",
          title: "Error",
        );
        await prefs.clear();
        setState(() {
          _isLoading = IsLoading.idle;
        });
      }
    }
  }


  Future<Map<String, dynamic>?> getProfileFromPrefs(String? email, String? password) async {
    // Initialize SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get saved token and user information from SharedPreferences
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');

    // If token doesn't match or no token is found, return null
    if (savedEmail == null || savedPassword == null) {
      showMessage(
        message: "Please enter the credentials.",
        title: "Error",
      );
      return null;
    }else if(savedEmail != email || savedPassword != password){
      showMessage(
        message: "Please enter the valid credentials.",
        title: "Error",
      );
      return null;
    }
    else if(savedEmail == email && savedPassword == password){
      // Return profile data from SharedPreferences if token matches
      return {
        "data": {
          "_id":prefs.getString("user_id") ?? "0",
          "fullName": prefs.getString('fullName') ?? "",
          "email": prefs.getString('email') ?? "",
          "username": prefs.getString('username') ?? "",
          "imgUrl": prefs.getString('profilePic') ?? "",
          "createdAt": prefs.getString('created_at') ?? ""
        }
      };
    }
  }



  @override
  Widget build(BuildContext context) {
    final loading = _isLoading == IsLoading.loading;
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SignInInputField(
            hintText: "Email",
            svg: "email.svg",
            onChanged: (value) {
              setState(() {
                email = value;
              });
            },
          ),
          SignInInputField(
            hintText: "Password",
            svg: "pwd.svg",
            isPwd: true,
            onChanged: (value) {
              setState(() {
                password = value;
              });
            },
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 10.h, bottom: 24.h),
            child: ElevatedButton.icon(
              onPressed: loading ? null : _sign,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: lightPrimary,
                disabledForegroundColor: white,
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
              ),
              icon: loading
                  ? LoadingAnimationWidget.inkDrop(color: white, size: 18.sp)
                  : Icon(
                CupertinoIcons.arrow_right,
                color: const Color(0xFF9fcdf5),
                size: 24.sp,
              ),
              label: Text(
                loading ? " Loading..." : "Sign In",
                style: TextStyle(
                  fontSize: 14.sp,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
