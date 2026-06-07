import 'package:gravlift_workout_tracker_app/pages/RootNavigation/CatalogPage/ExerciseCatalog.dart';

import 'ExerciseSet.dart';

class WorkoutExercise {
  String id;
  String exercise_id;
  String workout_id;
  String user_id;
  String name;//original
  int order;
  List<ExerciseSet> setList;
  ExerciseCatalog catalog;

  WorkoutExercise({
    required this.id,
    required this.exercise_id,
    required this.workout_id,
    required this.user_id,
    required this.name,
    required this.order,
    required this.setList,
    required this.catalog,
  });

  void addSet(ExerciseSet set){
    setList.add(set);
  }
  void removeSet(ExerciseSet set){
    setList.remove(set);
  }

  @override
  String toString() {
    // Join all sets with a newline for better readability
    String sets = setList.map((s) => s.toString()).join("\n");
    return '   (EXERCISE) Name: $name | Order: $order | ID: ${id.substring(0,5)}...\n$sets';
  }


  Map<String, dynamic> toJson(){
    return {
      "id": id,
      "exercise_id": exercise_id,
      "workout_id": workout_id,
      "user_id":user_id,
      "name":name,
      "order": order,
      "setList":(setList).map((e) => e.toJson()).toList(),
      "catalog": catalog.toJson(),
    };
  }

  factory WorkoutExercise.fromJsonMap(Map<String, dynamic> jsonMap){
    return WorkoutExercise(
      id: jsonMap["id"],
      exercise_id: jsonMap["exercise_id"],
      workout_id: jsonMap["workout_id"],
      user_id: jsonMap["user_id"],
      name: jsonMap["name"],
      order: jsonMap["order"],
      //also for catalog
      catalog: ExerciseCatalog.fromMap(jsonMap["catalog"]),
      //Every set is now an object starting from the json
      setList: (jsonMap["setList"] as List).map((e) => ExerciseSet.fromJsonMap(e)).toList(),
    );
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map, Map<String,dynamic> exCatalogMap){ //Made for history
    return WorkoutExercise(
      id: map["id"],
      exercise_id: map["exercise_id"],
      workout_id: map["workout_id"],
      user_id: map["user_id"],
      name: ExerciseCatalog.fromMap(exCatalogMap).exercise_name, //To be filled
      order: map["order"],
      //also for catalog
      catalog: ExerciseCatalog.fromMap(exCatalogMap),
      setList: [], //Filled while building
    );
  }

}