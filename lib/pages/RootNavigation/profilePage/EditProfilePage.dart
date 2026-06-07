import 'dart:io';
import 'package:gravlift_workout_tracker_app/WorkoutDataManager%20(changeNotifier)/WorkoutDataManager.dart';
import 'package:gravlift_workout_tracker_app/main.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/RootNavigation.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/Data%20Fetch%20Profile%20Info/ProfileInfo.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/Data%20Fetch%20Profile%20Info/fetchProfileInfo.dart';
import 'package:gravlift_workout_tracker_app/pages/templates/widgetsTemplates.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pfpFunctions.dart';

class EditProfilePage extends StatefulWidget {
  final bool justSignedUp;
  const EditProfilePage({super.key, this.justSignedUp = false});
  @override
  State<StatefulWidget> createState() => _EditProfilePageState();

}

class _EditProfilePageState extends State<EditProfilePage>{

  @override
  void initState() { //fetch user id and username to check if already exists
    super.initState();
    //If the user comes from the Edit button on profile page, load his current profile picture
    if(!widget.justSignedUp){fetchPfpUrl();}

  }
  //--- VARIABLES

  String? kgOrLbs = 'kg';
  String? cmOrInch = 'cm';
  String? kmOrMile = 'km';
  String? bio = '';
  String username = '';
  int age = 0; //no  null
  double weight = 0;
  double height = 0;
  String? maleOrFemale = 'male';
  bool exceptionTriggered = false;
  int maxUsernameChars = 12; int minUsernameChars = 4; int maxUsernameUnderscore = 2;
  int maxUsernameDots = 1; int maxBioChars = 100; int maxBioLines = 4;
  String? exceptionMessage = "";
  String? imgPickedUrl = "";
  final ScrollController _scrollController = ScrollController();
  //---

