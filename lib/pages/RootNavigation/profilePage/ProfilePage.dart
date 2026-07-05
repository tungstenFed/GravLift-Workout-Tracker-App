import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gravlift_workout_tracker_app/WorkoutDataManager%20(changeNotifier)/WorkoutDataManager.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/OngoingWSDialogs.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/OngoingWorkoutPage.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/Workout%20Classes/WorkoutSession.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/Data%20Fetch%20Profile%20Info/ProfileInfo.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/HistoryInfoPage.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/SkillTreeDirectory/SkillTreeChooserPage.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/SkillTreeDirectory/SkillTreePage.dart';
import 'package:gravlift_workout_tracker_app/pages/templates/widgetsTemplates.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/EditProfilePage.dart';
import 'package:provider/provider.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/SkillTreeDirectory/SkillTreePage.dart';



//temporary class to remove error detection in main.dart
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<StatefulWidget> createState() => _ProfilePageState();

}
class _ProfilePageState extends State<ProfilePage> {

  Future<List<dynamic>>? combinedFutures; //? to prevent null error
  Future<ProfileInfo>? profileInfoFuture;
  Future<int>? numberWorkoutSessions;
  Future<List<WorkoutSession>?>? history;
  String sharedPrefPfpPath = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    WorkoutDataManager manager = Provider.of<WorkoutDataManager>(context, listen: false);

