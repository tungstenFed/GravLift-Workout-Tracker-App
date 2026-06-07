import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gravlift_workout_tracker_app/main.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/CatalogPage/CreateExercise/createExerciseFunctions.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/CatalogPage/ExerciseCatalog.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/Workout%20Classes/UuidGenerator.dart';
import 'package:gravlift_workout_tracker_app/pages/auth/authFunctions.dart';
import 'package:gravlift_workout_tracker_app/pages/templates/widgetsTemplates.dart';
import 'package:gravlift_workout_tracker_app/WorkoutDataManager (changeNotifier)/WorkoutDataManager.dart';
import 'package:provider/provider.dart';

class CreateExercisePage extends StatefulWidget{
  const CreateExercisePage({super.key});
  @override
  State<StatefulWidget> createState() => CreateExercisePageState();
}

class CreateExercisePageState extends State<CreateExercisePage>{

  //TODO: delete the bucket pool img if user uploads and then exits.

  TextEditingController nameController = TextEditingController();
  String? imgPickedUrl;
  String exMessage = "";
  String generatedExerciseId = UuidGenerator.generate(); //Needed to save the picture in the bucket pool
  int musclesTrainedNum = 0;

  List<String> chestMuscles = ['Chest', 'Upper Chest', 'Lower Chest',];
  List<String> backMuscles = ['Back', 'Lats', 'Traps', 'Lower Back',];

  List<String> armMuscles = ['Biceps', 'Triceps', 'Brachialis', 'Forearms',];
  List<String> shoulderMuscles = ['Shoulders', 'Anterior Delts', 'Lateral Delts', 'Rear Delts', 'Rotator Cuff',];
  List<String> legMuscles = ['Quads', 'Hamstrings', 'Glutes', 'Calves', 'Abductors', 'Adductors',];
  List<String> coreMuscles = ['Core', 'Abs', 'Lower Abs', 'Obliques',];
  List<String> otherMuscles = ['Full Body', 'Neck',];

  late List<List<String>> listMusclesTrained = [
    chestMuscles,backMuscles,armMuscles,shoulderMuscles,legMuscles, coreMuscles,otherMuscles
  ];

  static const Map<String,String> titles = {
    //First keywords so the .contains works later on.
    "Chest": "Chest muscles",
    "Back": "Back muscles",
    "Biceps": "Arm muscles",
    "Shoulders": "Shoulder muscles",
    "Quads": "Leg muscles",
    "Core": "Abdominal muscles",
    "Full Body": "Full Body | Others"
  };

