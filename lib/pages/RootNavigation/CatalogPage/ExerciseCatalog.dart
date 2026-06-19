import 'package:gravlift_workout_tracker_app/main.dart';
import 'package:gravlift_workout_tracker_app/pages/auth/authFunctions.dart';

class ExerciseCatalog {
  final String id;
  final String exercise_name;
  final String muscle_trained;
  final String muscle_group;
  final String? how_to;
  final String yt_link;
  final bool isBodyweight;
  final bool isIsometric;
  final bool isBandAssisted;
  final bool isCardio;
  final String exercise_image_filename;
  final bool isCustomExercise;

  ExerciseCatalog({
    required this.id,
    required this.exercise_name,
    required this.muscle_trained,
    required this.muscle_group,
    required this.how_to,
    required this.yt_link,
    required this.isBodyweight,
    required this.isIsometric,
    required this.isBandAssisted,
    required this.isCardio,
    required this.exercise_image_filename,
    required this.isCustomExercise,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise_name': exercise_name,
      'muscle_trained': muscle_trained,
      'muscle_group': muscle_group,
      'how_to': how_to,
      'yt_link': yt_link,
      'isBodyweight': isBodyweight,
      'isIsometric': isIsometric,
      'isBandAssisted': isBandAssisted,
      'isCardio': isCardio,
      'exercise_image_filename': exercise_image_filename,
      'isCustomExercise': isCustomExercise,
    };
  }

  factory ExerciseCatalog.fromMap(Map<String,dynamic> map){
    return ExerciseCatalog(
      id: map["id"],
      exercise_name: map["exercise_name"],
      muscle_trained: map["muscle_trained"],
      muscle_group: map["muscle_group"],
      how_to: map["how_to"] ?? "",
      yt_link: map["yt_link"],
      isBodyweight: map["isBodyweight"],
      isIsometric: map["isIsometric"],
      isBandAssisted: map["isBandAssisted"],
      isCardio: map["isCardio"],
      exercise_image_filename: map["exercise_image_filename"],
      isCustomExercise: map["isCustomExercise"],
    );
  }
}



Future< List<ExerciseCatalog> > fetchExerciseCatalogInfo() async {

  //Updated for C.Exercise
  print("DEBUG: start fetchExerciseCatalogInfo...");
  List<Map<String,dynamic>> exerciseCatalogMapList;
  List<Map<String,dynamic>> customExercisesList;

  exerciseCatalogMapList = await supabaseClient.from("exercise_catalog").select();
  customExercisesList = await supabaseClient.from("custom_exercises").select().eq("user_id", user_id);
  //add the customExList to the other list
  exerciseCatalogMapList.addAll(customExercisesList);


  List<ExerciseCatalog> exerciseCatalogObjList = [];
  for (Map<String,dynamic> row in exerciseCatalogMapList) {
    exerciseCatalogObjList.add(ExerciseCatalog.fromMap(row));
  }
  print("DEBUG: end fetchExerciseCatalogInfo...");

  return exerciseCatalogObjList;
}
