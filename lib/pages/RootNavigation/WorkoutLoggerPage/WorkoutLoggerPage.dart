import 'package:flutter/material.dart';
import 'package:gravlift_workout_tracker_app/WorkoutDataManager%20(changeNotifier)/WorkoutDataManager.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/CreateRoutinePage.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/OngoingWSDialogs.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/Workout%20Classes/WorkoutSession.dart';
import 'package:gravlift_workout_tracker_app/pages/templates/widgetsTemplates.dart';
import 'package:provider/provider.dart';
import 'OngoingWorkoutPage.dart';

class WorkoutLoggerPage extends StatefulWidget {
  const WorkoutLoggerPage({super.key});

  @override
  State<StatefulWidget> createState() => _WorkoutLoggerPageState();
}

class _WorkoutLoggerPageState extends State<WorkoutLoggerPage> {

  Future<List<WorkoutSession>?>? routines; //? to prevent init. error

  Future<void> loadRoutines() async {
    WorkoutDataManager manager = Provider.of<WorkoutDataManager>(context, listen: false);
    routines = manager.routines;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<WorkoutDataManager>();
    loadRoutines();
    WorkoutDataManager manager = Provider.of<WorkoutDataManager>(context, listen: false);

    return FutureBuilder(
      future: routines,
      builder: (context, snapshot){
        // Error case
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("${snapshot.error}")),
          );
        }

        // If data is being fetched, return loading animation
        if (snapshot.hasData == false) {
          return Scaffold(
              body: Center(child: Column(children: [const SizedBox(height: 300,), const CircularProgressIndicator.adaptive(), gravLiftText(text: "Loading History", size: 20)]),)
          );
        }

        List<WorkoutSession>? routinesData = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: gravLiftText(text: "Log your workout", size: 26),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  gravLiftText(text: "Empty Workout", size: 22),
                  const SizedBox(height: 15),

                  // Empty workout button - made by me
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline_outlined, color: Colors.deepPurpleAccent, size: 30,),
                    title: gravLiftText(text: "Start Empty Workout", size: 19, color: Colors.deepPurpleAccent),
                    subtitle: Text(
                      "Select exercises and quickly start a workout.\n",
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    trailing: const Icon(Icons.keyboard_arrow_right_outlined, color: Colors.deepPurpleAccent, size: 40,),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        side: BorderSide(color: Colors.deepPurpleAccent, width: 0.8)
                    ),
                    tileColor: Colors.grey.withValues(alpha: 0.1), //same as withOpacity
                    onTap: ()  {
                      if(manager.workoutSession == null) { // when pressing this if session is active, dialog box and if yes scrap current ws and start another one
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const OngoingWorkoutPage()
                            )
                        );
                      }
                      else {
                        gravLiftReplaceWorkoutSession(context, false);
                      }
                    },
                  ),

                  const SizedBox(height: 40),
                  gravLiftText(text: "Routines", size: 22),
                  const SizedBox(height: 15),

                  // -----ROUTINES-----
                  ListTile(
                    leading: const Icon(Icons.inventory_outlined, color: Colors.deepPurpleAccent, size: 30,),
                    title: gravLiftText(text: "Create A Workout Routine", size: 16, color: Colors.deepPurpleAccent),
                    subtitle: Text(
                      "Create a routine to quickly start a workout session.\n",
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    trailing: const Icon(Icons.keyboard_arrow_right_outlined, color: Colors.deepPurpleAccent, size: 40,),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        side: BorderSide(color: Colors.deepPurpleAccent, width: 0.8)
                    ),
                    tileColor: Colors.grey.withValues(alpha: 0.1), //same as withOpacity
                    onTap: ()  {
                      if(manager.workoutSession == null) { //Scrap the ongoing ws so it doesn't conflict
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CreateRoutinePage()
                            )
                        );
                      } else {
                        gravLiftReplaceWorkoutSession(context, true);
                      }
                    },
                  ),

                  manager.internetConnection 
                    ? ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1,),
                      itemCount: routinesData?.length ?? 0,
                      itemBuilder: (context, index) {
                        WorkoutSession? routine = routinesData?[index];
                        if(routine != null){
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.fitness_center_rounded,
                                color: Colors.deepPurpleAccent,
                                size: 22,
                              ),
                            ),
                            title: Text(
                              routine.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${routine.exercisesList.length} exercise/s.",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurpleAccent,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.keyboard_arrow_right_rounded, color: Colors.grey[600], size: 20),
                              ],
                            ),
                            onTap: () {//TODO
                            },
                          );
                        }
                        return const SizedBox();
                      }
                  )
                : Padding(padding: EdgeInsetsGeometry.all(10), child: Text("Internet connection necessary to load routines.",
                      style: TextStyle(color: Colors.white70))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}