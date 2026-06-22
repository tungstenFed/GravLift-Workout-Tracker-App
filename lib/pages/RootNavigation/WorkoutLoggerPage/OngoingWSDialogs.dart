import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gravlift_workout_tracker_app/WorkoutDataManager%20(changeNotifier)/WorkoutDataManager.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/CreateRoutinePage.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/OngoingWorkoutPage.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/Workout%20Classes/WorkoutSession.dart';
import 'package:gravlift_workout_tracker_app/pages/templates/widgetsTemplates.dart';
import 'package:provider/provider.dart';

void gravLiftClosePageDialog(BuildContext contextPage){
  WorkoutDataManager manager = Provider.of<WorkoutDataManager>(contextPage, listen: false);

  showDialog(
    context: contextPage,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Delete workout session?", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: const Text('Permanently delete workout session.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Closes the dialog
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              manager.removeSession();
              manager.clearSharedPreferences();

              Navigator.pop(context);
              Navigator.pop(contextPage); //Just has to be a value, so root runs setState when receiving it
              manager.notify();
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
void gravLiftConfirmSessionDialog(BuildContext contextPage){

  String name = "";
  String exMsg = "";
  WorkoutDataManager manager = Provider.of<WorkoutDataManager>(contextPage, listen: false);
  bool isSubmitLoading = false;

  showDialog(
    context: contextPage,
    builder: (BuildContext context) {
      //RETURN A STATEFUL BUILDER, so this dialog has its own setState function, if called in the parent Widget, it rebuilds that, and not dialogbox
      return StatefulBuilder(builder: (context, setStateDialog){
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Finish Workout session?', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          content: const Text('Insert a name for your workout session:'),
          actions: [
            TextField(
              maxLength: 30,
              onChanged: (value) => name = value,
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context), // Closes the dialog
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isSubmitLoading == true ? null : () async { //If its NULL, it gets deactivated,
                try {
                  if(name == ""){
                      exMsg = "Session must have a name.";
                      setStateDialog((){});
                    } else if (manager.workoutSession!.exercisesList.isEmpty){
                      exMsg = "Session must have at least one exercise.";
                      setStateDialog((){});
                    }
                    else{
                      setStateDialog(()=>isSubmitLoading = true); //Deactivate the button temporarily)

                      exMsg="";
                      manager.workoutSession?.name = name;
                      manager.workoutSession?.end_time = DateTime.now();

                        if(manager.internetConnection){
                          await manager.insertWorkoutDataInDb(manager.workoutSession!); //Wait it's fully inserted in the db
                          manager.removeSession(); //Once its done delete the session from app
                          manager.clearSharedPreferences(); //Of active workout sessions

                          //Re-Fetch to update the profilePage's history
                          manager.reFetchHistory();
                          Navigator.pop(contextPage); //parent widget
                          Navigator.pop(context); //Dialog
                        } else {
                          await manager.saveOfflineWSToSharedPref();

                          manager.removeSession();
                          manager.clearSharedPreferences();

                          manager.reFetchHistory();
                          Navigator.pop(contextPage); //parent widget
                          Navigator.pop(context); //Dialog
                        }
                      }
                    } catch(e){
                      //Every other exception but SocketException (No internet)
                      //Needed because if an error is thrown, some data will be added to db and some not, so every error deletes every remains So on the next 'Submit' we're clear!
                      await manager.deleteAllWorkoutDataForThisUser();
                      setStateDialog((){
                        exMsg = "Please check that every set's information is properly inserted.";
                      });
                      isSubmitLoading = false; //activate if went wrong and has to re-press it
                    }
                      },
                    child: const Text('Submit'),
                  ),

              ],
            ),
            Center(child: gravLiftExceptionText(exMsg)),
          ],
        );
      });
    },
  );
}
void gravLiftReplaceWorkoutSession(BuildContext contextPage, bool isRoutine){

  showDialog(
    context: contextPage,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Ongoing workout session detected.\nPermanently delete the current session?", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: const Text('Permanently delete workout session.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Closes the dialog
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              WorkoutDataManager manager = Provider.of<WorkoutDataManager>(contextPage, listen: false);
              manager.removeSession();
              manager.clearSharedPreferences();
              manager.timer = null;

              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => isRoutine == false ? OngoingWorkoutPage() : CreateRoutinePage()
                  )
              );
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}



