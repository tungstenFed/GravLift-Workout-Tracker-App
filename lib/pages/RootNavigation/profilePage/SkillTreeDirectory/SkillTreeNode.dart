

class SkillTreeNode {

  final String name;
  bool isUnlocked;
  SkillTreeNode? variant;
  final bool is_variant;
  String? parent_name;
  String img_path;
  final String how_to;
  final String requirements;
  String main_skill_name;

  SkillTreeNode({
    required this.name,
    this.isUnlocked = false,
    this.variant,
    this.is_variant = false,
    this.parent_name,
    required this.img_path,
    required this.how_to,
    required this.requirements,
    required this.main_skill_name});

  //TODO await another table that connects to skills table to get what's unlocked and what's not
  factory SkillTreeNode.fromMap(Map<String,dynamic> map){
    return SkillTreeNode(
      name: map["name"],
      how_to: map["how_to"],
      requirements: map["requirements"],
      main_skill_name: map["main_skill_name"],
      img_path: map["img_path"],
      is_variant: map["is_variant"],
      parent_name: map["parent_name"],
      variant: null //Null when created, will be added when fetching the rows with a function in manager
    );
  }

  factory SkillTreeNode.fromJsonMap(Map<String,dynamic> map, ){
    return SkillTreeNode(
        name: map["name"],
        how_to: map["how_to"],
        requirements: map["requirements"],
        main_skill_name: map["main_skill_name"],
        img_path: map["img_path"],
        is_variant: map["is_variant"],
        parent_name: map["parent_name"],
        variant: null //null, built later
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "how_to": how_to,
      "requirements": requirements,
      "main_skill_name": main_skill_name,
      "img_path": img_path,
      "is_variant": is_variant,
      "parent_name": (is_variant == true)
        ? parent_name
        : null,
      //Variant is null
    };
  }

}