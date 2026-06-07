import 'dart:io';
import 'package:gravlift_workout_tracker_app/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

var imgPicker = ImagePicker();
var placeHolderIcon = Icon(Icons.person, color: Colors.white);

Future<String?> handleImageUpload() async {

  try{
    //Set image file as a variable, compress and upload to supabase
    XFile? fileChosen = await imgPicker.pickImage(source: ImageSource.gallery);
    if(fileChosen == null){print("[DEBUG] no img selected");return null;}

    //Allowed extensions: jpeg jpg png webp (All will turn in webP's)
    String fileExtension = fileChosen.path.split('.').last.toLowerCase().trim();
    print(fileExtension);

    List<String> allowedExtensions = ["jpg", "jpeg", "png", "webp"];
    if(allowedExtensions.contains(fileExtension) == false){
      print("[DEBUG] FILE TYPE NOT SUPPORTED");
      return null;
    }

    File? compressedImage = await compressFileForPfp(fileChosen);
    if(compressedImage == null){print("[DEBUG] ERROR IN COMPRESSION"); return null;}

    String? pfpUrl = await uploadToSupabase(compressedImage);
    return pfpUrl;

  }catch (e){
    print(e);
    if(e is UnsupportedError)
      {return e.message;}
    else if(e is CompressError){
      return e.message;
    }
  }
  return null;
}

Future<File?> compressFileForPfp (XFile file) async{

  //2 different paths because flutter would be trying to read and write on the SAME FILE,AT THE SAME TIME!
  //this ensures there's no conflict.

  String filePath = file.path;
  String targetPath = "${filePath}_compressed.webp";

  //returns nullable XFile
  XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
    filePath,
    targetPath,
    format: CompressFormat.webp,
    quality: 50, //50%
    minHeight: 300,
    minWidth: 300,
  );
  if(compressedFile != null){
    File resultFile = File(compressedFile.path); //Create a file to return

    int sizeInBytes = await compressedFile.length();
    print("Peso finale: ${sizeInBytes / 1024} KB"); //debug check size

    return resultFile;
  }
  else{
    //return null for safety! it cant actually be null if it works.
    return null;
  }



}

Future<String?> uploadToSupabase(File file) async {

  try{
    //give the file a specific name with the user id
    String userId = supabaseClient.auth.currentUser!.id;
    String userIdFilename = "$userId.webp";

    //RLS SQL QUERY HANDLED WITH AI. Users can only upload/insert their own pfp
    //if the file name (userId.webp) matches their userId + '.webp' !
    await supabaseClient.storage.from("profile_pictures").upload(
        userIdFilename,
        file,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true, //makes it so it gets replaced if exists already.
        )
    );
    return supabaseClient.storage.from("profile_pictures").getPublicUrl(userIdFilename);
  }
  catch(e){
    print(e);
    return null;
  }



}