void gravLiftDiscardEditsOrRoutineDialog(BuildContext contextPage, bool isRoutine){
  //USED FOR EDIT-WORKOUT-SESSION-PAGE and CREATE-ROUTINE-PAGE!
  WorkoutDataManager manager = Provider.of<WorkoutDataManager>(contextPage, listen: false);

  showDialog(
    context: contextPage,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Discard changes", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Text(
            isRoutine == false ?'Exit session editor without saving?' : 'Exit routine editor without saving?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Closes the dialog
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if(isRoutine){
                manager.removeSession();
                manager.clearSharedPreferences();
              }

              Navigator.pop(context);
              Navigator.pop(contextPage); //Just has to be a value, so root runs setState when receiving it
            },
            child: const Text('Exit'),
          ),
        ],
      );
    },
  );
}
void gravLiftConfirmEditSessionDialog(
    BuildContext contextPage, {required WorkoutSession oldSession,
  required WorkoutSession newSession, required BuildContext historyInfoPageContext}){

  String name = "";
  String exMsg = "";
  WorkoutDataManager manager = Provider.of<WorkoutDataManager>(contextPage, listen: false);
  bool isSubmitLoading = false;

  showDialog(
    context: contextPage,
    builder: (BuildContext context) {
      //RETURN A STATEFUL BUILDER, so this dialog has its own setState function, if called in the parent Widget, it rebuilds that, and not dialogbox
      return StatefulBuilder(builder: (context, setStateDialog){
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Edit Workout session?', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          content: Text('Insert a new name for your workout session:'),
          actions: [
            TextField(
              maxLength: 30,
              onChanged: (value) => name = value,
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context), // Closes the dialog
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isSubmitLoading == true ? null : () async { //If its NULL, it gets deactivated,
                    if(name == ""){
                      exMsg = "Session must have a name.";
                      setStateDialog((){});
                    } else if (newSession.exercisesList.isEmpty){
                      exMsg = "Session must have at least 1 exercise.";
                      setStateDialog((){});
                    }
                    else{
                      newSession.name = name;
                      setStateDialog(()=>isSubmitLoading = true); //Deactivate the button temporarily)
                      exMsg="";
                      try{
                        if(manager.internetConnection){
                          await manager.editWorkoutDataInDB(newSession, oldSession); //Wait it's fully inserted in the db

                          //Re-Fetch to update the profilePage's history
                          manager.reFetchHistory();

                          Navigator.pop(contextPage);  //parent widget
                          Navigator.pop(context); //Dialog
                          Navigator.pop(historyInfoPageContext);
                        } else {
                          setStateDialog((){
                            exMsg = "Please check your internet connection.";
                          });
                          setStateDialog((){isSubmitLoading = false;}); //activate if went wrong and has to re-press it
                        }
                      }catch(e){
                        await manager.deleteAllWorkoutDataForThisUser();
                        setStateDialog((){
                          exMsg = "Please check that every set's information is properly inserted.";
                        });
                        setStateDialog((){isSubmitLoading = false;}); //activate if went wrong and has to re-press it

                      }
                    }
                  },
                  child: const Text('Submit'),
                ),

              ],
            ),
            Center(child: gravLiftExceptionText(exMsg)),
          ],
        );
      });
    },
  );
}
//ROUTINE
void gravLiftConfirmCreateRoutine(BuildContext contextPage, WorkoutSession routine){

  String name = "";
  String exMsg = "";
  WorkoutDataManager manager = Provider.of<WorkoutDataManager>(contextPage, listen: false);
  bool isSubmitLoading = false;

  showDialog(
    context: contextPage,
    builder: (BuildContext context) {
      //RETURN A STATEFUL BUILDER, so this dialog has its own setState function, if called in the parent Widget, it rebuilds that, and not dialogbox
      return StatefulBuilder(builder: (context, setStateDialog){
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Create Routine?', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          content: Text('Insert a new name for your workout routine:'),
          actions: [
            TextField(
              maxLength: 30,
              onChanged: (value) => name = value,
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isSubmitLoading == true ? null : () async {
                    if(name == ""){
                      exMsg = "Routine must have a name.";
                      setStateDialog((){});
                    } else if (routine.exercisesList.isEmpty){
                      exMsg = "Routine must have at least 1 exercise.";
                      setStateDialog((){});
                    }
                    else{
                      routine.name = name;
                      setStateDialog(()=>isSubmitLoading = true);
                      exMsg="";
                      try{
                        if(manager.internetConnection){
                          print("------${routine.isRoutine}-----");
                          await manager.insertWorkoutDataInDb(routine); //isRoutine = true, uploading effectively a routine

                          manager.removeSession(); //Once its done delete the session from app
                          manager.clearSharedPreferences(); //Of active workout sessions

                            await manager.reFetchRoutines();
                           //TODO: shared preferences

                          Navigator.pop(contextPage);  //parent widget
                          Navigator.pop(context); //Dialog
                        } else {
                            await manager.saveOfflineRoutineToSharedPref();

                            manager.removeSession();

                            await manager.reFetchHistory();
                            Navigator.pop(contextPage); //parent widget
                            Navigator.pop(context); //Dialog

                          setStateDialog((){isSubmitLoading = false;}); //activate if went wrong and has to re-press it
                        }

                      }catch(e,stack){
                        await manager.deleteAllWorkoutDataForThisUser();
                        print(stack);
                        setStateDialog((){
                          exMsg = "Please check that every set's information is properly inserted.";
                        });
                        setStateDialog((){isSubmitLoading = false;}); //activate if went wrong and has to re-press it
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),

              ],
            ),
            Center(child: gravLiftExceptionText(exMsg)),
          ],
        );
      });
    },
  );
}
//hsHISTORY
void gravLiftDeletePastSession(BuildContext contextPage, {required WorkoutSession pastSession}){
  WorkoutDataManager manager = Provider.of<WorkoutDataManager>(contextPage, listen: false);

  showDialog(
    context: contextPage,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Delete this past workout session permanently?", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: const Text('Permanently delete workout session.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Closes the dialog
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try{
                if(manager.internetConnection){
                  await manager.deletePastWorkoutSession(pastSession);
                }
              }catch(e,stack){print("$e,$stack");}
              Navigator.pop(context);
              Navigator.pop(contextPage);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}