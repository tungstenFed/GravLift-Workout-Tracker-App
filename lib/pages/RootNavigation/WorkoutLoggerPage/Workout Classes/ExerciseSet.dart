import 'package:flutter/cupertino.dart';

class ExerciseSet {
   String id;
   String workout_exercise_id;
   String user_id;
   double? weight;
   int? reps;
   int? seconds; //In seconds
   String type;
   int rpe;
   TextEditingController? weightController;
   TextEditingController? repsController;

  ExerciseSet({
    required this.id,
    required this.workout_exercise_id,
    required this.user_id,
    this.weight,
    this.reps,
    this.seconds,
    required this.type,
    required this.rpe,
    this.weightController,
    this.repsController,
  });

  Map<String, dynamic> toJson(){
    return {
      "id": id,
      "workout_exercise_id": workout_exercise_id,
      "user_id": user_id,
      "weight": weight,
      "reps": reps,
      "seconds": seconds,
      "type": type,
      "rpe": rpe,
      //No controllers here, will be initialized later (JSON CAN ONLY BE PRIMITIVE DATA NO FLUTTER OBJECTS!)
    };
  }

  factory ExerciseSet.fromJsonMap(Map<String, dynamic> jsonMap){
    //Used when fetching from db
    return ExerciseSet(
      id: jsonMap["id"],
      workout_exercise_id: jsonMap["workout_exercise_id"],
      user_id: jsonMap["user_id"],
      weight: jsonMap["weight"],
      reps: jsonMap["reps"] ,
      seconds: jsonMap["seconds"],
      type: jsonMap["type"], //not null, always ''
      rpe: jsonMap["rpe"], //always 0 not null
      weightController: TextEditingController(text: jsonMap["weight"].toString()), //When creating the obj, create here controllers instead of passing them
      repsController: TextEditingController(text: jsonMap["reps"].toString()),
    );
  }

   factory ExerciseSet.fromMap(Map<String, dynamic> map){
     //Used when fetching from db
     return ExerciseSet(
       id: map["id"],
       workout_exercise_id: map["workout_exercise_id"],
       user_id: map["user_id"],
       weight: double.tryParse(map["weight"].toString()),
       reps: map["reps"] ,
       seconds: map["seconds"],
       type: map["type"], //not null, always ''
       rpe: map["rpe"], //always 0 not null
       weightController: TextEditingController(text: map["weight"].toString() ?? ""), //When creating the obj, create here controllers instead of passing them
       repsController: TextEditingController(text: map["reps"].toString() ?? ""),
     );
   }


   @override
   String toString() {
     return '      [SET] ID: ${id.substring(0,5)}... | Weight: $weight | Reps: $reps | Sec: $seconds | Type: $type | RPE: $rpe';
   }

}
