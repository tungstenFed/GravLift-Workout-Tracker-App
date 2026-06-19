import 'dart:core';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

//Explanation in OngoingWorkoutPage!
class WorkoutDataManager extends ChangeNotifier{
  WorkoutDataManager(){
    initConnectionListener();
    initData();
  }

  WorkoutSession? workoutSession; //Null, will be filled up as the workout goes on and there isn't always a ws ongoing
  WorkoutTimer? timer;
  String sharedPrefActiveWS = "active_workout_session"; //To not always write it over and over. this is the file in SP name where data will be
  String sharedPrefOfflineWS = "offline_workout_sessions"; //To stack WS appended in while offline and load them on supabase on online
  String sharedPrefOfflineCE = "offline_custom_exercises"; //same as above
  String sharedPrefProfileInfo = "profile_info";
  String sharedPrefExCatalog = "exercise_catalog";
  String sharedPrefPfpPath = "pfp_path"; //Load pfp offline

  //Null to initialize it here, and future to put await in the pages where it's fetched, less code to edit
  //Gotta be future also to use them in futureBuilders
   Future<ProfileInfo> profileInfo = Future.any([]); //Empty
   Future<List<ExerciseCatalog>>? exerciseCatalogList = fetchExerciseCatalogInfo();
   Future<int> numWorkoutSession = Future.value(0);
   Future<List<WorkoutSession>?>  history = Future.value([]);

   bool internetConnection = false;


  void initData() async {
    //---Quick connection check cause the listener will take some ms to start
    final connectivityResult = await Connectivity().checkConnectivity();
    internetConnection = !connectivityResult.contains(ConnectivityResult.none);
    //---

    if(internetConnection==false){
      //OFFLINE
      loadProfileInfoFromSharedPref();
      loadExCatalogToSharedPref();
      loadPfpFromSharedPref();

      //These 2 are none offline
      history = Future.value([]);
      numWorkoutSession = Future.value(0);
    } else {
      //ONLINE
      profileInfo = fetchProfileInfo();
      exerciseCatalogList = fetchExerciseCatalogInfo();

      saveProfileInfoToSharedPref(await profileInfo);
      saveExCatalogToSharedPref();

      numWorkoutSession = fetchNumberWorkoutSessions();
      history = fetchWorkoutSessions();
    }
    notifyListeners();
  }

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

  //---ACTIVE WS SHARED PREFERENCES---

      //To save everything is SP we're gonna user this class. First encode in json and save to SP, then on app open decode and assign here.
      //Also a method to clear the SP once everything is saved in db
      //Save to sPrefs
  Future<void> saveToSharedPreferences() async {

    if(workoutSession != null){ //if there's an active WS
      
      SharedPreferences sPrefs = await SharedPreferences.getInstance(); //Get prefs' instance so we can access it

      String jsonString = jsonEncode(workoutSession?.toJson()); //Create a JSON string to give sPrefs
      await sPrefs.setString(sharedPrefActiveWS, jsonString); //Save as a JSON String to sPrefs, specifying the "file" Name
      print("[DEBUG] SUCCESSFULLY SAVED TO S-PREFS (active-ws)");
    }
    notifyListeners();
  }
  //load from sPrefs and assign the workout session
  Future<void> loadFromSharedPreferences() async {
    SharedPreferences sPrefs = await SharedPreferences.getInstance();
    String? jsonString = sPrefs.getString(sharedPrefActiveWS);

    //If there was an active session...
    if(jsonString != null){
      //Decode the json string in a Map<String, dynamic> so we can factory and build a Object (cascade effect, every ex and set get's factory-ed)
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      workoutSession = WorkoutSession.fromJsonMap(jsonMap);

      print("[DEBUG] successfully loaded data from last session (active-ws)");
      notifyListeners();
    }
  }
  Future<void> clearSharedPreferences() async {
    final sPrefs = await SharedPreferences.getInstance();
    await sPrefs.remove(sharedPrefActiveWS);
    notifyListeners();
    print("🧹 [DEBUG]  SPREFS CLEARED. (active-ws)");
  }

  //---PROFILE INFO SHARED-PREFERENCES---
  Future<void> saveProfileInfoToSharedPref(ProfileInfo data) async {
    final sPrefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(data.toJson());
    await sPrefs.setString(sharedPrefProfileInfo, jsonString);
    notifyListeners();
  }
  Future<void> loadProfileInfoFromSharedPref() async {
    SharedPreferences sPrefs = await SharedPreferences.getInstance();
    String? jsonString = sPrefs.getString(sharedPrefProfileInfo);
    if(jsonString != null){
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      profileInfo = Future.value(ProfileInfo.fromMap(jsonMap)); //Convert to future obj not to rework the entire app

      print("[DEBUG] successfully loaded data(profileinfo)");
      notifyListeners();
    }
  }

