import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/Workout%20Classes/WorkoutExercise.dart';

class WorkoutSession //from Map to Obj
{
  String id;
  DateTime? start_time;
  DateTime? end_time;
  DateTime? created_time;
  String name;
  List<WorkoutExercise> exercisesList = [];

  WorkoutSession({required this.id,  required this.name,  required this.exercisesList,  this.start_time,  this.end_time, this.created_time});

  //from OBJ to MAP which will be later encoded in JSON (for SP)
  Map<String,dynamic> toJson() {
    return {
      "id":id,
      "start_time":start_time?.toIso8601String(),
      "end_time":start_time?.toIso8601String(),
      "created_time":start_time?.toIso8601String(),
      "name":name,
      //Every element in list has to be a Json
      "exercisesList": exercisesList.map((e) => e.toJson()) .toList(),
    };
  }

  //From MAP (decoded from Json in SP) to OBJ using factory
  factory WorkoutSession.fromJsonMap(Map<String, dynamic> jsonMap){
    return WorkoutSession(
      id: jsonMap["id"],
      name: jsonMap["name"],
      start_time: DateTime.tryParse(jsonMap["start_time"]),
      created_time: DateTime.tryParse(jsonMap["created_time"]),
      end_time: DateTime.tryParse(jsonMap["end_time"]),
      //Every element in list is json and it's converted in obj
      exercisesList: (jsonMap["exercisesList"] as List).map((e) => WorkoutExercise.fromJsonMap(e)) .toList(),
    );
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map){
    return WorkoutSession(
      id: map["id"],
      name: map["name"],
      start_time: DateTime.tryParse(map["start_time"]),
      created_time: DateTime.tryParse(map["created_time"]),
      end_time: DateTime.tryParse(map["end_time"]),
      exercisesList: [] //Filled while building each object
    );
  }

  @override
  String toString() {
    // Just call this to print everything about the WS. made with gemini just to debug, and save a lot of time.
    String exercises = exercisesList.map((e) => e.toString()).join("\n   " + "-"*50 + "\n");
    return '''
      ============================================================
      📊 DEBUG WORKOUT SESSION 📊
      ============================================================
      SESSION ID: $id
      NAME:       $name
      START:      $start_time
      END:        $end_time
      ------------------------------------------------------------
      EXERCISES LIST:
      ------------------------------------------------------------
      $exercises
      ============================================================
    ''';
  }

}