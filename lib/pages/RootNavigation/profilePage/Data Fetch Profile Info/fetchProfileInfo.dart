import 'package:gravlift_workout_tracker_app/main.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/Data%20Fetch%20Profile%20Info/ProfileInfo.dart';
import 'package:gravlift_workout_tracker_app/pages/auth/authFunctions.dart';


Future<ProfileInfo> fetchProfileInfo() async {
  print("DEBUG: Inizio caricamento...");
  Map<String,dynamic> profileInfoMap;
  profileInfoMap = await supabaseClient.from("profiles").select().eq("user_id", user_id).single();

  Map<String,dynamic> profileStats = await supabaseClient.from("profiles_stats").select().eq("user_id", user_id).single();
  profileInfoMap.addAll(profileStats);
  print("DEBUG: fatto...");


  return ProfileInfo.fromMap(profileInfoMap);

}