  //---EXERCISE CATALOG SHARED-PREFERENCES---
  Future<void> saveExCatalogToSharedPref() async {
    final sPrefs = await SharedPreferences.getInstance();
    List<ExerciseCatalog>? loadedExCatalog = await exerciseCatalogList;
    String jsonString = "";

    if(loadedExCatalog != null){
      //Turn that exerciseCatalog list in a list map<String,dynamic> for json
      List<Map<String,dynamic>> jsonLoadedExCatalog = loadedExCatalog.map((exercise) => exercise.toJson()).toList();
      jsonString = jsonEncode(jsonLoadedExCatalog);

      await sPrefs.setString(sharedPrefExCatalog, jsonString);
      notifyListeners();
    }
  }
  Future<void> loadExCatalogToSharedPref() async {
    SharedPreferences sPrefs = await SharedPreferences.getInstance();
    String? jsonString = sPrefs.getString(sharedPrefExCatalog);

    if(jsonString != null){
      List<dynamic> jsonDecodedList = jsonDecode(jsonString);
      List<ExerciseCatalog> decodedList = jsonDecodedList.map((exercise) => ExerciseCatalog.fromMap(exercise)).toList();
      exerciseCatalogList = Future.value(decodedList);

      print("[DEBUG] successfully loaded data(exerciseCATALOG)");
      notifyListeners();
    }
  }

  //---PFP SHARED-PREFERENCES---
  Future<void> savedPfpToSharedPref(String pfpPath) async {
    final sPrefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(pfpPath);
    await sPrefs.setString(sharedPrefPfpPath, jsonString);
    notifyListeners();
  }
  Future<String> loadPfpFromSharedPref() async {
    SharedPreferences sPrefs = await SharedPreferences.getInstance();
    String? jsonString = sPrefs.getString(sharedPrefPfpPath);
    if(jsonString != null){
      String pfpPath = jsonDecode(jsonString);
      print("[DEBUG] successfully loaded data(PFP-SHARED-PREFS)");
      return pfpPath;
    }
    return "";
  }

  //---OFFLINE WORKOUT SESSIONS (PENDING) SHARED-PREFERENCES
  Future<void> saveOfflineWSToSharedPref() async {
    try{
      //Add batch of pending ws's that'll be added to supabase when internet is back on.
      SharedPreferences sPrefs = await SharedPreferences.getInstance();

      //Fetch the other offline ws already in SP, then add the current one.
      List<WorkoutSession> offlineSessions = []; //needs to be dynamic in other for jsonDecode to work and add.
      String? jsonString = sPrefs.getString(sharedPrefOfflineWS);

      if(jsonString != null){
        //Get the past list and convert all in workoutSession objects. jsonDecode returns a List<dynamic>
        List<dynamic> pastSessions = jsonDecode(jsonString);
        offlineSessions = pastSessions.map((session) => WorkoutSession.fromJsonMap(session)).toList();
      }
      offlineSessions.add(workoutSession!);

      //Saved in a list of workout sessions, when loading from this SP keep in mind its a list
      List<Map<String, dynamic>> jsonOfflineWs = offlineSessions.map((session) => session.toJson()).toList();
      jsonString = jsonEncode(jsonOfflineWs);
      await sPrefs.setString(sharedPrefOfflineWS, jsonString);

      print("[DEBUG] SUCCESSFULLY SAVED TO S-PREFS (OFFLINE-ws)");
      notifyListeners();
    } catch (e,stack){
      print(e);
    }
  }
  Future<void> load_InsertOfflineWSFromSharedPref() async {
    SharedPreferences sPrefs = await SharedPreferences.getInstance();
    String? jsonString = sPrefs.getString(sharedPrefOfflineWS);
    try{

      if(jsonString != null) {
        List<dynamic> jsonOfflineWs = jsonDecode(jsonString);
        List<WorkoutSession> offlineWs = jsonOfflineWs.map((session) => WorkoutSession.fromJsonMap(session)).toList();

        if (internetConnection) {
          print("3");
          //Insert every session in supabase
          for (WorkoutSession session in offlineWs) {
            print("4");
            await supabaseClient.from("workout_sessions").insert({
              "user_id": user_id,
              "name": session.name,
              "id": session.id,
              "start_time": session.start_time!.toIso8601String(),
              "end_time": session.end_time!.toIso8601String(),
              "created_time": session.created_time!.toIso8601String()
            }).eq("user_id", user_id);

            print("Loaded offline session to supabase.");
          }

        }
      }
      } catch (e,stack){
      print("************\*************$e,$stack*****************\************");
      }
    }

