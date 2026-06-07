import 'package:flutter/material.dart';
import 'package:gravlift_workout_tracker_app/main.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/CatalogPage/ExerciseCatalog.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/OngoingWorkoutPage.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/Workout%20Classes/ExerciseSet.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/Workout%20Classes/WorkoutExercise.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/Workout%20Classes/WorkoutSession.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/Data%20Fetch%20Profile%20Info/ProfileInfo.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/Data%20Fetch%20Profile%20Info/fetchProfileInfo.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/Data%20Fetch%20Profile%20Info/fetchWorkoutRelatedData.dart';
import 'package:gravlift_workout_tracker_app/pages/auth/authFunctions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher_string.dart';

//Explanation in OngoingWorkoutPage!
class WorkoutDataManager extends ChangeNotifier{
  WorkoutDataManager();

  WorkoutSession? workoutSession; //Null, will be filled up as the workout goes on and there isn't always a ws ongoing
  WorkoutTimer? timer;
  String sharedPrefFileName = "active_workout_session"; //To not always write it over and over. this is the file in SP name where data will be

  //Null to initialize it here, and future to put await in the pages where it's fetched, less code to edit
  //Gotta be future also to use them in futureBuilders
   Future<ProfileInfo> profileInfo =  fetchProfileInfo();
   Future<List<ExerciseCatalog>>? exerciseCatalogList =  fetchExerciseCatalogInfo();
   Future<int> numWorkoutSession =  fetchNumberWorkoutSessions();
   Future<List<WorkoutSession>?> history = fetchWorkoutSessions();

