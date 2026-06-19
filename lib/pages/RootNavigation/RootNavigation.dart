import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gravlift_workout_tracker_app/WorkoutDataManager%20(changeNotifier)/WorkoutDataManager.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/WorkoutLoggerPage.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/ProfilePage.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/CatalogPage/CatalogPage.dart';
import 'package:gravlift_workout_tracker_app/pages/templates/widgetsTemplates.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/WorkoutLoggerPage/OngoingWorkoutPage.dart';
import 'package:provider/provider.dart';

//This is the rootNavigation which builds  the BOTTOM APPBAR  which its list of pages all share.
//it has an indexedStack which is useful for this matter since it loads up all the pages you give it,
//and keeps them loaded at every time so u easily switch between them. SO all pages will just load the body

//WHEN CALLING EITHER OF THESE PAGES IN PAGES LIST ALWAYS CALL 'ROOT NAVIGATION' OR OTHERWISE THERE WOULD BE NO
//BOTTOM APP BAR

class RootNavigation extends StatefulWidget{
  final int pageIndex;
  const RootNavigation({super.key, this.pageIndex = 0});

  @override
  State<StatefulWidget> createState() => _RootNavigationState();

}

class _RootNavigationState extends State<RootNavigation>{

//makes it so u can decide which page to go to when calling this rootNavigation
  late int pageIndex = widget.pageIndex;

  @override
  initState(){
    super.initState();
    WorkoutDataManager manager = Provider.of<WorkoutDataManager>(context, listen: false);
    //Check for any last active sessions
    manager.loadFromSharedPreferences();

  }
  List<Widget> pagesList = [
    ProfilePage(), // 0
    CatalogPage(), // 1
    WorkoutLoggerPage(), // 2
    //---Add futures pages here---
  ];

  @override
  Widget build(BuildContext context) {

    WorkoutDataManager manager = context.watch<WorkoutDataManager>(); //Make this page watch the provider, rebuilding on notifyListeners()!
    print("rebuilt");

    return Scaffold(

      //The body changes based on the index, so based on the actual page we're showing as it keeps the
      //bottom appbar loaded once.

      body: Stack(
        //Stack to add current workout session floating bar
        children: [
          //-Start Actual Page shown-
            IndexedStack(
            index: pageIndex,
            children: pagesList,
            ),
          //-End Actual Page shown-

          //----ONGOING WS BAR---
          if(( manager.workoutSession != null ? true : false) == true)
           Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            //Container for background and border
             child: Container(
               decoration: ShapeDecoration(
                   shape: RoundedRectangleBorder(
                       side: BorderSide(color: Colors.deepPurpleAccent, width: 0.8),
                       borderRadius: BorderRadiusGeometry.all(Radius.circular(20))
                   ),
               ),

               //Its child is the floating bar
               child: ClipRRect(
                 //Clip rect to "cut" the material widget which is drawn on top of the Container's border, and cuts the edges
                 //this was the material is cut and the border is shown
                 borderRadius: BorderRadius.circular(20),

                 //Material is needed here to make the tiel's splash effect visible
                 child: Material(
                   color: Theme.of(context).scaffoldBackgroundColor, //Theme color, here and not on the container to no get overwritten

                   child: ListTile(
                     leading: const Icon(Icons.fitness_center, color: Colors.deepPurpleAccent, size: 20),
                     title: gravLiftText(text: "Ongoing Workout", size: 19),
                     subtitle: manager.timer,
                     trailing: const Icon(Icons.keyboard_double_arrow_right_outlined, color: Colors.deepPurpleAccent),
                     onTap: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => OngoingWorkoutPage()),
                       );
                     },
                   ),
                 ),
               ),
             )
          ) else SizedBox(), //Blank widget

          //----NO CONNECTION WIDGET---
          if(manager.internetConnection == false)
            Positioned(
                bottom: 90,
                left: 70,
                right: 70,
                child: Container(
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.redAccent, width: 0.8),
                        borderRadius: BorderRadiusGeometry.all(Radius.circular(20))
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Material(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: ListTile(
                        leading: const Icon(Icons.signal_wifi_connected_no_internet_4, color: Colors.redAccent, size: 16),
                        title: gravLiftText(text: "No Internet Connection", size: 14),
                        titleAlignment: ListTileTitleAlignment.center,
                      ),
                    ),
                  ),
                )
            ) else SizedBox() //Blank widget
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        height: 70,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton( //CATALOG ICON BUTTON
                onPressed: () => setState(() {pageIndex = 1;}),
                icon: Icon(Icons.manage_search_sharp),
                iconSize: 40,
                style: IconButton.styleFrom(
                  foregroundColor: pageIndex == 1 ? Colors.deepPurpleAccent : Colors.grey[500],
                  hoverColor: Colors.white10,
                  highlightColor: Colors.white24,
                ),
              ),

              IconButton( //PROFILE PAGE ICON BUTTON
                onPressed: () => setState(() {pageIndex = 0;}),
                icon: Icon(Icons.person_2_outlined),
                iconSize: 40,
                style: IconButton.styleFrom(
                  foregroundColor: pageIndex == 0 ? Colors.deepPurpleAccent : Colors.grey[500],
                  hoverColor: Colors.white10,
                  highlightColor: Colors.white24,
                ),
              ),

              IconButton( //WORKOUT LOGGER PAGE ICON BUTTON
                onPressed: () => setState(() {pageIndex = 2;}),
                icon: Icon(Icons.event_note_outlined),
                iconSize: 40,
                style: IconButton.styleFrom(
                  foregroundColor: pageIndex == 2 ? Colors.deepPurpleAccent : Colors.grey[500],
                  hoverColor: Colors.white10,
                  highlightColor: Colors.white24,
                ),
              ),
            ],
          )
      ),
    );
  }
}