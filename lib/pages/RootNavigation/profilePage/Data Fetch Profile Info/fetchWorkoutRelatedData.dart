import 'package:flutter/material.dart';
import 'package:gravlift_workout_tracker_app/main.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/CatalogPage/ExerciseCatalog.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/Workout%20Classes/ExerciseSet.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/Workout%20Classes/WorkoutExercise.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/Workout%20Classes/WorkoutSession.dart';
import 'package:gravlift_workout_tracker_app/pages/auth/authFunctions.dart';
import 'package:postgrest/src/types.dart';

Future<int> fetchNumberWorkoutSessions() async {
  List<Map<String,dynamic>> workoutSessions = await supabaseClient.from("workout_sessions").select().eq("user_id", user_id).eq("isRoutine", false);
  return workoutSessions.length;
}

Future<List<WorkoutSession>?> fetchWorkoutSessions() async {

  try{
    List<Map<String,dynamic>> dataWSList = await supabaseClient.from("workout_sessions").select().eq("user_id", user_id).eq("isRoutine", false);
    List<WorkoutSession> result = [];
    for(var ws in dataWSList){
      WorkoutSession objSession = WorkoutSession.fromMap(ws); //Need to fill his exercisesList
      List<Map<String,dynamic>> dataEXList = await supabaseClient.from("workout_exercises").select().eq("user_id", user_id).eq("workout_id", ws["id"]); //fetch this workout's exList


      for(var ex in dataEXList){
        Map<String,dynamic> exCatalogMap = await supabaseClient.from("exercise_catalog").select().eq("id", ex["exercise_id"]).single(); //get this ex's catalog ex
        WorkoutExercise objExercise = WorkoutExercise.fromMap(ex, exCatalogMap); //Need to fill his setList

        List<Map<String,dynamic>> dataSETList = await supabaseClient.from("exercise_sets").select().eq("user_id", user_id).eq("workout_exercise_id", ex["id"]); //fetch the sets of this ex

        for(var set in dataSETList){
          ExerciseSet objSet = ExerciseSet.fromMap(set);
          objExercise.setList.add(objSet); //fill ex's setList
        }
        objSession.exercisesList.add(objExercise); //fill ws's exList
      }
      result.add(objSession);
    }

    return result;
  } catch(e,stack){print("$e,$stack"); return [];}

}

Future<List<WorkoutSession>?> fetchRoutines() async {
  //Same as fetchWorkoutSessions but fetches ws with .eq("isRoutine",true).
  try{
    List<Map<String,dynamic>> dataWSList = await supabaseClient.from("workout_sessions").select().eq("user_id", user_id).eq("isRoutine", true);
    List<WorkoutSession> result = [];
    for(var ws in dataWSList){
      WorkoutSession objSession = WorkoutSession.fromMap(ws); //Need to fill his exercisesList
      List<Map<String,dynamic>> dataEXList = await supabaseClient.from("workout_exercises").select().eq("user_id", user_id).eq("workout_id", ws["id"]); //fetch this workout's exList


      for(var ex in dataEXList){
        Map<String,dynamic> exCatalogMap = await supabaseClient.from("exercise_catalog").select().eq("id", ex["exercise_id"]).single(); //get this ex's catalog ex
        WorkoutExercise objExercise = WorkoutExercise.fromMap(ex, exCatalogMap); //Need to fill his setList

        List<Map<String,dynamic>> dataSETList = await supabaseClient.from("exercise_sets").select().eq("user_id", user_id).eq("workout_exercise_id", ex["id"]); //fetch the sets of this ex

        for(var set in dataSETList){
          ExerciseSet objSet = ExerciseSet.fromMap(set);
          objExercise.setList.add(objSet); //fill ex's setList
        }
        objSession.exercisesList.add(objExercise); //fill ws's exList
      }
      result.add(objSession);
      print("fetched routines, ${result.length}");
    }

    return result;
  } catch(e,stack){print("$e,$stack"); return [];}
}




