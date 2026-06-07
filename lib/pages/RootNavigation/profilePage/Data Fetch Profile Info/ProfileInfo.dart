class ProfileInfo {
  String user_id;
  String username;
  String bio;
  String email;
  int age;
  String kg_or_lbs;
  String cm_or_inches;
  String km_or_miles;
  String male_female;
  String pfp_url;
  double weight;
  double height;

  ProfileInfo({
    required this.user_id,
    required this.username,
    this.bio = "",
    required this.email,
    required this.age,
    required this.kg_or_lbs,
    required this.cm_or_inches,
    required this.km_or_miles,
    required this.male_female,
    this.pfp_url = "",
    required this.weight,
    required this.height,
  });

  factory ProfileInfo.fromMap(Map<String,dynamic> map){

    map.forEach((key,value){
      print("$key, $value, ${value.runtimeType}");
    });
    return ProfileInfo(
        user_id: map["user_id"],
        username: map["username"],
        bio: map["bio"] ?? "No bio yet.",
        email: map["email"],
        age: map["age"],
        kg_or_lbs: map["kg_or_lbs"],
        km_or_miles: map["km_or_miles"],
        cm_or_inches: map["cm_or_inches"],
        male_female: map["male_female"],
        pfp_url: map["pfp_url"] ?? "noUrl",
        weight: double.parse(map["weight"].toString()), //supabase returns as int, to make it double first it becomes a string -> parse accepts only strings.
        height: double.parse(map["height"].toString()),
    );
  }

}
