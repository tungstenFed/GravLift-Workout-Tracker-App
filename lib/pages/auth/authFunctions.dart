
import 'dart:io';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/RootNavigation.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/EditProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:gravlift_workout_tracker_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String user_id = supabaseClient.auth.currentUser!.id;

Future<String?> signUpAthlete({required String email, required String password, required BuildContext context}) async {
  try {
    if (email.isEmpty || password.isEmpty) {throw AuthException("Email or password empty");}

    AuthResponse signUpResponse = await supabaseClient.auth.signUp(password: password, email: email);

    if (signUpResponse.user == null) {throw AuthException("Error during Signup.");}


    //insert in profiles
    String userId = signUpResponse.user!.id; //'!' cause can't be null.
    await supabaseClient.from("profiles").insert({
      "user_id": userId,
      "email": email,
      //TODO: Remember to also a user and age column later on, when account is created.
    });

    //If dart arrives here it's successful, so move to boarding page - WORKS.
    Navigator.pushAndRemoveUntil( //no back arrow
        context,
        MaterialPageRoute(
            builder: (context) => EditProfilePage(justSignedUp: true)
        ),
        (route) => false //REMOVES all pages in the stack, pushAndRemoveUntil expects 3 args
    );
  } catch (e) {
    if (e is AuthException) {
      return e.message;
    }
    else if (e is SocketException) {
      return "Connection Error.";
    }
    else if (e is PostgrestException) {
      print(e);
      return "Database Error";
    }
  } //DONE: Error handling

}

Future<String?> signInAthlete(String email, String password, BuildContext context) async {

  try {
    if (email.isEmpty || password.isEmpty) {
      throw AuthException("Email or Password is empty.");
    }

    AuthResponse signInResponse = await supabaseClient.auth.signInWithPassword(
        password: password, email: email);
    if (signInResponse.user?.id == null) {
      throw AuthException("Error during signup.");
    }

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => RootNavigation(pageIndex: 0,)
        ),
        (route) => false
    );
  } catch (e) {
    if (e is AuthException) {
      return e.message;
    }
    else if (e is SocketException) {
      return "Connection Error.";
    }
    else if (e is PostgrestException) {
      return "Database Error";
    }
  } //DONE: Error handling
}