  //Create a Set(List but without duplicates and easy functions) because SegmentedButton requires a set of options
  late String involvedMuscle = "Chest"; //one is always there, chest as default
  String musclegroup = "";
  String name = "";
  String imageUrl = "";
  bool isBodyweight = false;
  bool isCardio = false;
  bool isIsometric = false;
  bool isBandAssisted = false;
  bool isCustomExercise = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: TextField(
          maxLength: 20,
          controller: nameController,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: "Custom Exercise's Name",
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
          ),
          onChanged: (value){
            name = value;
          },
        ),
        actions: [
          TextButton.icon(
            onPressed: (){
              if(name != ""){
                confirmCustomExDialog(
                    context, name, generatedExerciseId,
                    isBodyweight, isCardio, isBandAssisted, isIsometric,
                    imageUrl,  involvedMuscle, musclegroup, isCustomExercise
                );
              }
            },
            label: gravLiftText(text: "Confirm", size: 16, color: Colors.deepPurpleAccent),
          ),
        ],
        leading: IconButton(
          onPressed: (){
            discardCustomExDialog(context, generatedExerciseId);
          },
          icon: Icon(Icons.keyboard_return),
        ),
      ),
      body:
      SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 100,
                        foregroundImage: imgPickedUrl == null || imgPickedUrl == ""
                            ? AssetImage("assets/images/custom_exercise.png")
                            : NetworkImage('$imgPickedUrl?t=${DateTime.now().millisecondsSinceEpoch}'),
                        backgroundColor: Colors.black,
                      ),
                      //change icon
                      Positioned(
                        width: 60,
                        height: 50,
                        top: 150,
                        right: 0,
                        child: IconButton(
                            iconSize: 10,
                            icon: Image.asset('assets/images/changes.png'),
                            onPressed: () async {
                              String? url = await handleCustomExPicUpload(generatedExerciseId);
                              url != null ? imageUrl = url : imageUrl = "";
                              setState(() {
                                url == null
                                    ? exMessage = "Error during image upload/Unsupported file type."
                                    : exMessage = "";
                              });
                              setState((){imgPickedUrl = url;});
                            }
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  gravLiftExceptionText(exMessage),
                  SizedBox(height: 10,),
                  gravLiftText(text: "Choose Mainly involved muscle:", size: 20),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        Divider(),
                        SizedBox(height: 10,),

                        //For each LIST inside of this big one, create a wrap, that contains all of that list's muscles
                        ...listMusclesTrained.map((muscleList){
                          var currentTitle = "";
                          titles.forEach((keyword, title){
                            //Each title has a keyword that is contained in each muscleList
                            if(muscleList.contains(keyword)){
                              currentTitle = title;
                            }
                          });

                          //Column because its the Title's wrap + Wrap! (+SizedBoxes)
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              gravLiftText(text: currentTitle, size: 20, color: Colors.white70),
                              SizedBox(height: 5),
                              Wrap(
                                //Wrap made by gemini to space out the buttons and make them go nextLine
                                spacing: 8.0,
                                runSpacing: 8.0,
                                alignment: WrapAlignment.center,

                                children: muscleList.map((muscle) {
                                  final isSelected = involvedMuscle == muscle;
                                  return FilterChip( //On and off Button with a boolean value, selected or not.
                                    label: Text(muscle),
                                    selected: isSelected,
                                    avatar: Image.asset(
                                      'assets/images/tags_icons/${muscle.toLowerCase().trim()}.png',
                                    ),
                                    onSelected: (bool selected) {
                                      setState(() {
                                        //If selected add it to
                                        if(selected == true){
                                          involvedMuscle = muscle;
                                          switch(muscleList.first){
                                            case "Chest":
                                              musclegroup = "Chest";
                                              break;
                                            case "Back":
                                              musclegroup = "Back";
                                              break;
                                            case "Biceps":
                                              musclegroup = "Arms";
                                              break;
                                            case "Shoulder":
                                              musclegroup = "Shoulders";
                                              break;
                                            case "Quads":
                                              musclegroup = "Legs";
                                              break;
                                            case "Core":
                                              musclegroup = "Abs";
                                              break;
                                            case "Full Body": //Either fb or neck muscle group
                                              muscle == "Full Body" ? musclegroup = "Full Body" : musclegroup = "Neck";
                                              break;
                                          }
                                        }
                                      });
                                    },
                                    selectedColor: Colors.deepPurpleAccent,
                                    checkmarkColor: Colors.deepPurpleAccent,
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 5),
                              Divider(),
                            ],
                          );
                        }).toList(),
                        //Finish muscle involved selected buttons
                        SizedBox(height: 15,),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              gravLiftText(text: "Choose exercise type: ", size: 25, ),
                              SizedBox(height: 15,),
                              // isBodyweight row
                              CheckboxListTile(
                                title: gravLiftText(
                                  text: "Bodyweight exercise",
                                  size: 16,
                                  color: isBodyweight == true ? Colors.deepPurpleAccent : Colors.grey,
                                ),
                                value: isBodyweight,
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: Colors.deepPurpleAccent,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 70.0),
                                onChanged: (value) {
                                  setState(() {
                                    isBodyweight = value!;
                                  });
                                },
                              ),
                              // band row
                              CheckboxListTile(
                                title: gravLiftText(
                                  text: "Band Assisted exercise",
                                  size: 16,
                                  color: isBandAssisted == true ? Colors.deepPurpleAccent : Colors.grey,
                                ),
                                value: isBandAssisted,
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: Colors.deepPurpleAccent,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 70.0),
                                onChanged: (value) {
                                  setState(() {
                                    isBandAssisted = value!;
                                  });
                                },
                              ),
                              // iso row
                              CheckboxListTile(
                                title: gravLiftText(
                                  text: "Isometric exercise",
                                  size: 16,
                                  color: isIsometric == true ? Colors.deepPurpleAccent : Colors.grey,
                                ),
                                value: isIsometric,
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: Colors.deepPurpleAccent,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 70.0),
                                onChanged: (value) {
                                  setState(() {
                                    isIsometric = value!;
                                  });
                                },
                              ),
                              // cardio row
                              CheckboxListTile(
                                title: gravLiftText(
                                  text: "Cardio exercise",
                                  size: 16,
                                  color: isCardio == true ? Colors.deepPurpleAccent : Colors.grey,
                                ),
                                value: isCardio,
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: Colors.deepPurpleAccent,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 70.0),
                                onChanged: (value) {
                                  setState(() {
                                    isCardio = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )
            )
          ],
        ),
      )
    );
  }
}

//DIALOG
void discardCustomExDialog(BuildContext contextPage, String exId) {
  //Deletes images in bucket
  showDialog(
    context: contextPage,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Discard changes?", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: const Text('Current custom exercise will be discarded.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Closes the dialog
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String path = "${user_id}_$exId.webp";
              await supabaseClient.storage.from("custom_exercises_pictures").remove([path]); //Wants a list of strings.
              Navigator.pop(context);
              Navigator.pop(contextPage); //Just has to be a value, so root runs setState when receiving it
            },
            child: const Text('Discard'),
          ),
        ],
      );
    },
  );
}
void confirmCustomExDialog(BuildContext contextPage,String name, String exId, bool isBW, bool isCardio, bool isBA, bool isIso, String imageUrl, String muscle_trained, String muscle_group, bool isCustomExercise){

  bool isSubmitLoading = false;
  showDialog(
    context: contextPage,
    builder: (BuildContext context) {
      WorkoutDataManager manager = Provider.of<WorkoutDataManager>(context,listen: false);
      //RETURN A STATEFUL BUILDER, so this dialog has its own setState function, if called in the parent Widget, it rebuilds that, and not dialogbox
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Create custom exercise?', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          actions: [
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isSubmitLoading == true ? null : () async { //If its NULL, it gets deactivated,

                    //Create an exerciseCatalog obj and use a function in the manager
                    List<String> splitName = name.split(" ");
                    String yt_Link = "https://www.youtube.com/results?search_query=";
                    for(String element in splitName){
                      yt_Link = yt_Link + "$element+ "; //Update the search_query every iteration. last has " " at the end.
                    }

                    ExerciseCatalog customExercise = ExerciseCatalog(
                      id: exId.toString(),
                      exercise_name: name,
                      muscle_trained: muscle_trained,
                      muscle_group: muscle_group,
                      how_to: "",
                      yt_link: yt_Link,
                      isBodyweight: isBW,
                      isIsometric: isIso,
                      isBandAssisted: isBA,
                      isCardio: isCardio,
                      exercise_image_filename: imageUrl,
                      isCustomExercise: isCustomExercise,
                    );
                    await manager.createCustomExerciseInDb(customExercise);
                    await manager.reFetchExerciseCatalogList(); //TO show new ex

                    Navigator.pop(context);
                    Navigator.pop(contextPage);

                  },
                  child: const Text('Confirm'),
                ),

              ],
            ),
          ],
        );
    }
  );
}
