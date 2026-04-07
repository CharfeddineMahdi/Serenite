import 'package:flutter/material.dart';
import 'package:ami_mobile/features/auth/screens/loginPage.dart'; 

class ConfirmationScreen extends StatefulWidget {
  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFedf9f6),
          image: DecorationImage(
            image: AssetImage('assets/images/greywithOpacity.png'),
            repeat: ImageRepeat.repeat,
            scale: 3.5,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image sans rotation
              Image.asset(
                'assets/images/Logotype-BNA-Assurances-Horizontal.png',
                width: 300.0,
              ),
              SizedBox(height: 20.0),
              Text(
                'Inscription réussie !',
                style: TextStyle(
                  fontSize: 24.0,
                  fontFamily: 'GilmerBold',
                  color: Color(0xFF5230a5),
                ),
              ),
              SizedBox(height: 90.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF009b79),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(0),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                ),
                child: Text(
                  'Se connecter',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontFamily: 'GilmerBold',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}