  //---OFFLINE CUSTOM EXERCISES (PENDING) SHARED-PREFERENCES
  Future<void> saveCustomExToSharedPref(ExerciseCatalog customExercise) async {
    SharedPreferences sPrefs = await SharedPreferences.getInstance();

    List<ExerciseCatalog> offlineCustomExercises = [];
    String? jsonString = sPrefs.getString(sharedPrefOfflineCE);
    if(jsonString != null){
      List<dynamic> decodedList = jsonDecode(jsonString);
      offlineCustomExercises = decodedList.map((cEx) => ExerciseCatalog.fromMap(cEx)).toList();
    }
    offlineCustomExercises.add(customExercise);

    List<Map<String,dynamic>> jsonCustomExList = offlineCustomExercises.map((cEx) => cEx.toJson()).toList();
    jsonString = jsonEncode(jsonCustomExList);
    sPrefs.setString(sharedPrefOfflineCE, jsonString);

    print("[DEBUG] SUCCESSFULLY SAVED TO S-PREFS (CUSTOM-EXERCISE)");
    notifyListeners();
  }
  Future<void> load_InsertOfflineCustomExFromSharedPref() async {
    SharedPreferences sPrefs = await SharedPreferences.getInstance();
    String? jsonString = sPrefs.getString(sharedPrefOfflineCE);

    if(jsonString != null){
      List<dynamic> jsonOfflineCustomEx = jsonDecode(jsonString);
      List<ExerciseCatalog> offlineCustomEx = jsonOfflineCustomEx.map((cEx) => ExerciseCatalog.fromMap(cEx)).toList();

      try{
        if(internetConnection){
          //Insert every session in supabase
          for(ExerciseCatalog cEx in offlineCustomEx){
            await supabaseClient.from("custom_exercises").insert({
              "exercise_name": cEx.exercise_name,
              "id": cEx.id,
              "user_id": user_id,
              "muscle_trained": cEx.muscle_trained,
              "muscle_group": cEx.muscle_group,
              "isBodyweight": cEx.isBodyweight,
              "isBandAssisted": cEx.isBandAssisted,
              "isCardio": cEx.isCardio,
              "isIsometric": cEx.isIsometric,
              "exercise_image_filename" : cEx.exercise_image_filename,
              "yt_link": cEx.yt_link
            }).eq("user_id", user_id);
            print("Loaded offline Custom exercise to supabase.");
          }
          sPrefs.clear();
        }
      } catch (e){
        print(e);
      }
    }
  }

  //Needed to re-fetch history and n of workout sessions so when adding or deleting a workout session, the page is updated
  Future<void> reFetchHistory() async{
      if(internetConnection){
        history = fetchWorkoutSessions();
        numWorkoutSession = fetchNumberWorkoutSessions();
        print("Successfully re-fetched history");
      } else {
        history = Future.value([]);
        numWorkoutSession = Future.value(0);
        print("Didn't re-fetch history, no internet.");
        }
      notifyListeners(); //Update who's watching the data manager (root, history)
  }
  Future<void> reFetchExerciseCatalogList() async {
      if(internetConnection) {
        //Function used to refetch what's in the manager which is fetched only once on app's opening, after creating a Custom ex.
        exerciseCatalogList = fetchExerciseCatalogInfo(); //The real change is in this function, added the c.ex table!
        notifyListeners();
        print("Successfully refetched catalog");

      } else {
        loadExCatalogToSharedPref();
        print("Didn't CEX re-fetched Catalog, got from Sp");
      }
  }
  Future<void> reFetchProfileInfo() async {
      if(internetConnection){
        profileInfo = fetchProfileInfo();
        notifyListeners();
        print("Successfully re-fetched profileInfo");
      } else {
        loadProfileInfoFromSharedPref();
        print("Didn't re-fetch profileInfo, got from SP");
      }
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

  void initConnectionListener(){
    //Add a connectivity_plus package listener to check changes in internet connection
    Connectivity() //Create instance
      .onConnectivityChanged //Use the package's Stream (Flux of data)
      .listen((List<ConnectivityResult> result){
          //now .listen() is a Stream's function that lets you listen to every change made by that stream ( Constant flux of data)
            //In this case flutter listens to every change in th\e connection. And when there's a change it RUNS this code.
            //Uses a List<ConnectivityResult> to get access to the result
        if(result.isNotEmpty && result.contains(ConnectivityResult.none)){
          internetConnection = false;notifyListeners();
        }else{
          internetConnection = true;
          //When coming from started app with no internet, and internet comes up refetch from db
          saveExCatalogToSharedPref();
          reFetchHistory();
          reFetchExerciseCatalogList(); //So loads it when internet comes back on
          load_InsertOfflineCustomExFromSharedPref(); //Whenever internet's on, load the pending cEx
          load_InsertOfflineWSFromSharedPref(); //same as line above, ws

          notifyListeners();
        }

    });
  }


}