import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gravlift_workout_tracker_app/WorkoutDataManager%20(changeNotifier)/WorkoutDataManager.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/CatalogPage/ExerciseCatalog.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/CatalogPage/ExercisePage.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/AddExercisePage.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/OngoingWSDialogs.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/Workout%20Classes/ExerciseSet.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/Workout%20Classes/UuidGenerator.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/Workout%20Classes/WorkoutExercise.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/Workout%20Classes/WorkoutSession.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/Data%20Fetch%20Profile%20Info/ProfileInfo.dart';
import 'package:gravlift_workout_tracker_app/pages/auth/authFunctions.dart';
import 'package:gravlift_workout_tracker_app/pages/templates/TimeInputField.dart';
import 'package:gravlift_workout_tracker_app/pages/templates/widgetsTemplates.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
/*
CREATE A EditWorkoutPage similar to OngoingWorkoutPage WITH THAT SESSION, WITH ALL THE MODIFY-ABLE WIDGETS, THEN WHEN THE USER CONFIRMS,
DELETE FROM DB THIS PAST SESSION AND RE-INSERT IT BUT WITH THE SAME DATE.
ALSO WHILE USER'S MODIFYING DON'T SAVE TO SP OR MANAGER

This page gets a workoutSession object when created and builds a page similar to OngoingWorkoutPage based on it.
*/

class EditWorkoutPage extends StatefulWidget {
  final WorkoutSession pastSession;
  final BuildContext historyInfoPageContext;
  const EditWorkoutPage({super.key, required this.pastSession, required this.historyInfoPageContext});

  @override
  State<StatefulWidget> createState() => EditWorkoutPageState();
}

class EditWorkoutPageState extends State<EditWorkoutPage> {
  ProfileInfo? profileInfo;
  String? kg_or_lbs;
  ExerciseCatalog? result;
  int exercisesOrder = 1;
  SharedPreferences? sPrefs;


  @override
  void initState() {
    super.initState();
    //Fetch user preferences
    fetchData();

    //No need to save to SP or CN, if you go back, everything's discarded.

  }

  Future<ProfileInfo?> fetchData() async {
    WorkoutDataManager manager = Provider.of<WorkoutDataManager>(context, listen: false);
    profileInfo = await manager.profileInfo;
    kg_or_lbs = profileInfo!.kg_or_lbs;
    return null;
  }



