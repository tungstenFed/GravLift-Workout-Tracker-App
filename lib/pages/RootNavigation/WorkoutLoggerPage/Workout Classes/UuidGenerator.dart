import 'package:uuid/uuid.dart';
//For each exercise object to give supabase it is needed to generate a uuid so there's no problems when uploading to supabase
//and keeps track of that which exercise's set is which...

class UuidGenerator {
  static Uuid id = Uuid(); //Generates a uuid for supabase Uuid object

  static String generate(){
    return id.v4(); //Supabase needs v4
  }
}