    //we want multiple future variables but future builder has 1 parameter, so we're gonna create a list of futures using 'Future.wait()'
    //this function creates a list of futures and completes it only when all the futures are completed.
    //Future.wait() wants a list as argument.
    combinedFutures = Future.wait([
      
        //If i put 'await' here it wants a 'ProfileInfo' instead of the current Future<ProfileInfo>.
        profileInfoFuture = manager.profileInfo, //INDEX for snapshot.data = 0
        numberWorkoutSessions = manager.numWorkoutSession, //INDEX for snapshot.data = 1
        history = manager.history, //INDEX for snapshot.data = 2
      ]
    );
    sharedPrefPfpPath = await manager.loadPfpFromSharedPref();
  }

  @override
  Widget build(BuildContext context) {

    WorkoutDataManager manager = Provider.of<WorkoutDataManager>(context, listen: false);
    context.watch<WorkoutDataManager>(); //Make this widget a listener, rebuilt on notify listeners (to upd history + nWSs )
    print("----[DEBUG]---- PROFILE PAGE REBUILT WATCH");
    loadData(); //On rebuild of this page loadData and get the latest data from the manager. The manager's initialized history is updated within the ?'Confirm' btn in OnGoingWorkoutPage

    return FutureBuilder<List<dynamic>>( //between the <> goes the type of variable in 'future:' argument.
      future: combinedFutures,
      builder: (context, snapshot) {
        // Error case
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("${snapshot.error}")),
          );
        }

        // If data is being fetched, return loading animation
        if (snapshot.hasData == false) {
          return Scaffold(
            body: Center(child: Column(children: [SizedBox(height: 300,), CircularProgressIndicator.adaptive(), gravLiftText(text: "Loading History", size: 20)]),)
          );
        }

        // If data is successfully fetched, assign it
        ProfileInfo profileInfo = snapshot.data![0];
        int numberWorkoutSessions = snapshot.data![1];
        List<WorkoutSession>? history = snapshot.data?[2];

        //app
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
                  profileInfo.username,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.boldonse(
                    fontSize: 20
                ),
              ),
            actions: [
              TextButton.icon( //EDIT
                onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfilePage())
                  );
                },
                  label: gravLiftText(text: "Edit", size: 20, color: Colors.deepPurpleAccent),
                  icon: Icon(Icons.edit, color: Colors.deepPurpleAccent,),
              ),
              Icon(Icons.settings, color: Colors.white),
            ],
          ),

          drawer: Drawer(
            child: Padding(
              padding: EdgeInsetsGeometry.all(15),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 40,),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.coffee, size: 25,),
                      label: const Text("Donate via Patreon ❤️", style: TextStyle(fontSize: 19),),
                      onPressed: () {
                        manager.openExternalLink("https://www.patreon.com/cw/tungstenFed"); //Patreon link url
                      },
                    ),
                  ],
                )
              )
            ),
          ),

          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0), // Main page padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Ensures everything starts from the left
              children: [
                // --- PROFILE HEADER (No Card) ---
                Row(    // Row 1: Avatar and Primary Info
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.black,
                      foregroundImage:
                          manager.internetConnection == true
                            ? (profileInfo.pfp_url == "")
                                ? AssetImage("assets/images/avatar.jpg")
                                : NetworkImage('${profileInfo.pfp_url}?t=${DateTime.now().millisecondsSinceEpoch}')
                            : (sharedPrefPfpPath.isNotEmpty)
                              ? FileImage(File(sharedPrefPfpPath))
                              : AssetImage("assets/images/avatar.jpg"),

                    ),
                    SizedBox(width: 20),
                    Expanded(child: Column( //Expanded prevents overflowing on the right
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Athlete: ${profileInfo.username}.",
                          style: GoogleFonts.aleo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.fitness_center, size: 20, color: Colors.deepPurpleAccent),
                            SizedBox(width: 8),
                            gravLiftText(text:
                              manager.internetConnection
                                ?"$numberWorkoutSessions Workouts"
                                : "Connection Error",
                                size: 17),
                          ],
                        ),
                        SizedBox(height: 15),
                        Container(child: gravLiftText(text: profileInfo.bio, size: 10)),
                      ],
                    )),
                  ],
                ),

                SizedBox(height: 15), // Spacing instead of a Divider

                // Row 2: Biometric Data (Weight and Height)
                // Since the card is gone, we can align these to the left or keep them spread
                Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Aligning to the left for a cleaner flat look
                  children: [
                    // Weight Display
                    Icon(Icons.scale, size: 18, color: Colors.grey),
                    SizedBox(width: 5),
                    Text(
                      "Weight: ${profileInfo.weight} ${profileInfo.kg_or_lbs}",
                      style: TextStyle(color: Colors.white70),
                    ),
                    Spacer(), // Gap between weight and height
                    // Height Display
                    Icon(Icons.height, size: 18, color: Colors.grey),
                    SizedBox(width: 5),
                    Text(
                      "Height: ${profileInfo.height} ${profileInfo.cm_or_inches}",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),

              //PROGRESSION TREE DASHBOARD
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SkillTreeChooserPage()),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent[600], // Sfondo grigio scuro della dashboard
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white70, // Sottile bordo per dare profondità
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Icona semplice stile Dashboard
                          Icon(
                            Icons.account_tree_outlined,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              "Calisthenics Skills \nProgression Trees",
                              style: TextStyle(
                                color: Colors.grey[300], // Grigio chiaro, pulito
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),

                          // Una piccola freccia discreta sulla destra (opzionale, ma fa molto "dashboard")
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.deepPurpleAccent[600],
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Center(child: gravLiftText(text: "Workout Sessions", size: 20,)),
                Divider(color: Colors.white10),

              ////If user hasn't worked out show button to start empty ws
              numberWorkoutSessions == 0
              ? Column(
                    children: [
                      Text(
                          manager.internetConnection==true
                            ?"No workout sessions yet!"
                            :"Internet connection necessary to load workout sessions.",
                          style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 20,),
                      // Empty workout button only if internet connection
                      manager.internetConnection==true
                      ? ListTile(
                          leading: Icon(Icons.add_circle_outline_outlined, color: Colors.deepPurpleAccent, size: 25,),
                          title: gravLiftText(text: "Start Empty Workout", size: 17, color: Colors.deepPurpleAccent),
                          trailing: Icon(Icons.keyboard_arrow_right_outlined, color: Colors.deepPurpleAccent, size: 35,),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
                              side: BorderSide(color: Colors.deepPurpleAccent, width: 0.8)
                          ),
                          tileColor: Colors.grey.withValues(alpha: 0.1), //same as withOpacity
                          onTap: ()  {
                            if(manager.workoutSession == null) { // when pressing this if session is active, dialog box and if yes scrap current ws and start another one
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OngoingWorkoutPage()
                                  )
                              );
                            }
                            else {
                              gravLiftReplaceWorkoutSession(context, false);
                            }
                          },
                        )
                      : SizedBox(),
                    ]
                 )
              //ELSE, show the past ws
              : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1,),
                    itemCount: history?.length ?? 0, //It'll never be show if it's loading, but don't show anything if there's no WS's
                    itemBuilder: (context,index) {
                      if (history!.isEmpty) {
                        //If user hasn't worked out show button to start empty ws
                        return Column(
                          children: [
                            Text("No workout sessions yet!", style: TextStyle(color: Colors.white70)),
                            SizedBox(height: 20,),
                            // Empty workout button
                            ListTile(
                              leading: Icon(Icons.add_circle_outline_outlined, color: Colors.deepPurpleAccent, size: 30,),
                              title: gravLiftText(text: "Start Empty Workout", size: 19, color: Colors.deepPurpleAccent),
                              subtitle: Text(
                                "Select exercises and quickly start a workout.\n",
                                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              ),
                              trailing: Icon(Icons.keyboard_arrow_right_outlined, color: Colors.deepPurpleAccent, size: 40,),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
                                side: BorderSide(color: Colors.deepPurpleAccent, width: 0.8)
                              ),
                              tileColor: Colors.grey.withValues(alpha: 0.1), //same as withOpacity
                            )
                          ]
                        );
                      }
                      else if(history[index] != null) {
                        //At this point it can't be null
                        final session = history[index];
                        //Date format
                        String formattedDate = "${session.created_time!.day}/${session.created_time!.month}/${session.created_time!.year} - d/m/y";
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

                          //1. Leading
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.deepPurpleAccent.withValues(
                                alpha: 0.1),
                            child: const Icon(
                              Icons.fitness_center_rounded,
                              color: Colors.deepPurpleAccent,
                              size: 22,
                            ),
                          ),

                          // 2. Title
                          title: Text(
                            session.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // 3. Date
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),

                          // 4. Trailing
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min, //Needed not to crash overflow
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Ex number
                                  Text(
                                    "${session.exercisesList.length} exercise/s.",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurpleAccent,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // Duration
                                  Text(
                                    _calcWSDuration(session.start_time!, session.end_time!),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.keyboard_arrow_right_rounded,
                                  color: Colors.grey[600], size: 20),
                            ],
                          ),


                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HistoryInfoPage(session: session))
                            );
                          },
                        );
                      }
                      else{ return null;}
                    },
                ),


              ],
            ),
          ),
        );
      },
    );
  }

  String _calcWSDuration(DateTime startTime, DateTime endTime){
    Duration difference = endTime.difference(startTime);
    return "${difference.inHours}h:${difference.inMinutes}m:${difference.inSeconds}s";
  }
}