  void addSession(WorkoutSession session){
    workoutSession = session;
    timer = WorkoutTimer(startTime: DateTime.now());
    workoutSession?.start_time = DateTime.now();
    workoutSession?.created_time = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,);
    notifyListeners();
  }
  void removeSession(){
    clearSharedPreferences();
    workoutSession = null;
    timer = null;
    notifyListeners();
  }
  void addExercise(WorkoutExercise exercise){
    workoutSession!.exercisesList.add(exercise);
    notifyListeners(); //Make every widget aware of the change => UI changes [Always needed]
  }
  void removeExercise(WorkoutExercise exercise){
    workoutSession!.exercisesList.remove(exercise);
    notifyListeners();
  }
  void addSetToExercise(WorkoutExercise whichExercise, ExerciseSet set){
    for(var ex in workoutSession!.exercisesList){
      if(ex.id == whichExercise.id){
        ex.addSet(set);
      }
    } notifyListeners();
  }
  void removeSetToExercise(WorkoutExercise whichExercise, ExerciseSet set){
    for(var ex in workoutSession!.exercisesList){
      if(ex.id == whichExercise.id){
        ex.removeSet(set);
      }
    } notifyListeners();
  }
  void notify(){
    notifyListeners();
  }

  Future<void> insertWorkoutDataInDb(WorkoutSession session) async {

      //Insert session
      await supabaseClient.from("workout_sessions").insert({
        "user_id": user_id,
        "name": session.name,
        "id": session.id,
        "start_time": session.start_time!.toIso8601String(),
        "end_time": session.end_time!.toIso8601String(),
        "created_time": session.created_time!.toIso8601String()
      });

      //Insert every exercise of this session
      int order = 0;
      for(WorkoutExercise exercise in session.exercisesList){
        await supabaseClient.from("workout_exercises").insert({
          "order": order,
          "id": exercise.id,
          "workout_id": exercise.workout_id,
          "exercise_id": exercise.exercise_id,
          "user_id": user_id,
        });
        order++;

        //Insert every set in this exercise's setList
        List<Map<String, dynamic>> setsToInsert = [];

        for (ExerciseSet set in exercise.setList) {
          setsToInsert.add({
            "id": set.id,
            "workout_exercise_id": exercise.id,
            "user_id": user_id,
            "weight": set.weight,
            "reps": set.reps,
            "type": set.type,
            "seconds": set.seconds,
            "rpe": set.rpe,
          });
        }

        // bulk insert!
        if (setsToInsert.isNotEmpty) {
          await supabaseClient.from("exercise_sets").insert(setsToInsert);
        }
      }
      notifyListeners();
  }
  Future<void> editWorkoutDataInDB(WorkoutSession newSession, WorkoutSession oldSession) async {

    try {
      String id = newSession.id; //Id's are the same

      //Get the old times to insert them in the newSession
      DateTime? oldStartTime = oldSession.start_time;
      DateTime? oldEndTime = oldSession.end_time;
      DateTime? oldCreatedTime = oldSession.created_time;


      //Upsert the new session, update data
      await supabaseClient.from("workout_sessions").upsert({
        "user_id": user_id,
        "name": newSession.name,
        "id": id, //The id remains the same, check Edit.
        "start_time": oldStartTime?.toIso8601String(),
        "end_time": oldEndTime?.toIso8601String(),
        "created_time": oldCreatedTime?.toIso8601String(),
      });

      //remove all old exercises and sets
      await supabaseClient.from("workout_exercises")
          .delete()
          .eq("user_id", user_id)
          .eq("workout_id", id);

      //Insert every exercise of this session
      int order = 0;
      for (WorkoutExercise exercise in newSession.exercisesList) {
        await supabaseClient.from("workout_exercises").insert({
          "order": order,
          "id": exercise.id,
          "workout_id": id,
          "exercise_id": exercise.exercise_id,
          "user_id": user_id,
        });
        order++;

        List<Map<String, dynamic>> setsToInsert = [];

        for (ExerciseSet set in exercise.setList) {
          setsToInsert.add({
            "id": set.id,
            "workout_exercise_id": exercise.id,
            "user_id": user_id,
            "weight": set.weight,
            "reps": set.reps,
            "type": set.type,
            "seconds": set.seconds,
            "rpe": set.rpe,
          });
        }
        // Bulk insert
        if (setsToInsert.isNotEmpty) {
          await supabaseClient.from("exercise_sets").insert(setsToInsert);
        }
      }
      reFetchHistory();
    }
    catch(e,stack)
    {
      print("❌\n$e,\n\n$stack");
      rethrow;
    }
  }
  Future<void> deleteAllWorkoutDataForThisUser() async { //For this session eh
    await supabaseClient.from("workout_sessions").delete().eq("user_id", user_id).eq("id", workoutSession!.id);
    //Cascade deletes everything related to this session with foreign keys in supabase
  }
  Future<void> deletePastWorkoutSession(WorkoutSession pastSession) async {
    try {
      await supabaseClient.from("workout_sessions").delete().eq("user_id", user_id).eq("id", pastSession.id);
      print(pastSession.id);
      reFetchHistory();
    }
    catch(e,stack){print("$e,$stack");rethrow;}
  }
  Future<void> createCustomExerciseInDb(ExerciseCatalog customExercise) async{
    try{
      await supabaseClient.from("custom_exercises").insert({
        "exercise_name": customExercise.exercise_name,
        "id": customExercise.id,
        "user_id": user_id,
        "muscle_trained": customExercise.muscle_trained,
        "muscle_group": customExercise.muscle_group,
        "isBodyweight": customExercise.isBodyweight,
        "isBandAssisted": customExercise.isBandAssisted,
        "isCardio": customExercise.isCardio,
        "isIsometric": customExercise.isIsometric,
        "exercise_image_filename" : customExercise.exercise_image_filename,
        "yt_link": customExercise.yt_link
      });
    } catch(e){
      print(e); rethrow;
    }
  }

  //To save everything is SP we're gonna user this class. First encode in json and save to SP, then on app open decode and assign here.
  //Also a method to clear the SP once everything is saved in db
  //Save to sPrefs
  Future<void> saveToSharedPreferences() async {

    if(workoutSession != null){ //if there's an active WS
      
      SharedPreferences sPrefs = await SharedPreferences.getInstance(); //Get prefs' instance so we can access it

      String jsonString = jsonEncode(workoutSession?.toJson()); //Create a JSON string to give sPrefs
      await sPrefs.setString(sharedPrefFileName, jsonString); //Save as a JSON String to sPrefs, specifying the "file" Name
      print("[DEBUG] SUCCESSFULLY SAVED TO S-PREFS");
      
    }
    notifyListeners();
  }
  //load from sPrefs and assign the workout session
  Future<void> loadFromSharedPreferences() async {
    SharedPreferences sPrefs = await SharedPreferences.getInstance();
    String? jsonString = sPrefs.getString(sharedPrefFileName);

    //If there was an active session...
    if(jsonString != null){
      //Decode the json string in a Map<String, dynamic> so we can factory and build a Object (cascade effect, every ex and set get's factory-ed)
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      workoutSession = WorkoutSession.fromJsonMap(jsonMap);

      print("[DEBUG] successfully loaded data from last session");
      print(workoutSession.toString());
      notifyListeners();

    }
  }
  Future<void> clearSharedPreferences() async {
    final sPrefs = await SharedPreferences.getInstance();
    await sPrefs.remove(sharedPrefFileName);
    notifyListeners();
    print("🧹 [DEBUG]  SPREFS CLEARED.");
  }

  //Needed to re-fetch history and n of workout sessions so when adding or deleting a workout session, the page is updated
  Future<void> reFetchHistory() async{
    history = fetchWorkoutSessions();
    numWorkoutSession = fetchNumberWorkoutSessions();
    print("Successfully re-fetched history");

    notifyListeners(); //Update who's watching the data manager (root, history)
  }
  Future<void> reFetchExerciseCatalogList() async {
    //Function used to refetch what's in the manager which is fetched only once on app's opening, after creating a Custom ex.
    exerciseCatalogList = fetchExerciseCatalogInfo(); //The real change is in this function, added the c.ex table!
    notifyListeners();
    print("Successfully CEX re-fetched history");
  }
  Future<void> reFetchProfileInfo() async {
    profileInfo = fetchProfileInfo();
    notifyListeners();
    print("Successfully re-fetched profileInfo");
  }
  
  Future<void> openExternalLink(String stringUrl) async {
    Uri url = Uri.parse(stringUrl);
    if(await canLaunchUrl(url)){
      await launchUrl(url,
        mode: LaunchMode.externalApplication
      );
    } else {
      print("Error opening $stringUrl");
    }

  }
}