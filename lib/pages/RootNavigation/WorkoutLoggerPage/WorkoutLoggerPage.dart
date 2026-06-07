import 'package:flutter/material.dart';
import 'package:gravlift_workout_tracker_app/WorkoutDataManager%20(changeNotifier)/WorkoutDataManager.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/OngoingWSDialogs.dart';
import 'package:gravlift_workout_tracker_app/pages/templates/widgetsTemplates.dart';
import 'package:provider/provider.dart';
import 'OngoingWorkoutPage.dart';

class WorkoutLoggerPage extends StatefulWidget {
  const WorkoutLoggerPage({super.key});

  @override
  State<StatefulWidget> createState() => _WorkoutLoggerPageState();
}

class _WorkoutLoggerPageState extends State<WorkoutLoggerPage> {
  // variable to either show routines or create a routine page
  bool hasSavedRoutines = false;


  @override
  Widget build(BuildContext context) {
    WorkoutDataManager manager = Provider.of<WorkoutDataManager>(context, listen: false);


    return Scaffold(
      appBar: AppBar(
        title: gravLiftText(text: "Log your workout", size: 26),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              gravLiftText(text: "Empty Workout", size: 22),
              const SizedBox(height: 15),

              // Empty workout button - made by me
              ListTile(
                leading: Icon(Icons.add_circle_outline_outlined, color: Colors.deepPurpleAccent, size: 30,),
                title: gravLiftText(text: "Start Empty Workout", size: 19, color: Colors.deepPurpleAccent),
                subtitle: Text(
                  "Select exercises and quickly start a workout.\n",
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                trailing: Icon(Icons.keyboard_arrow_right_outlined, color: Colors.deepPurpleAccent, size: 40,),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
                  side: BorderSide(color: Colors.deepPurpleAccent, width: 0.8)
                ),
                tileColor: Colors.grey.withValues(alpha: 0.1), //same as withOpacity


                onTap: ()  {
                  if(manager.workoutSession == null) { // when pressing this if session is active, dialog box and if yes scrap current ws and start another one
                   Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OngoingWorkoutPage()
                        )
                    );
                  }
                  else {
                    gravLiftReplaceWorkoutSession(context);
                  }
                },

              ),

              const SizedBox(height: 40),
              gravLiftText(text: "Routines", size: 22),
              const SizedBox(height: 15),

              // ROUTINES
              if (hasSavedRoutines == false)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 40),
                      const SizedBox(height: 15),
                      Text(
                        "A 'Create Routine' button will be implemented here if no saved routines are found in the user's profile database. Otherwise, your saved routines will be displayed in this section.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[400], fontSize: 14, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                )
              else
              // Qui andrà il builder per le routine salvate
                const Text("List of saved routines will be here."),
            ],
          ),
        ),
      ),
    );
  }
}
