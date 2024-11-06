import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/helpers.dart';
import '../../../components/top_snackbar.dart';
import '../widgets/text_input_field.dart';

enum IsLoading { loading, failed, success, idle }

class CreateAccount extends StatefulWidget {
  const CreateAccount({
    Key? key,
    required this.onContinue,
  }) : super(key: key);

  final void Function() onContinue;

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String? fullName;
  String? email;
  String? password;
  String? confirmPassword;
  IsLoading _isLoading = IsLoading.idle;

  Future<void> _onCreateAccount() async {
    setState(() {
      _isLoading = IsLoading.loading;
    });

    final prefs = await SharedPreferences.getInstance();

// Save fullName
    await prefs.setString('fullName', fullName!);
    print("Full Name saved in SharedPreferences: $fullName");

// Save email
    await prefs.setString('email', email!);
    print("Email saved in SharedPreferences: $email");

// Save password
    await prefs.setString('password', password!);
    print("Password saved in SharedPreferences: $password");

    // Create a Random object
    Random random = Random();

    // Generate a random integer between 0 and 100 (inclusive)
    int randomInt = random.nextInt(101); // 0 to 100
    await prefs.setString('user_id', randomInt.toString());
    print("UserID saved in SharedPreferences: $randomInt");


    setState(() {
      _isLoading = IsLoading.success;
    });

    showMessage(
      message: "Account created for $email",
      title: "Success",
      type: MessageType.success,
    );

    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final loading = _isLoading == IsLoading.loading;

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
                      "Create Account",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    addHorizontalSpace(5),
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
                Form(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 18.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextInput("Full name", "a name", (value) {
                          setState(() => fullName = value);
                        }),
                        _buildTextInput("Email", "an email", (value) {
                          setState(() => email = value);
                        }),
                        Text(
                          "Please note that you will be asked to verify this email",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12.sp,
                          ),
                        ),
                        _buildTextInput("Password", "password", (value) {
                          setState(() => password = value);
                        }, isObscure: true),
                        _buildTextInput("Confirm password", "password again",
                                (value) {
                              setState(() => confirmPassword = value);
                            }, isObscure: true),
                        addVerticalSpace(30),
                        Center(
                          child: _buildCreateAccountButton(loading),
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

  Widget _buildTextInput(String label, String hintText, ValueChanged<String> onChanged, {bool isObscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label*".toUpperCase(),
          style: TextStyle(
            fontSize: 15.sp,
            color: primary.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        addVerticalSpace(8),
        TextInputField(
          hintText: hintText,
          obsecureText: isObscure,
          onChanged: onChanged,
        ),
        addVerticalSpace(18),
      ],
    );
  }

  Widget _buildCreateAccountButton(bool loading) {
    return Directionality(
      textDirection: loading ? TextDirection.ltr : TextDirection.rtl,
      child: ElevatedButton.icon(
        onPressed: _validateAndCreateAccount,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: lightPrimary,
          disabledForegroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 7.h),
        ),
        icon: loading
            ? LoadingAnimationWidget.inkDrop(color: Colors.white, size: 18.sp)
            : Icon(
          CupertinoIcons.arrow_right,
          color: const Color(0xFF9fcdf5),
          size: 24.sp,
        ),
        label: Text(
          loading ? " LOADING..." : "CREATE ACCOUNT",
          style: TextStyle(fontSize: 14.sp),
        ),
      ),
    );
  }

  void _validateAndCreateAccount() {
    if ([fullName, email, password, confirmPassword].any((field) => field == null || field!.isEmpty)) {
      showMessage(
        message: "All fields are required, please fill each text field below",
        title: "Validation Failed",
        type: MessageType.error,
      );
      return;
    }

    if (password != confirmPassword) {
      showMessage(
        message: "Password and confirm password must be equal",
        title: "Confirm Password",
        type: MessageType.error,
      );
      return;
    }

    _onCreateAccount();
  }
}