  void fetchPfpUrl() async {
    WorkoutDataManager manager = Provider.of<WorkoutDataManager>(context, listen: false);
    ProfileInfo profileInfo = await manager.profileInfo;
    imgPickedUrl = profileInfo.pfp_url;
    setState(() {});
  }
  void checkUniqueUsername(String username) async {
    try{
      print(supabaseClient.auth.currentUser?.email);
      Map<String,dynamic> fetchedExistingUsernameRow = await supabaseClient.from("profiles")
          .select().eq("username", username).single();
      //if successful: username exists
      setState(() {
        exceptionMessage = "Username already taken, try another."; exceptionTriggered = true;
      });
    } catch(e){
      print(e);
      setState(() {
        //else clear
        exceptionMessage = ""; exceptionTriggered = false;
      });
    }
  }
  //usernamePolicies for better overall code readability. (Just ifs and else ifs)
  void textFieldPolicies(String value, isUsernameTextField) {

    if(isUsernameTextField)
    {
      //MAX & MIN CHARS
      if(value.length > maxUsernameChars || value.length < minUsernameChars)
      {exceptionMessage="Max Username length is $maxUsernameChars, Min is $minUsernameChars"; exceptionTriggered = true;}

      //MAX .  & _
      else if(value.split('.').length - 1 > 1 || value.split('_').length - 1 > 2)//splits and counts amount
          {exceptionMessage="Max ' . ' is 1 | Max ' _ ' is 2"; exceptionTriggered = true;}

      //AT LEAST 1 LETTER
      else if(value.contains(RegExp(r'[a-zA-Z]')) == false)
      {exceptionMessage="Username must contain at least 1 letter"; exceptionTriggered = true;}

      //UNIQUE USERNAME handled in func above

      //If everything's right
      else if(value.length <= maxUsernameChars &&
          value.length >= minUsernameChars &&
          (value.split('.').length - 1 < 1 || value.split('_').length - 1 < 2) &&
          (value.contains(RegExp(r'[a-zA-Z]')) == true) ) //user taken is handled in function above
          {
        exceptionTriggered = false; exceptionMessage = "";
      }
    }
    else{
      if(value.length > maxBioChars){exceptionTriggered=true; exceptionMessage="Max Bio lenght is 100 characters.";}
      else if(value.length <= maxBioChars){exceptionTriggered=false;   exceptionMessage="";}
    }
  }
  void scrollToTop(){_scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.bounceInOut);}

  @override
  Widget build(BuildContext context)
  {
    WorkoutDataManager manager = Provider.of<WorkoutDataManager>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 88),
            child: Text(
            //using widget.x i can access the main widget's parameters
              widget.justSignedUp == false  ? "Edit your GravLift Profile" : "Welcome to GravLift. Set up your Profile.",
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            gravLiftText(text: "Profile Picture", size: 25), Container(height: 5,),
            Stack(
              children: [
                CircleAvatar(
                  radius: 100,

                  foregroundImage: imgPickedUrl == null || imgPickedUrl == ""
                    ? AssetImage("assets/images/avatar.jpg")
                  /*
                    Added ?=t... to modify the url so it's different everytime its created, because
                    if it isn't added, the pfp isn't updated since flutter sees 2 same urls when you upload
                    2 different images, since the PATH of the image when uploaded to supabase is the same regardless of the
                    fle name (its always userId + .webp).

                    [if flutter sees 2 same urls, he ignored the second thinking he already loaded it!]
                  */
                    : NetworkImage('$imgPickedUrl?t=${DateTime.now().millisecondsSinceEpoch}'),
                  backgroundColor: Colors.black,
                  child: placeHolderIcon,
                ),
                //change icon
                Positioned(
                  width: 60,
                  height: 60,
                  top: 150,
                  right: 0,
                  child: IconButton(
                    icon: Image.asset('assets/images/changes.png'),

                    onPressed: () async {

                        var url = await handleImageUpload();
                        setState(() {
                          url == null
                              ? exceptionTriggered = true
                              : exceptionTriggered = false;
                          url == null
                              ? exceptionMessage = "Error during image upload/Unsupported file type."
                              : exceptionMessage = "";
                        });
                        setState((){imgPickedUrl = url;});
                    }

                  ),
                )
              ],
            ), Container(height: 10,),
            //Exception Messages
            gravLiftExceptionText(exceptionTriggered == false ? "" : exceptionMessage),

            //USERNAME
            gravLiftText(text: "Username", size: 20),
            gravLiftTextField(
              hint: "Username",
              icon: Icons.drive_file_rename_outline,
              restrictiveTextField: true,

              onChanged: (value) {
                username = value;
                setState(() {
                  textFieldPolicies(value, true);
                });
              },
            ),
            Container(height: 15,),

            //BIO
            gravLiftText(text: "Bio", size: 20),
            gravLiftTextField(
                hint: "Bio",
                icon: Icons.drive_file_rename_outline,
                onSubmitted: (value) {
                  bio = value;
                  setState(() {
                    textFieldPolicies(value, false);
                  });
                },
                keyboardType: TextInputType.multiline, //expands
                restrictiveTextField: false,
                maxLines: maxBioLines,
              onChanged: (value){bio=value;}
            ),
            Container(height: 15,),

            //KG OR LBS + INPUT
            Row(children: [
              Container(width: 80),
              gravLiftText(text: "Current Weight Unit ", size: 20),
              Container(width: 15,),
              DropdownButton(
                items: [
                    DropdownMenuItem(value: "kg", child: Text("Kg")),
                    DropdownMenuItem(value: "lbs", child: Text("Lbs")),
                  ],
                onChanged: (value){ kgOrLbs = value;    setState(() {});      },
                hint: Text(kgOrLbs!)
              ),
            ],
            ),
            gravLiftTextField(
                hint: "Weight",
                icon: Icons.scale,
                onChanged: (value) {
                  weight = double.parse(value);
                  },
              restrictiveTextField: false,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            Container(height: 15,),

            //AGE
            gravLiftText(text: "Age ", size: 20),
            gravLiftTextField(
              hint: "Age",
              icon: Icons.watch,
              onChanged: (value) {
                age = int.parse(value);
              },
              restrictiveTextField: false,
              keyboardType: TextInputType.numberWithOptions(decimal: false),
            ),
            Container(height: 15,),

            //GENDER
            Row(children: [
              Container(width: 130),
              gravLiftText(text: "Gender ", size: 20),
              Container(width: 15,),
              DropdownButton(
                  items: [
                    DropdownMenuItem(value: "male", child: Text("Male")),
                    DropdownMenuItem(value: "female", child: Text("Female")),
                  ],
                  onChanged: (value){ maleOrFemale = value;    setState(() {});      },
                  hint: Text(maleOrFemale!)
              ),
            ],
            ),

            //cm OR inch + INPUT
            Row(children: [
              Container(width: 50),
              gravLiftText(text: "Body Measurement Unit ", size: 20),
              Container(width: 15,),
              DropdownButton(
                  items: [
                    DropdownMenuItem(value: "cm", child: Text("Cm")),
                    DropdownMenuItem(value: "inch", child: Text("Inch")),
                  ],
                  onChanged: (value){ cmOrInch = value;    setState(() {});      },
                  hint: Text(cmOrInch!)
              ),
            ],
            ),
            gravLiftTextField(
              hint: "Height",
              icon: Icons.scale,
              onChanged: (value) {
                height = double.parse(value);
              },
              restrictiveTextField: false,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            Container(height: 15,),

            //kmg OR mile + INPUT
            Row(children: [
              Container(width: 120),
              gravLiftText(text: "Distance Unit ", size: 20),
              DropdownButton(
                  items: [
                    DropdownMenuItem(value: "km", child: Text("Kms")),
                    DropdownMenuItem(value: "mile", child: Text("Miles")),
                  ],
                  onChanged: (value){ kmOrMile = value;    setState(() {});      },
                  hint: Text(kmOrMile!)
              ),
            ],
            ),
            Container(height: 10,),
            gravLiftFabExt(
                onPressed: () async {
                  if(username == "" || weight == 0 || height == 0 || age == 0){
                    setState((){exceptionTriggered = true; exceptionMessage = "Please fill out all fields.";});
                    scrollToTop();
                  } else if(!exceptionTriggered) {
                    setState((){exceptionTriggered = false; exceptionMessage = "";});
                    //UPDATE and not INSERT, not creating a new row but we're updating it.(Already created in signup, fill out null values
                    //Also if editing later on profile it has to be actually UPDATE
                    String userId = supabaseClient.auth.currentUser!.id;
                    await supabaseClient.from("profiles").update({
                      "username": username,
                      "age": age,
                      "bio": bio,
                      "kg_or_lbs": kgOrLbs,
                      "cm_or_inches": cmOrInch,
                      "km_or_miles": kmOrMile,
                      "male_female": maleOrFemale,
                      "pfp_url": imgPickedUrl,
                    }).eq("user_id", userId); //specify which user

                    //in this case we create the rows right here so we're gonna upsert, if exists update else create.
                    await supabaseClient.from("profiles_stats").upsert({
                          "user_id": userId,
                          "weight": weight,
                          "height": height
                    });

                    manager.reFetchProfileInfo();

                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => RootNavigation(pageIndex: 0,)),
                        (route) => false //REMOVES all pages in the stack, pushAndRemoveUntil expects 3 args
                    );
                  }
                } ,
                label: widget.justSignedUp == false ? "Update Profile" : "Create Profile"
            ),
            Container(height: 80),

          ],
        ),
      ),
    );
  }
}