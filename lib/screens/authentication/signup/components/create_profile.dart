import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../services/auth_service.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/helpers.dart';
import '../../../components/top_snackbar.dart';
import '../widgets/radio_buttons.dart';
import '../widgets/text_input_field.dart';

class CreateProfile extends StatefulWidget {
  const CreateProfile({Key? key}) : super(key: key);

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  String? username;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  String userImagePath = "";

  File? _imageFile;


  Future<void> _pickImage(String? imageSource) async {
    final XFile? pickedFile =
    await _picker.pickImage(source: imageSource == "gallery" ? ImageSource.gallery : ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } else {
      // If no image is picked, use userImagePath if available
      if (userImagePath != null && userImagePath.isNotEmpty) {
        setState(() {
          _imageFile = File(userImagePath); // Use the existing user image path
        });
      } else {
        // If no image is selected and no user image path available
        setState(() {
          _imageFile = null; // Ensure it is null if not picked
        });
      }
    }
  }


  void _createProfile() async {
    if (username != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Save profile data to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();

// Save username
        await prefs.setString('username', username!);
        print("Username saved in SharedPreferences: $username");

// Save profilePic path
        await prefs.setString('profilePic', _imageFile!.path);
        print("Profile picture path saved in SharedPreferences: ${_imageFile!.path}");


        showMessage(
          message:
              "Account created successfully. Please sign in to your account.",
          title: "Profile Created",
          type: MessageType.success,
        );
        Navigator.pop(context);
      } catch (e) {
        onUnkownError(e);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      showMessage(
        message: "Please fill in all required fields.",
        title: "Missing Information",
        type: MessageType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Create Profile",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    addHorizontalSpace(5),
                    Icon(
                      Icons.person,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
                Form(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 18.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Username*".toUpperCase(),
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: primary.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        addVerticalSpace(8),
                        TextInputField(
                          hintText: "a username",
                          onChanged: (value) {
                            setState(() {
                              username = value;
                            });
                          },
                        ),
                        addVerticalSpace(18),
                        Text(
                          "Profile photo*".toUpperCase(),
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: primary.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        addVerticalSpace(20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CircleAvatar(
                              radius: 50.r,
                              backgroundColor: lightPrimary,
                              foregroundColor: Colors.white,
                              foregroundImage: _imageFile == null
                                  ? null
                                  : FileImage(_imageFile!),
                              child: _imageFile == null
                                  ? Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 30.sp,
                              )
                                  : null,
                            ),
                            Column(
                              children: [
                                InkWell(
                                  onTap: () => _pickImage("camera"),
                                  child: Ink(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border:
                                          Border.all(width: 2, color: primary),
                                      borderRadius: BorderRadius.circular(25.r),
                                    ),
                                    child: Text(
                                      "Choose from Camera",
                                      style: TextStyle(
                                        color: primary,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ),
                                addVerticalSpace(10.h),
                                InkWell(
                                  onTap: () => _pickImage("gallery"),
                                  child: Ink(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: primary,
                                      border:
                                          Border.all(width: 2, color: primary),
                                      borderRadius: BorderRadius.circular(25.r),
                                    ),
                                    child: Text(
                                      "Choose from Gallery",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        addVerticalSpace(20),
                        Text(
                          "Account purpose*".toUpperCase(),
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: primary.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        addVerticalSpace(10),
                        const RadioButtons(),
                        addVerticalSpace(20),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              disabledBackgroundColor: lightPrimary,
                              disabledForegroundColor: Colors.white,
                            ),
                            onPressed: _isLoading ? null : _createProfile,
                            child: _isLoading
                                ? LoadingAnimationWidget.inkDrop(
                                    color: Colors.white, size: 18.sp)
                                : Text("FINISH SIGNUP",
                                    style: TextStyle(fontSize: 14.sp)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
