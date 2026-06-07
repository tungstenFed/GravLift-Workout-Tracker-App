import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ExerciseCatalog.dart';
import 'package:gravlift_workout_tracker_app/pages/templates/widgetsTemplates.dart';

//Bozza made my gemini, simple structure to save time.

//TODO: show workout session cards in which this exercise has been done


class ExercisePage extends StatefulWidget {
  final ExerciseCatalog exercise;
  const ExercisePage({super.key, required this.exercise});

  @override
  State<StatefulWidget> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {

  String exceptionMessage = "";
  List<String> musclesTrained = [
    // Petto
    'Chest', 'Upper Chest', 'Lower Chest',
    // Schiena
    'Back', 'Lats', 'Traps', 'Lower Back',
    // Spalle
    'Shoulders', 'Anterior Delts', 'Lateral Delts', 'Rear Delts', 'Rotator Cuff',
    // Braccia
    'Biceps', 'Triceps', 'Brachialis', 'Forearms',
    // Gambe
    'Quads', 'Hamstrings', 'Glutes', 'Calves', 'Abductors', 'Adductors',
    // Core
    'Core', 'Abs', 'Lower Abs', 'Obliques',
    // Altro
    'Full Body', 'Neck',
  ];

  void launchYoutube(String exerciseYtLink) async{
    //Required: Import url_launcher library in the pubspec.yaml, this allows to open links in flutter

    Uri url = Uri.parse(exerciseYtLink); //Creates an actual valid url

    if(await canLaunchUrl(url)){
      //Launches the url and forces the opening of the youtube app, otherwise, browser.
      launchUrl(url, mode: LaunchMode.externalApplication);

      setState(() {exceptionMessage="";});
    } else {
      setState(() {exceptionMessage="Couldn't open youtube link.";});
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 2,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.exercise.exercise_name,
            style: GoogleFonts.aleo(
              color: Colors.deepPurpleAccent,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: widget.exercise.isCustomExercise == false
                ? Image.asset('assets/images/exercisesImages/${widget.exercise.exercise_image_filename}',
                    //if image cant be loaded parameter
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.fitness_center,
                      size: 100,
                      color: Colors.grey,
                    ),
                  )
                : Image.network(widget.exercise.exercise_image_filename,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.fitness_center,
                      size: 100,
                      color: Colors.grey,
                    ),
                  )
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Tags row
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: BoxBorder.all(color: Colors.deepPurpleAccent),
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/images/tags_icons/${widget.exercise.muscle_trained.toLowerCase()}.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Testo del tag
                      gravLiftText(
                        text: widget.exercise.muscle_trained,
                        size: 20,
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),

                  gravLiftText(text: "How to perform this exercise", size: 25, color: Colors.white),
                  const SizedBox(height: 10),
                  Text( //TODO: Add a how_to for every exercise in the database
                    widget.exercise.how_to != null
                        ? widget.exercise.how_to.toString()
                        : "No description available for this exercise yet.",
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),

                  const SizedBox(height: 30),
                  // YT Button
                  Center(
                    child: Column(
                        children:[
                          ElevatedButton.icon(
                            onPressed: () {
                              launchYoutube(widget.exercise.yt_link);
                            },
                            icon: const Icon(Icons.play_circle_fill),
                            label: const Text("Watch Tutorial on Youtube"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                          ),
                          gravLiftExceptionText(exceptionMessage),
                        ]
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}