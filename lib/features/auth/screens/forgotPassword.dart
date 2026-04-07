import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ami_mobile/services/api_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKeyPhone = GlobalKey<FormState>();
  final _formKeyOtp = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();

  int _currentStep = 0;
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
bool _showPassword = false;
bool _showConfirmPassword = false;
  int _startTimer = 60;
  bool _timerRunning = false;
  Timer? _timer;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    _timerRunning = true;
    _startTimer = 60;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_startTimer > 0) {
        setState(() {
          _startTimer--;
        });
      } else {
        timer.cancel();
        setState(() {
          _timerRunning = false;
        });
      }
    });
  }

  void _nextStep() async {
    try {
      if (_currentStep == 0) {
        String phoneNumber = _phoneNumberController.text;

        if (phoneNumber.isEmpty || phoneNumber.length != 8) {
          Fluttertoast.showToast(
            msg: "Veuillez saisir un numéro de téléphone valide.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Color(0xFF009b79),
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return;
        }

        // Envoyer OTP
        await _apiService.sendOtp(phoneNumber);
        startTimer();
        setState(() {
          _currentStep++;
        });
      } else if (_currentStep == 1) { // Vérifier OTP
        String otp = _otpController.text;

        if (otp.isEmpty || otp.length != 6) {
          Fluttertoast.showToast(
            msg: "Veuillez saisir le code OTP de 6 chiffres.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Color(0xFF009b79),
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return;
        }

        await _apiService.verifyOtp(_phoneNumberController.text, otp);
        setState(() {
          _currentStep++;
        });
      } else if (_currentStep == 2) { 
        if (_formKeyPassword.currentState!.validate()) {
  await _apiService.changePassword(
    _phoneNumberController.text,
    _newPasswordController.text,
    _confirmPasswordController.text, // Add the missing argument here
  );

          Fluttertoast.showToast(
            msg: "Mot de passe changé avec succès.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Color(0xFF009b79),
            textColor: Colors.white,
            fontSize: 16.0,
          );

          Navigator.pop(context);
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString().replaceAll('Exception: ', ''),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Color(0xFF009b79),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneNumberController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50.0),
            Text(
              'Mot de Passe Oublié',
              style: TextStyle(
                color: Color(0xFF009b79),
                fontFamily: 'IBMPlexSansItalic',
                fontSize: 35.0,
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(3, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  width: 10.0,
                  height: 10.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentStep == index
                        ? Color(0xFF009b79)
                        : Color(0xFF04348C),
                  ),
                );
              }),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: _buildStepContent(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep != 3) // Show button only if _currentStep is not 3
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF009b79),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Text(
                      _currentStep == 2 ? 'Terminer' : 'Suivant',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPhoneNumberStep();
      case 1:
        return _buildOtpStep();
      case 2:
        return _buildPasswordStep();
      default:
        return Container();
    }
  }

  Widget _buildPhoneNumberStep() {
    return Form(
      key: _formKeyPhone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Veuillez entrer votre numéro de téléphone.',
            style: TextStyle(fontSize: 16.0, color: Color(0xFF04348C)),
          ),
          SizedBox(height: 10.0), 
          TextFormField(
            controller: _phoneNumberController,
            decoration: InputDecoration(
            labelText: 'Numéro de téléphone',
            suffixIcon:
                Icon(Icons.phone_enabled_outlined, color: Color(0xFF009b79)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(width: 1, color: Color(0xFF04348C)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(width: 1, color: Color(0xFF04348C)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(width: 1, color: Color(0xFF009b79)),
            ),
            contentPadding: EdgeInsets.all(16.0),
          ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez saisir votre numéro de téléphone';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep() {
    return Form(
      key: _formKeyOtp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Un code OTP a été envoyé à votre numéro de téléphone.',
            style: TextStyle(fontSize: 16.0, color: Color(0xFF04348C)),
          ),
          SizedBox(height: 10.0), // Add spacing for better UI
          TextFormField(
            controller: _otpController,
            decoration: InputDecoration(
            labelText: 'Code OTP',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(width: 1, color: Color(0xFF04348C)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(width: 1, color: Color(0xFF04348C)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(width: 1, color: Color(0xFF009b79)),
            ),
            contentPadding: EdgeInsets.all(16.0),
          ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty || value.length != 6) {
                return 'Veuillez saisir un code OTP valide';
              }
              return null;
            },
          ),
          SizedBox(height: 20.0),
          if (_timerRunning)
            Text("Renvoyer OTP dans $_startTimer secondes.")
          else
            TextButton(
              onPressed: () {
                // Renvoie de l'OTP ici
                _nextStep();
              },
              child: Text("Renvoyer OTP"),
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
  return Form(
    key: _formKeyPassword,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Veuillez entrer un nouveau mot de passe.',
          style: TextStyle(fontSize: 16.0, color: Color(0xFF04348C)),
        ),
        SizedBox(height: 10.0), // Add spacing for better UI
        TextFormField(
          controller: _newPasswordController,
          decoration: InputDecoration(
            labelText: 'Nouveau mot de passe',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(width: 1, color: Color(0xFF04348C)),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility : Icons.visibility_off,
                color: Color(0xFF009b79),
              ),
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(width: 1, color: Color(0xFF04348C)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(width: 1, color: Color(0xFF009b79)),
            ),
            contentPadding: EdgeInsets.all(16.0),
          ),
          obscureText: !_showPassword, // Use _showPassword to toggle visibility
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir un nouveau mot de passe';
            }
            return null;
          },
        ),
        SizedBox(height: 10.0),
        TextFormField(
          controller: _confirmPasswordController,
          decoration: InputDecoration(
            labelText: 'Confirmer le mot de passe',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(width: 1, color: Color(0xFF04348C)),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                color: Color(0xFF009b79),
              ),
              onPressed: () {
                setState(() {
                  _showConfirmPassword = !_showConfirmPassword; // Correctly toggle visibility
                });
              },
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(width: 1, color: Color(0xFF04348C)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(width: 1, color: Color(0xFF009b79)),
            ),
            contentPadding: EdgeInsets.all(16.0),
          ),
          obscureText: !_showConfirmPassword, // Use _showConfirmPassword to toggle visibility
          validator: (value) {
            if (value != _newPasswordController.text) {
              return 'Les mots de passe ne correspondent pas';
            }
            return null;
          },
        ),
      ],
    ),
  );
}
}
