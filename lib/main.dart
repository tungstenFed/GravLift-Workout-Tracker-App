import 'package:flutter/material.dart';
import 'package:gravlift_workout_tracker_app/WorkoutDataManager%20(changeNotifier)/WorkoutDataManager.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/RootNavigation.dart';
import 'package:gravlift_workout_tracker_app/pages/auth/AuthPage.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/*
  These are AMBIENT VARIABLES, so these 2 aren't exposed to the public on github.
  How it works: Define ambient variables on Android Studio in this case and when the IDE reads
  'String.fromEnvironment("SUPABASE_URL")', it searches env variables and when main is run these fields are completed.
  (Also when building the APK specify through terminal these variables)
  {Not 100% Secure as it's possible to see these variables in the apk going through the binary, but the RLS is what matters.}
*/
const String url = String.fromEnvironment("SUPABASE_URL");
const String key = String.fromEnvironment("SUPABASE_ANON_KEY");


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

