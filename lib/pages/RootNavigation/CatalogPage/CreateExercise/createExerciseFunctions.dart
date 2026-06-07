
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gravlift_workout_tracker_app/main.dart';
import 'package:gravlift_workout_tracker_app/pages/auth/authFunctions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

ImagePicker imgPicker = ImagePicker();

Future<String?> handleCustomExPicUpload(String exerciseId) async {
  XFile? fileChosen = await imgPicker.pickImage(source: ImageSource.gallery);
  if(fileChosen==null){print("No img selected"); return null;}

  String fileExtension = fileChosen.path.split(".").last.toLowerCase().trim();
  //Check extensions
  List<String> allowedExtensions = ["jpg","jpeg","webp","png"];
  if(allowedExtensions.contains(fileExtension) == false ){
    print("Wrong file extension"); return null;
  }
  File? compressedImage = await compressImage(fileChosen);
  String? publicStorageUrl = await uploadToDb(compressedImage, exerciseId);
  return publicStorageUrl;

}

Future<File?> compressImage(XFile fileChosen) async {
  String path = fileChosen.path;
  String targetPath = "${fileChosen.path}_compressed.webp";

  XFile? compressedImg = await FlutterImageCompress.compressAndGetFile(
    path,
    targetPath,
    minWidth: 300,
    minHeight: 300,
    quality: 50,
    format: CompressFormat.webp
  );

  if(compressedImg == null){print("Error during compression, return null"); return null;}
  File? file = File(compressedImg.path);
  return file;
}

Future<String?> uploadToDb(File? file, String exerciseId) async {
  try{
    if(file != null){
      String uniquePath = "${user_id}_${exerciseId}.webp"; //unique path per user and per exercise.

      await supabaseClient.storage.from("custom_exercises_pictures").upload(
        uniquePath,
        file,
        fileOptions: FileOptions(
          cacheControl: "3600",
          upsert: true,
        )
      );
      return supabaseClient.storage.from("custom_exercises_pictures").getPublicUrl(uniquePath);
    }
  } catch(e){
    print(e);
    return null;
  }
}