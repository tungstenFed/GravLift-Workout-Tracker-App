import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gravlift_workout_tracker_app/WorkoutDataManager%20(changeNotifier)/WorkoutDataManager.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/SkillTreeDirectory/SkillTreeNode.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/SkillTreeDirectory/SkillTreePage.dart';
import 'package:gravlift_workout_tracker_app/pages/templates/widgetsTemplates.dart';
import 'package:provider/provider.dart';

class SkillTreeChooserPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => SkillTreeChooserPageState();

}

class SkillTreeChooserPageState extends State<SkillTreeChooserPage>{
  List<Widget> rowChildren = []; //for every iteration useful to add children to a pre existing row. See below

  Future<List<List<SkillTreeNode>>> futureLoadedSkillList = Future.value([]);

  @override
  void initState() {

    initSkillsList();
    super.initState();
  }

  Future<void> initSkillsList() async {
    WorkoutDataManager manager = Provider.of<WorkoutDataManager>(context, listen:false);
    futureLoadedSkillList =  manager.skillsList;
    return;
  }


  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: futureLoadedSkillList,
        builder: (context, snapshot){
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

          var loadedSkillsList = snapshot.data;

          return Scaffold(
              appBar: AppBar(
                title: gravLiftText(text: "Pick a Skill", size: 15),
              ),
              body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      for (int i = 0; i < loadedSkillsList!.length; i += 2) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [

                              Expanded(
                                child: buildSkillTreeButton(
                                  context,
                                  loadedSkillsList[i],
                                  loadedSkillsList[i][0].main_skill_name,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: (i + 1 < loadedSkillsList.length) //example: last btn is 4th, if 4th+1 = 5th index exists build it, if not a blank widget
                                    ? buildSkillTreeButton(
                                  context,
                                  loadedSkillsList[i + 1],
                                  loadedSkillsList[i + 1][0].main_skill_name,
                                )
                                    : const SizedBox(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  )
              )
          );
        }
    );


  }
  
}

Widget buildSkillTreeButton(BuildContext context, List<SkillTreeNode> skills, String mainSkillName){
  return Expanded(
    child: InkWell(

      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SkillTreePage(skills: skills, mainSkillName: mainSkillName,)));
        SkillTreePage(skills: skills, mainSkillName: mainSkillName);
      },

      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            mainSkillName,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ),
  );
}