  @override
  Widget build(BuildContext context) {
    //No need for manager, i've already got my session

    WorkoutSession oldSession = widget.pastSession; //Doesn't get modified
    WorkoutSession newSession = widget.pastSession; //Gets modified -> becomes new
    BuildContext historyInfoPageContext = widget.historyInfoPageContext; //get the historyInfoPage's context so i can close it once everything is edited

    return Scaffold(
      appBar: AppBar(
        title: gravLiftText(text: newSession.name, size:15),
        leadingWidth: 100,
        centerTitle: true,
        leading: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.red,
              ),
              onPressed: () {
                gravLiftDiscardEditsDialog(context);
              },
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
            child: SizedBox(
              height: 40,
              width: 80,
              child: gravLiftFabExt(
                  onPressed: () {
                    gravLiftConfirmEditSessionDialog(context, oldSession: oldSession, newSession: newSession, historyInfoPageContext: historyInfoPageContext);

                  },
                  label: "Finish",
                  fontSize: 16
              ),
            ),
          )
        ],
      ),

      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final exercise = newSession.exercisesList[index];
                  return Card(
                    //ListTile for info + table for sets
                    child: Column(
                      children: [
                        ListTile(
                          //CircleAvatar + border
                          leading: Container(
                            decoration: BoxDecoration(
                              border: BoxBorder.all(color: Colors.deepPurpleAccent, width: 2),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 22.5,
                              foregroundImage: AssetImage(
                                  "assets/images/exercisesImages/${exercise.catalog.exercise_image_filename}"),
                            ),
                          ),
                          title: gravLiftText(
                              text: exercise.catalog.exercise_name, size: 18, color: Colors.deepPurpleAccent),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ExercisePage(exercise: exercise.catalog,)
                                )
                            );
                          },
                          trailing: IconButton(
                            icon: Icon(Icons.delete_forever),
                            color: Colors.red[400],
                            onPressed: () {
                              setState(() {
                                newSession.exercisesList.remove(exercise);
                              });
                            },
                          ),
                        ),
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(0.4), // Set
                            1: FlexColumnWidth(1), // Weight
                            2: FlexColumnWidth(1), // Reps
                            3: FlexColumnWidth(1), // Type
                            4: FlexColumnWidth(1), // RPE
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,


                          children: [
                            // LABELS ROW
                            TableRow(children: [
                              tableLabelBuilder("SET"),
                              tableLabelBuilder("WEIGHT"),
                              tableLabelBuilder("REPS/SECONDS"),
                              tableLabelBuilder("TYPE"),
                              tableLabelBuilder("RPE"),
                            ]),


                            //A FIRST ROW IS ALWAYS PRESENT (CREATED WHEN ADDING EXERCISE DOWN BELOW)
                            ...exercise.setList.asMap().entries.map((exSet) {
                              /* Here go through the exercise's setList and convert it to map. This way the single set of the list becomes a
                              MAP with KEY: the set's index in the list and with VALUE: the set object!
                              .entries is required to map this new MAP, creating a MapEntry with index and key
                              then .map() */

                              int setNumberLabel = exSet.key + 1; //The set's index is the key!
                              int setIndex = exSet.key;
                              var set = exSet.value;

                              return TableRow(children: [

                                //SET'S NUMBER LABEL AS A PopMenuButton with option to delete set
                                PopupMenuButton(
                                  //Set's number
                                  icon: Text("$setNumberLabel", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
                                  //delete option
                                  itemBuilder: (BuildContext contextPopMenu) => [
                                    PopupMenuItem(
                                      child: TextButton.icon(
                                        icon: Icon(Icons.delete_forever, color: Colors.red, size: 30,),
                                        label: Text("Delete set", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        onPressed: () {
                                          if(setNumberLabel > 1){
                                            setState(() {
                                              //Fixed error, first remove controllers.
                                              exercise.setList[setIndex].weightController?.dispose();
                                              exercise.setList[setIndex].repsController?.dispose();

                                              exercise.setList.removeAt(setIndex);
                                              //Remove controllers
                                            });
                                          }
                                          Navigator.pop(contextPopMenu);
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                tableInputBuilder(profileInfo?.kg_or_lbs ?? "kg", exercise, "${exercise.id}_${setIndex}_unit", () => setState(() {}),context,setIndex),
                                tableInputBuilder("0", exercise, "${exercise.id}_${setIndex}_reps", () => setState(() {}), context,setIndex),
                                tableInputBuilder("Type", exercise, "${exercise.id}_${setIndex}_type", () => setState(() {}), context,setIndex),
                                tableInputBuilder("Rpe", exercise, "${exercise.id}_${setIndex}_rpe", () => setState(() {}), context,setIndex),
                              ]);
                            }).toList(),

                            // ADD SET ROW
                            TableRow(children: [
                              SizedBox(), // blank for weight column
                              SizedBox(),
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: SizedBox(
                                    //To control height
                                    height: 32.5,
                                    child: gravLiftFabExt(
                                        onPressed: () {
                                          setState(() {
                                            //Create a set
                                            ExerciseSet set = ExerciseSet(
                                              id: UuidGenerator.generate(),
                                              workout_exercise_id: exercise.id,
                                              user_id: user_id,
                                              type: "",
                                              rpe: 0,
                                              weightController: TextEditingController(),
                                              repsController: TextEditingController(),
                                            );
                                            exercise.addSet(set);
                                          });
                                        },
                                        label: "+",
                                        fontSize: 25),
                                  )),
                              SizedBox(), // blank for reps column
                              SizedBox(),
                            ])
                          ],
                        )
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(color: Colors.white10,height: 1,),
                itemCount: newSession.exercisesList.length ?? 0,
              ),
            ),


            //Add button //When popping, if a value is inserted in the pop as a result, it's assigned to result, ofc with an await.
            gravLiftFabExt(
                onPressed: () async {
                  var result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddExercisePage()),
                  ) as ExerciseCatalog;

                  // ignore: unnecessary_null_comparison
                  if (result != null) {
                    setState(() {
                      String id = UuidGenerator.generate(); //generate here so i pass it to its first set
                      WorkoutExercise exercise = WorkoutExercise(
                          id: id,
                          exercise_id: result.id,
                          workout_id: newSession.id,
                          user_id: user_id,
                          name: result.exercise_name,
                          order: exercisesOrder,
                          setList: [ //Add exercise with a blank setList [FIRST ROW! INDEX 0]
                            ExerciseSet(
                              id: UuidGenerator.generate(),
                              workout_exercise_id: id,
                              user_id: user_id,
                              weight: null,
                              reps: null,
                              seconds: null,
                              type: "",
                              rpe: 0,
                              weightController: TextEditingController(), //Create first set's controllers
                              repsController: TextEditingController(),
                            )
                          ],
                          catalog: result
                      );
                      newSession.exercisesList.add(exercise);
                    });
                    exercisesOrder++;
                  }
                },
                label: "Add Exercise")
          ],
        ),
      ),
    );
  }
}

//Trying out helper methods here because there's a lot of repeated code
Widget tableLabelBuilder(String text) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0),
    child: Center(
      child: Text(text,
          style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 1.1)),
    ),
  );
}


