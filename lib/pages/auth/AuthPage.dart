
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gravlift_workout_tracker_app/pages/templates/widgetsTemplates.dart';
import 'SignInPage.dart'; import 'SignUpPage.dart';

class AuthPage extends StatefulWidget{
  const AuthPage({super.key});
  @override
  State<StatefulWidget> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>{

  bool isLoggedIn = false;
  void toggleAuthMode(){
    setState(() {
      isLoggedIn = !isLoggedIn;
    });
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding( 
          padding: EdgeInsetsGeometry.symmetric(vertical: 88),
          child: Text(
            "GravLift Workout App",
            style: GoogleFonts.montserrat(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          )
        ),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/gravliftlogoneonNOBG.png", height: 230,),
            Text(
              isLoggedIn == false ? "Sign up to GravLift" : "Sign in to GravLift",
              style: GoogleFonts.aleo(
                fontSize: 39,
                fontWeight: FontWeight.bold,
              )
            ),

            Container(height: 5,),

            Text(
                isLoggedIn == false ? "Already have an account? Press Below" : "Don't have an account? Press Below",
                style: GoogleFonts.aleo(
                  fontSize: 19,
                  fontWeight: FontWeight.w200,
                )
            ),
            TextButton(
              onPressed: toggleAuthMode,
              child: Text(isLoggedIn == false ? "Sign in GravLift" : "Sign up to GravLift", style: TextStyle(fontSize: 15)),
            ),

            Container(height: 5,),

            gravLiftFabExt(
                //empty params arrow function here to return 'VoidCallBack?' to the onPressed param. Doesn't change the outcome, open up page
                onPressed: () => Navigator.push(
                    context, //Gives current widget's context which allows flutter to know the whole widget tree, and reach the Navigator widget (Above in the tree) - Ask gemini for more infos
                    MaterialPageRoute(
                    //Either build sign up or sign in page.
                    //Used .push to keep authPage in background if user made a mistake.
                      builder: (context) => isLoggedIn == false ?  SignUpPage() :  SignInPage()
                    )
                ),
                label: isLoggedIn == false ? "Sign Up" : "Sign In",
            )
          ],
        ),
      )
    );
  }

}




