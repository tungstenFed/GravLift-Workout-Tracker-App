import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gravlift_workout_tracker_app/WorkoutDataManager%20(changeNotifier)/WorkoutDataManager.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/CatalogPage/CreateExercise/CreateExercisePage.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/CatalogPage/ExerciseCatalog.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/CatalogPage/ExercisePage.dart';
import 'package:gravlift_workout_tracker_app/pages/templates/widgetsTemplates.dart';
import 'package:provider/provider.dart';


class CatalogPage extends StatefulWidget{
  const CatalogPage({super.key});
  @override
  State<StatefulWidget> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage>{


  Future<List<ExerciseCatalog>>? futureExerciseCatalogList; //Full list, no search function used.

  List<ExerciseCatalog>? exerciseCatalogList;
  List<ExerciseCatalog>? filteredExerciseList;
  String chosenMuscleGroup = "Chest";

  @override
  void initState(){
    super.initState();
    loadData();
  }
  void loadData() {
    WorkoutDataManager manager = Provider.of<WorkoutDataManager>(context, listen: false);
    futureExerciseCatalogList = manager.exerciseCatalogList; //no await
  }

  void searchExerciseByText(String value){

    List<ExerciseCatalog> foundExercises;

    if(value.isEmpty){
      foundExercises = exerciseCatalogList!; //All exercises if empty
    }
    else{
      //.where() returns an iterable and for each element, if true is return it is added to the new list
      //else discarded. Used to filter lists, perfect here.
      foundExercises = exerciseCatalogList!.where(
      (exercise){
          String name = exercise.exercise_name.toLowerCase();
          value = value.toLowerCase();

        if(name.contains(value.toLowerCase())){
          return true;
        }else{
          return false;
        }
      }).toList(); //Cause returns an iterable
    }

    setState(() {
      filteredExerciseList = foundExercises;
    });
  }
  void searchExerciseByMuscleGroup(String muscleGroup){
    chosenMuscleGroup = muscleGroup;

    List<ExerciseCatalog> foundExercises;
    if(muscleGroup.isEmpty  || muscleGroup == null){
      foundExercises = exerciseCatalogList!; //All exercises if empty
    }
    else{
      foundExercises = exerciseCatalogList!.where((exercise){
        if(exercise.muscle_group == muscleGroup){return true;}
        else{return false;}
      }).toList();
    }
    setState(() {
      filteredExerciseList = foundExercises;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          TextButton.icon(
            //Strategy, new table in supabase, fetch also from that and create a obj similar to exercisecatalog but from that personalized and private exclusive to user table
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => CreateExercisePage()));
            },
            label: gravLiftText(text: "Create", size: 20, color: Colors.deepPurpleAccent),
            icon: Icon(Icons.edit, color: Colors.deepPurpleAccent,),
          ),
        ],
        title: Text(
          "Exercise catalog",
          textAlign: TextAlign.center,
          style: GoogleFonts.boldonse(
              fontSize: 18
          ),
        ),
      ),
      body: FutureBuilder(
        future: futureExerciseCatalogList,
        builder: (context, snapshot){
          // Error case
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text("${snapshot.error}")),
            );
          }

          // If data is being fetched, return loading animation
          if (!snapshot.hasData) {
            return const Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator.adaptive(), SizedBox(height: 10), Text("Loading Exercises..."),],
              ),
            );
          }
          // If data is successfully fetched, assign it
          //load the data one time, checking if it is null, so it doesn't get overwritten every setState().
          if(exerciseCatalogList == null){
            exerciseCatalogList = snapshot.data!;
            filteredExerciseList = snapshot.data!;
          }

          return Scaffold(
            body: Column(
              children: [
                Row(
                  children: [
                    Expanded( //Searchbar Text field
                      child: gravLiftTextField(
                        hint: "Search",
                        icon: Icons.search,
                        onChanged: (value)=>searchExerciseByText(value),
                      ),
                    ),
                    DropdownButton(
                      hint: Text(chosenMuscleGroup),
                      items: [
                        DropdownMenuItem(value: "Chest", child: Text("Chest")),
                        DropdownMenuItem(value: "Abs", child: Text("Abs")),
                        DropdownMenuItem(value: "Core", child: Text("Core")),
                        DropdownMenuItem(value: "Arms", child: Text("Arms")),
                        DropdownMenuItem(value: "Back", child: Text("Back")),
                        DropdownMenuItem(value: "Legs", child: Text("Legs")),
                        DropdownMenuItem(value: "Full Body", child: Text("Full Body")),
                      ],
                      onChanged: (value)=>searchExerciseByMuscleGroup(value!),
                    )
                  ],
                ),


                // Expanded is required here because the Scaffold's body is a Column containing a ListView.
                // Since a ListView defaults to infinite height,it wouldn't know how to constrain itself within the Column,
                // leading to an 'unbounded height' error. Using Expanded forces the ListView to fill only the remaining
                // screen space, preventing layout overflows and enabling scrolling.
                Expanded(
                  child: ListView.separated(
                    itemCount: filteredExerciseList!.length, //How many times

                    separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1,),

                    itemBuilder: (context, index) {
                      final exercise = filteredExerciseList![index];
                      //Path = standard exercise, url = custom ex
                      String imagePathOrUrl =
                          exercise.isCustomExercise == false
                              ? "assets/images/exercisesImages/${exercise.exercise_image_filename}"
                              : exercise.exercise_image_filename;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.black,
                          foregroundImage: exercise.isCustomExercise == false
                            ? AssetImage(imagePathOrUrl)
                            : NetworkImage(imagePathOrUrl)
                        ),
                        title: gravLiftText(
                          text: exercise.exercise_name,
                          size: 20,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: gravLiftText(
                            text: exercise.muscle_trained,
                            size: 15,
                            color: Colors.grey,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.deepPurpleAccent,
                          size: 18,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExercisePage(exercise: exercise),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );

        }
      )
    );
  }

}