Widget tableInputBuilder(String hint, WorkoutExercise exercise, String uniqueKey, VoidCallback setState,
    BuildContext context, int setIndex) {

  //Find which the specific set so in every if reduce the code by a whole lot
  ExerciseSet set = exercise.setList[setIndex];

  if ((exercise.catalog.isCardio || exercise.catalog.isIsometric) &&
      (hint.toLowerCase() != "kg" && hint.toLowerCase() != "lbs" && hint.toLowerCase() != "type" && hint.toLowerCase() != "rpe") ) {

    int currentMinutes = 0;
    int currentSeconds = 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          //First text field for minutes
          Expanded(
            child: TimeInputField(
              onSave: (minutes){ //Get the value from controller.text
                currentMinutes = minutes;
                //When found access his first set and set seconds
                set.seconds = (currentMinutes * 60) + currentSeconds;

              },

              hint: hint,
              uniqueKey: uniqueKey,
            ),
          ),
          Text(":"),
          //Second text field for seconds
          Expanded(
            child: TimeInputField(

              onSave: (seconds){ //Get the value from controller.text
                currentSeconds = seconds;
                //When found access his first set and set seconds
                set.seconds =  (currentMinutes * 60) + currentSeconds;

              },

              hint: hint,
              uniqueKey: uniqueKey,
            ),
          )
        ],
      ),
    );

  } else if (hint.toLowerCase() == "type" || hint.toLowerCase() == "rpe") {

    //Always fetch the type and rpe so when setState is called it re-fetches the same variable maintaining it
    int? currentRpe = set.rpe;
    String? currentType = set.type;


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      //--decoration
      child: DropdownButtonHideUnderline(
        child: InputDecorator(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
          ),
          //--End decoration

          child: hint.toLowerCase() == "type"
              ? DropdownButton(
            key: ValueKey(uniqueKey),
            value: currentType == "" ? null : currentType,
            isExpanded: true,
            hint: Text("Select", style: TextStyle(color: Colors.grey[400], fontSize: 14),),
            style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white),

            items: const [
              DropdownMenuItem(value: "normal", child: Text("Normal")),
              DropdownMenuItem(value: "dropset", child: Text("Dropset")),
              DropdownMenuItem(value: "warmup", child: Text("Warmup")),
              DropdownMenuItem(value: "failure", child: Text("Failure")),
              DropdownMenuItem(value: "1rm", child: Text("1RM")),
            ],
            onChanged: (value) {
              setState(); //Call function parameter
              set.type = value ?? "normal";
              currentType = value;

              print(set);
            },
          )
          //RPE
              : DropdownButton(
              key: ValueKey(uniqueKey),
              isExpanded: true,
              value: currentRpe == 0 ? null : currentRpe,
              hint: Text("Select", style: TextStyle(color: Colors.grey[400], fontSize: 14)),
              style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),

              //Generate 10 items with index 1-10 actually (0-9)
              items: List.generate(10, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Center(child: Text("${index + 1}")),
                );
              }),
              onChanged: (value) {
                setState(); //Call function parameter},
                set.rpe = value ?? 0;
                currentRpe = value;
              }
          ),
        ),
      ),
    );

  } else {
    //---KG OR REPS---
    //UPDATE THE CONTROLLERS' VALUES ON PAGE LOAD SO DATA IS SHOWN ON THE TEXT FIELD IF REBUILT
    //WEIGHT
    if(hint.toLowerCase() == "kg" || hint.toLowerCase() == "lbs"){
      //inlineIf set's weight isn't null, controller's text is its value.toString(), else it's 0 and not "null".
      set.weight != null  ?  set.weightController?.text = set.weight.toString()  :  set.weightController?.text = "0";
    }
    //REPS
    else if(hint.toLowerCase() == "0"){
      //inlineIf set's reps isn't null, controller's text is its value.toString(), else it's 0 and not "null".
      set.reps != null  ?  set.repsController?.text = set.reps.toString()  :  set.repsController?.text = "0";
    }
  }

  void updateValues(dynamic value){ //Create a local function not to copy-n-paste it inside onSub. and onTapOut. just for less written code.
    //WEIGHT
    if(hint.toLowerCase() == "kg" || hint.toLowerCase() == "lbs"){
      set.weight = double.tryParse(value) ?? 0;
    }
    //REPS
    else if(hint.toLowerCase() == "0"){
      set.reps = int.tryParse(value) ?? 0;
    }
  }
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    child: TextField(
      onSubmitted: (_){
        if(hint.toLowerCase() == "kg" || hint.toLowerCase() == "lbs"){
          updateValues(set.weightController?.text);
        }
        else if(hint.toLowerCase() == "0"){
          updateValues(set.repsController?.text);
        }
      },
      onTapOutside: (_){
        if(hint.toLowerCase() == "kg" || hint.toLowerCase() == "lbs"){
          updateValues(set.weightController?.text);
        }
        else if(hint.toLowerCase() == "0"){
          updateValues(set.repsController?.text);
        }
        FocusScope.of(context).unfocus(); //get out of keyboard
      },
      onChanged: (val) {
        // Sync the model SILENTLY as the user types
        if (hint.toLowerCase() == "kg" || hint.toLowerCase() == "lbs") {
          set.weight = double.tryParse(val);
        } else {
          set.reps = int.tryParse(val);
        }
      },

      key: ValueKey(uniqueKey),
      controller: (hint.toLowerCase() == "kg" || hint.toLowerCase() == "lbs") ? set.weightController :  set.repsController, //WeightController or RepsController inline if
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
      ),
    ),
  );
}
