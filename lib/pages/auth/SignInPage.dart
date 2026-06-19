import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gravlift_workout_tracker_app/WorkoutDataManager%20(changeNotifier)/WorkoutDataManager.dart';
import 'package:provider/provider.dart';
import 'authFunctions.dart';
import 'package:gravlift_workout_tracker_app/pages/templates/widgetsTemplates.dart';

class SignInPage extends StatefulWidget{
  SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>{
  String email = "";
  String password = "";
  bool isObscureText = true; //true means obscured.
  String? exceptionMessage;

  @override
  Widget build(BuildContext context) {
    WorkoutDataManager manager = Provider.of<WorkoutDataManager>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 80),
              child: Text(
                "GravLift Sign In",
                style: GoogleFonts.montserrat(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              )
          ),
          centerTitle: true,
        ),

        body: SingleChildScrollView(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 80),
              Image.asset("assets/images/gravliftlogoneonNOBG.png", height: 160,),
              Container(height: 10,),

              Text(
                  "Email:",
                  style: GoogleFonts.montserrat(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  )
              ),
              //---TextField Username or Email---
              Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 20,vertical: 10),
                  child: TextField(
                    onChanged: (value) => email = value,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white), // White text input
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black12, // black bg
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.deepPurpleAccent),


                      // Border when not focused
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey[800]!),
                      ),

                      // Border when focused
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 2),
                      ),
                      //adds better shape to border
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                  )
              ),


              Text(
                  "Password:",
                  style: GoogleFonts.montserrat(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  )
              ),
              //---TextField Password---
              Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 20,vertical: 10),
                  child: TextField(
                    onChanged: (value) => password = value,
                    obscureText: isObscureText == true ? true : false,
                    obscuringCharacter: "●",

                    style: const TextStyle(color: Colors.white), // White text input
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black12, // Dark background
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.deepPurpleAccent),
                      //Used to change characters visibility
                      suffixIcon: IconButton(onPressed: () => setState((){isObscureText = !isObscureText;}), icon: Icon(Icons.remove_red_eye_outlined), color: Colors.deepPurpleAccent,),

                      // Border when not focused
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey[800]!),
                      ),

                      // Border when focused
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 2),
                      ),
                      //adds better shape to border
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                  )
              ),
              Container(height: 13,),

              //---Confirm Btn--
              gravLiftFabExt(
                onPressed: () async {
                  exceptionMessage = await signInAthlete(email, password, context, manager);
                  setState(() {
                  });
                },
                label: "Confirm"
              ),
              Container(height: 10),
              gravLiftExceptionText(exceptionMessage),
            ],
          ),
        )
    );
  }
}