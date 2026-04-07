import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ami_mobile/features/reclamation/screens/ReclamationScreen.dart';
import 'package:ami_mobile/features/simulateurs/screens/SimulateurPage.dart';
import 'package:ami_mobile/features/simulateurs/screens/SimulateursPage.dart';
import 'package:ami_mobile/features/auth/screens/forgotPassword.dart';

import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import "features/auth/screens/loginPage.dart";
Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          GradientScreen(),
          MyAppLogoAnimation(), 
        ],
      ),
       routes: {
        '/login': (context) => LoginPage(),
        '/forgotPassword': (context) => ForgotPasswordPage(),
        '/simulateur': (context) => SimulateurPage(),
        '/simulateurs': (context) => SimulateursPage(),
        '/reclamations': (context) => ReclamationScreen(),
       
      },
    );
  }
}

class GradientScreen extends StatelessWidget {
  const GradientScreen({Key? key});

  /* @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
           colors: [
              Color(0xFF009b79),
               Color(0xFF1c3f93), 
              Color(0xFF5230a5),
            ],
          ),
        ),  
      ),
    );
  } */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Page 1.png'),
            fit: BoxFit.cover, 
          ),
        ),
      ),
    );
  }
}


class MyAppLogoAnimation extends StatelessWidget {
  const MyAppLogoAnimation({Key? key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: const LogoAnimation(), 
      nextScreen: const LoginPage(), 
      duration: 8000, 
      splashTransition: SplashTransition.fadeTransition, 
      pageTransitionType: PageTransitionType.rightToLeft, 
      backgroundColor: Colors.transparent, 
    );
  }
}

class LogoAnimation extends StatelessWidget {
  const LogoAnimation({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 3.5, 
          heightFactor: 3.5, 
          child: Image.asset(
            "assets/images/LogoBNA_BLANC.png",
            fit: BoxFit.contain, // Ajuster la taille de l'image pour s'adapter au FractionallySizedBox
          ),
        ),
      ),
    );
  }
}


class SecondScreen extends StatelessWidget {
  const SecondScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber, // Couleur d'arrière-plan de l'écran suivant
      body: Center(
        child: Text(
          "Second Screen",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
