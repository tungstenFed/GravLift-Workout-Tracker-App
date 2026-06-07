import 'package:flutter/material.dart';
import 'package:gravlift_workout_tracker_app/WorkoutDataManager%20(changeNotifier)/WorkoutDataManager.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/RootNavigation.dart';
import 'package:gravlift_workout_tracker_app/pages/auth/AuthPage.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//Temporary hardcoding here:
const String url = "https://uaxmydtigrqekvidmzkt.supabase.co";
const String key = "sb_publishable_4dITghu_svJ6q3WD9syKcA_qtL0ALqV";

//supabaseClient is now the current instance client, so by initializing it below, it modies the
//current client, and therefore modifies this variable which refers to it

SupabaseClient supabaseClient = Supabase.instance.client;

void main() async {
  //Main - launches supabase configuration
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza il client Singleton di Supabase: configura l'endpoint (URL) e le
  // credenziali (Key), attiva lo storage nativo per la persistenza della sessione
  // e abilita il supporto al flusso di autenticazione PKCE.
  await Supabase.initialize(url: url, anonKey: key,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, //token in SharedPreferences
    ),);


  //Create a provider object to connect the UI to the changeNotifier class we created
  runApp(
    ChangeNotifierProvider(
      create: (BuildContext context) => WorkoutDataManager(),
      child: const App(), //- Launch auth screen or check if token already exists and skip it
    )
  );


}

//ROOT
class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GravLift Workout Tracker App',
      theme: ThemeData.dark(),
      //Open homepage or auth screen if user session is null
      home: supabaseClient.auth.currentSession == null ? AuthPage() : RootNavigation(pageIndex: 0),
    );
  }
}

