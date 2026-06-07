import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/CatalogPage/ExercisePage.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/OngoingWSDialogs.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/OngoingWorkoutPage.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/EditWorkoutPage.dart' hide tableLabelBuilder;
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/Workout%20Classes/ExerciseSet.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/Workout%20Classes/WorkoutSession.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/ProfilePage.dart';
import 'package:gravlift_workout_tracker_app/pages/templates/widgetsTemplates.dart';

//THIS PAGE IS TO VIEW A PAST WORKOUT SESSION, NOT MODIFY IT.
//TO MODIFY A PAST WORKOUT SESSION IMPLEMENT A MODIFY OPTION IN THE APPBAR WHICH THE IDEA IS:
//IT'S GOING TO CREATE A EditWorkoutPage similar to OngoingWorkoutPage WITH THAT SESSION, WITH ALL THE MODIFY-ABLE WIDGETS, THEN WHEN THE USER CONFIRMS,
//DELETE FROM DB THIS PAST SESSION AND RE-INSERT IT BUT WITH THE SAME DATE.

//ALSO WHILE USER'S MODIFYING DON'T SAVE TO SP OR MANAGER?

class HistoryInfoPage extends StatefulWidget {
  final WorkoutSession session;
  const HistoryInfoPage({super.key, required this.session});

  @override
  State<StatefulWidget> createState() => HistoryInfoPageState();
}

class HistoryInfoPageState extends State<HistoryInfoPage> {
  @override
  Widget build(BuildContext context) {
    final WorkoutSession session = widget.session;

    return Scaffold(
      appBar: AppBar(
        title: gravLiftText(text: session.name, size: 15),
        leadingWidth: 100,
        centerTitle: true,
        leading: Row(
          children: [
            //Return btn
            IconButton(
              icon: Icon(Icons.keyboard_return),
              onPressed: () {
                Navigator.pop(context);
              }, //Pop cause everything is saved anyways either local or notifier,
            ),
            //Delete workout btn
            IconButton(
              icon: Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () {
                gravLiftDeletePastSession(context, pastSession: widget.session);
              },
            ),
          ],
        ),
        actions: [
          TextButton.icon( //EDIT
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditWorkoutPage(pastSession: session, historyInfoPageContext: context))
              );
            },
            label: gravLiftText(text: "Edit", size: 18, color: Colors.deepPurpleAccent),
            icon: Icon(Icons.edit, color: Colors.deepPurpleAccent,),
          ),
        ],
      ),

      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final exercise = session.exercisesList[index];
                  return Card(
                    //ListTile for info + table for sets
                    child: Column(
                      children: [
                        ListTile(
                          //CircleAvatar + border
                          leading: Container(
                            decoration: BoxDecoration(
                              border: BoxBorder.all(
                                color: Colors.deepPurpleAccent,
                                width: 2,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 22.5,
                              foregroundImage: AssetImage(
                                "assets/images/exercisesImages/${exercise.catalog.exercise_image_filename}",
                              ),
                            ),
                          ),
                          title: gravLiftText(
                            text: exercise.catalog.exercise_name,
                            size: 18,
                            color: Colors.deepPurpleAccent,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ExercisePage(exercise: exercise.catalog),
                              ),
                            );
                          },
                        ),
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(0.4), // Set
                            1: FlexColumnWidth(1), // Weight
                            2: FlexColumnWidth(1), // Reps
                            3: FlexColumnWidth(1), // Type
                            4: FlexColumnWidth(1), // RPE
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,

                          children: [
                            // LABELS ROW
                            TableRow(
                              children: [
                                //this uses the builders inside of OngoingWorkoutPage!
                                tableLabelBuilder("SET"),
                                tableLabelBuilder("WEIGHT"),
                                tableLabelBuilder("REPS/SECONDS"),
                                tableLabelBuilder("TYPE"),
                                tableLabelBuilder("RPE"),
                              ],
                            ),

                            //A FIRST ROW IS ALWAYS PRESENT (CREATED WHEN ADDING EXERCISE DOWN BELOW)
                            ...exercise.setList.asMap().entries.map((exSet) {
                              /* Here go through the exercise's setList and convert it to map. This way the single set of the list becomes a
                              MAP with KEY: the set's index in the list and with VALUE: the set object!
                              .entries is required to map this new MAP, creating a MapEntry with index and key
                              then .map() */

                              int setNumberLabel =
                                  exSet.key + 1; //The set's index is the key!
                              int setIndex = exSet.key;
                              ExerciseSet set = exSet.value;

                              return TableRow(
                                children: [
                                  //SET'S NUMBER LABEL AS A PopMenuButton WITHOUT option to delete set
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: Text("$setNumberLabel", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),

                                  //KG
                                  _tableRowBuilder("kg", set.weight.toString()),

                                  //REPS / SECONDS - Show seconds or reps (Inline if with ? and :)
                                  (exercise.catalog.isIsometric || exercise.catalog.isCardio)
                                      ? _tableRowBuilder("secs", set.seconds.toString())
                                      : _tableRowBuilder("reps", set.reps.toString()),
                                  //TYPE
                                  _tableRowBuilder("type", set.type),
                                  //RPE
                                  _tableRowBuilder("rpe", set.rpe.toString()),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.white10, height: 1),
                itemCount: session.exercisesList.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//To write less code function, builds the rows for each set's information
Widget _tableRowBuilder(String type, String data){
  //Here there is Code that mimics the style of the dropdownButton for the "type" in OngoingWorkoutPage. Just a text
  //The code was generated by gemini but totally fixed by me, ai just saved me time styling these Texts the same way as in OngoingWorkoutPage.-

  if(type == "kg" || type == "reps"){type = "kg_or_reps";} //kg is same as reps style-wise
  else if(type == "type" || type == "rpe"){type = "type_or_rpe";}

  switch(type){

    case "kg_or_reps":
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 1.0),
            ),
          ),
          child: Text(
            data,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      );

    case "secs":
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1.0),
                  ),
                ),
                child: Text(
                  "${int.parse(data) / 60}",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                ":",
                style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1.0),
                  ),
                ),
                child: Text(
                  "${int.parse(data) - (60 * (int.parse(data) / 60))}",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      );

    case "type_or_rpe":
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 1.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );

    default:
      return SizedBox();
  }
}
