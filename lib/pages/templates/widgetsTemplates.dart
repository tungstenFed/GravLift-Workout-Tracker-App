import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gravlift_workout_tracker_app/WorkoutDataManager%20(changeNotifier)/WorkoutDataManager.dart';
import 'package:gravlift_workout_tracker_app/main.dart';
import 'package:gravlift_workout_tracker_app/pages/auth/authFunctions.dart';
import 'package:provider/provider.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/OngoingWorkoutPage.dart';

//idea from gemini only idea

Widget gravLiftText({required String text,required double size, Color color = Colors.white, }){
  return Text(
      text,
      style: GoogleFonts.aleo(

        fontSize: size,
        fontWeight: FontWeight.bold,
        color: color
      )
  );
}

Widget gravLiftTextField({
  required String hint,
  required IconData icon,
  // changed in ValueChanged<String>? che è lo standard per onSubmitted ( i just wanna put it default so i can call it when creating it)
  ValueChanged<String>? onSubmitted,
  ValueChanged<String>? onChanged, //gemini explained how to create a function parameter, just like the normal widgets.
  bool restrictiveTextField = false,
  TextInputType keyboardType = TextInputType.text,

  //default parameters to be changed only in bio widget
  int minLines = 1,
  int? maxLines = 1,

}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: TextField(
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,

      inputFormatters: [
        //If number with no decimal put it explicit
        if(keyboardType == TextInputType.numberWithOptions(decimal: false))
          FilteringTextInputFormatter.digitsOnly,
        //if text field restrict and allow the regexp
        if(restrictiveTextField)
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._]'))
      ],

      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black12,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      maxLines: maxLines,
      minLines: minLines,
    ),
  );
}

Widget gravLiftExceptionText(String? message){
  return Text(
    message ?? "", //?? means if its null returns ""
    style: GoogleFonts.akshar(
        color: Colors.red,
        fontWeight: FontWeight.w400,
        fontSize: 20
    ),
  );
}

Widget gravLiftFabExt({required Function() onPressed, required String label, double fontSize = 20,}) {
  //Decoration-------------------------------
  return FloatingActionButton.extended(
    onPressed: onPressed,
    heroTag: null,
    backgroundColor: Colors.deepPurpleAccent.shade400,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    // ----------------------------------------
    label: Text(
      label,
      style: GoogleFonts.aleo(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}





