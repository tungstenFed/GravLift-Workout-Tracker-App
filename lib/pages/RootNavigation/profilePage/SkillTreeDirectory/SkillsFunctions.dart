import 'package:gravlift_workout_tracker_app/main.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/SkillTreeDirectory/SkillTreeNode.dart';

Future<List<List<SkillTreeNode>>> fetchSkillsList() async {
    try{
      List<Map<String, dynamic>> rawSkills = await supabaseClient.from("skills").select();
      List<SkillTreeNode> allSkills = rawSkills.map((skill) => SkillTreeNode.fromMap(skill)).toList();
      List<SkillTreeNode> allSkillsWithVariants = buildSkillTreeNodesVariants(allSkills);

      List<String> mainSkillNames = getMainSkillNames(allSkillsWithVariants);

      List<   List<SkillTreeNode>   > dividedSkillsByMSN = []; //divided by mainSkillName


      for(var mainSkillName in mainSkillNames){ //for each mainSkillName
        List<SkillTreeNode> temp = [];
        for(var node in allSkillsWithVariants){ //go through each skill
          if(node.main_skill_name == mainSkillName){ //when found add it to temp
            temp.add(node);
          }
        }
        dividedSkillsByMSN.add(temp);
      }

      print("Successfully fecthed skill lists");
      return dividedSkillsByMSN;
    } catch(e) {
      print(e);
      return [];
    }
}

List<SkillTreeNode> buildSkillTreeNodesVariants(List<SkillTreeNode> allSkills){
  List<SkillTreeNode> result = [];

  //Get only the parents in the result and leave the variants aside which will be added later
  result = allSkills.where((element) => element.is_variant == false).toList();

  //Now since every skill's variant isn't created yet, assign them in this for cycle
  for(SkillTreeNode currentNode in allSkills){
    if(currentNode.is_variant == true && currentNode.parent_name != null){
      //Actually modifying result here, when parent name equals variant parentName modify the parent's variant
      var parentNode = result.firstWhere((node) => node.name == currentNode.parent_name);
      parentNode.variant = currentNode;
    }
  }
  return result;
}

List<String> getMainSkillNames(List<SkillTreeNode> allSkills){
  List<String> result = [];
  for(var node in allSkills){
    if(result.contains(node.main_skill_name) == false){
      result.add(node.main_skill_name);
    }
  }
  return result;
}