import 'dart:async';

import 'package:ami_mobile/features/auth/screens/confirmationScreen.dart';
import 'package:ami_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  int _currentStep = 0;
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
TextEditingController _confirmPasswordController = TextEditingController();
bool _showPassword = false;
bool _showConfirmPassword = false;

  int _startTimer = 60; 
  bool _timerRunning = false; 
  Timer? _timer; 

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

  final ApiService _apiService = ApiService();
  void _nextStep() async {
    try {
      if (_currentStep == 0) {
        String phoneNumber = _phoneNumberController.text;
        if (phoneNumber.isEmpty) {
          Fluttertoast.showToast(
            msg: "Veuillez saisir votre numéro de téléphone.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Color(0xFF009b79),
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return;
        } else if (phoneNumber.length != 8 ||
            !RegExp(r'^[0-9]{8}$').hasMatch(phoneNumber)) {
          Fluttertoast.showToast(
            msg: "Le numéro de téléphone doit être composé de 8 chiffres.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
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
      } else if (_currentStep == 1) {//VeriF otp
        String otp = _otpController.text;
        if (otp.isEmpty || otp.length != 6) {
          Fluttertoast.showToast(
            msg: "Veuillez saisir le code OTP de 6 chiffres.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Color(0xFF009b79),
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return;
        }
        try {
          await _apiService.verifyOtp(_phoneNumberController.text, otp);
          setState(() {
            _currentStep++;
          });
        } catch (e) {
          Fluttertoast.showToast(
            msg: e.toString().replaceAll('Exception: ', ''),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Color(0xFF009b79),
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return;
        }
      } else if (_currentStep == 2) {//Fomulaire
        if (_formKey.currentState!.validate()) {
          setState(() {
            _currentStep++;
          });
        }
      } else if (_currentStep == 3) {
        if (_formKey2.currentState!.validate()) {
        await _apiService.completeRegistration(
          _phoneNumberController.text,
          _usernameController.text,
          _emailController.text,
          _prenomController.text,
          _dateController.text,
          _nameController.text,
          _cinController.text,
          _passwordController.text,
        );

        setState(() {
          _currentStep++;
        });
        } else { print ('erreur');}
      
      }
    } catch (e) {
      print('Error during next step: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text(
                'Impossible de se connecter au serveur. Veuillez réessayer plus tard.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  /* void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  } */

  void _submitForm() {
    print('Nom: ${_nameController.text}');
    print('Prénom: ${_prenomController.text}');
    print('Email: ${_emailController.text}');
    print('Date de naissance: ${_dateController.text}');
    print('CIN: ${_cinController.text}');
    print('Login: ${_usernameController.text}');
    print('Mot de passe: ${_passwordController.text}');

    _nextStep();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dateController.dispose();
    _phoneNumberController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Color(0xFF1c3f93), 
          colorScheme: ColorScheme.light(
            primary: Color(0xFF1c3f93), 
            onSurface: Color(0xFF5230a5), 
          ),
          dialogBackgroundColor: Color(0xFFbbeadf), 
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF1c3f93), 
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    setState(() {
      _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFedf9f6),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50.0),
            Text(
              'Inscription',
              style: TextStyle(
                color: Color(0xFF1c3f93),
                fontFamily: 'GilmerBold',
                fontSize: 40.0,
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(4, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  width: 10.0,
                  height: 10.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentStep == index
                        ? Color(0xFF009b79)  
                        : Color(0xFF1c3f93),
                  ),
                );
              }),
            ),
            SizedBox(height: 20.0),
            if (_currentStep == 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Veuillez entrer votre numéro de téléphone.',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFF1c3f93),
                      fontFamily: 'Gilmer Regular',
                    ),
                  ),
                  Text(
                    'Nous vous enverrons un code de vérification.',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFF1c3f93),
                      fontFamily: 'Gilmer Regular',
                    ),
                  ),
                  SizedBox(height: 20.0),
                ],
              ),
            Expanded(
              child: _buildStepContent(),
            ),
            Row(
 mainAxisAlignment: MainAxisAlignment.end,
 children: [
  if (_currentStep != 4) // Afficher le bouton uniquement si _currentStep n'est pas égal à 4
    Container(
      decoration: BoxDecoration(
        color: Color(0xFF009b79), // La couleur du bouton est gérée ici
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0), 
          topRight: Radius.circular(30), 
          bottomLeft: Radius.circular(10), 
          bottomRight: Radius.circular(0), 
        ),
      ),
      child: ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Fond transparent
          shadowColor: Colors.transparent, // Aucune ombre
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Aucun rayon de bordure pour l'élévated button
          ),
        ),
        child: Text(
          _currentStep == 3 ? 'Terminer' : 'Suivant',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'GilmerBold'),
        ),
      ),
    ),
],
),
          SizedBox(height: 20.0),
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
        return _buildVerificationCodeStep();
      case 2:
        return _buildFormStep();
      case 3:
        return _buildFormStep2();
      case 4:
        return ConfirmationScreen(); 
      default:
        return Container();
    }
  }

  Widget _buildPhoneNumberStep() {
    return Column(
      children: [
        TextField(
          controller: _phoneNumberController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
    labelText: 'Numéro de téléphone',
    labelStyle: TextStyle(
      fontSize: 16.0,
      fontFamily: 'GilmerHeavy',
      color: Colors.grey,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
    ),
    prefixIcon: Icon(
      Icons.person_outlined,
      color: Color(0xFF009b79),
    ),
  ),
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

   Widget _buildVerificationCodeStep() {
    return Column(
      children: [
        Text(
          'Un code de vérification a été envoyé à votre numéro de téléphone.',
          style: TextStyle(
            fontSize: 16.0,
            color: Color(0xFF1c3f93),
            fontFamily: 'IBMPlexSansItalic',
          ),
        ),
        SizedBox(height: 20.0),
        OtpTextField(
          numberOfFields: 6,
          borderColor: Color(0xFF009b79),
          showFieldAsBox: true,
          borderRadius: BorderRadius.circular(8),
          focusedBorderColor: Color(0xFF009b79),
          disabledBorderColor: Color(0xFF1c3f93),
          enabledBorderColor: Color(0xFF1c3f93),
          borderWidth: 2,
          onSubmit: (String code) {
            _otpController.text = code;
          },
        ),
        SizedBox(height: 20.0),
        if (_timerRunning) 
          Text(
            'Attendez $_startTimer secondes avant de pouvoir renvoyer le code',
            style: TextStyle(
              color: Color(0xFF009b79),
              fontWeight: FontWeight.bold,
            ),
          ),
        if (!_timerRunning) 
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.refresh, color: Color(0xFF009b79)),
                onPressed: () async {
                  try {
                    await _apiService.resendOtp(_phoneNumberController.text);
                    print('Code renvoyé');
                    // Réinitialiser et démarrer le timer
                    _startTimer = 60;
                    startTimer();
                  } catch (e) {
                    print('Erreur lors du renvoi du code : $e');
                  }
                },
              ),
              Text(
                'Renvoyer le code',
                style: TextStyle(
                  color: Color(0xFF009b79),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
      ],
    );
  }
  Widget _buildFormStep() {
  return Form(
    key: _formKey,
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0), // Ajoute un peu d'espace autour
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
    labelText: 'Nom',
    labelStyle: TextStyle(
      fontSize: 16.0,
      fontFamily: 'GilmerHeavy',
      color: Colors.grey,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
    ),
    focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(30),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(0),
    ),
    borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
  ),
    prefixIcon: Icon(
      Icons.person_outlined,
      color: Color(0xFF009b79),
    ),
  ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est obligatoire';
                }
                return null;
              },
            ),
            SizedBox(height: 30.0),     
            TextFormField(
              controller: _prenomController,
              decoration: InputDecoration(
                  labelText: 'Prénom',
    labelStyle: TextStyle(
      fontSize: 16.0,
      fontFamily: 'GilmerHeavy',
      color: Colors.grey,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
    ),
    focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(30),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(0),
    ),
    borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
  ),
    prefixIcon: Icon(
      Icons.person_outlined,
      color: Color(0xFF009b79),
    ),
  ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est obligatoire';
                }
                return null;
              },
            ),
            SizedBox(height: 30.0),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
    labelText: 'Email',
    labelStyle: TextStyle(
      fontSize: 16.0,
      fontFamily: 'GilmerHeavy',
      color: Colors.grey,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
    ),
    focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(30),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(0),
    ),
    borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
  ),
    prefixIcon: Icon(
      Icons.email_outlined,
      color: Color(0xFF009b79),
    ),
  ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est obligatoire';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Entrez une adresse email valide';
                }
                return null;
              },
            ),
            SizedBox(height: 30.0),
            TextFormField(  
              controller: _dateController,
              decoration: InputDecoration(
    labelText: 'Date de naissance',
    labelStyle: TextStyle(
      fontSize: 16.0,
      fontFamily: 'GilmerHeavy',
      color: Colors.grey,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
    ),
    focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(30),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(0),
    ),
    borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
  ),
    prefixIcon: Icon(
      Icons.calendar_today_outlined,
      color: Color(0xFF009b79),
    ),
  ),
              onTap: () => _selectDate(context),
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est obligatoire';
                }
                return null;
              },
            ),
            SizedBox(height: 30.0),
            TextFormField(
              controller: _cinController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
    labelText: 'Cin',
    labelStyle: TextStyle(
      fontSize: 16.0,
      fontFamily: 'GilmerHeavy',
      color: Colors.grey,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
    ),
    focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(30),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(0),
    ),
    borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
  ),
    prefixIcon: Icon(
      Icons.badge_outlined,
      color: Color(0xFF009b79),
    ),
  ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est obligatoire';
                }
                if (!RegExp(r'^\d{8}$').hasMatch(value)) {
                  return 'Le CIN doit être composé de 8 chiffres.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildFormStep2() {
   return SingleChildScrollView(
    child:Form(
    key: _formKey2, 
    child: Column(
      children: [
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
    labelText: 'Login',
    labelStyle: TextStyle(
      fontSize: 16.0,
      fontFamily: 'GilmerHeavy',
      color: Colors.grey,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0), 
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
    ),
    focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(30),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(0),
    ),
    borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
  ),
  ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ est obligatoire';
            }
            if (value.length < 3) {
              return 'Le nom d\'utilisateur doit contenir au moins 3 caractères.';
            }
            return null;
          },
        ),
        SizedBox(height: 20.0),
        TextFormField(
          controller: _passwordController,
          obscureText: !_showPassword,
          decoration: InputDecoration(
   labelText: 'Mot de passe',
    labelStyle: TextStyle(
      fontSize: 16.0,
      fontFamily: 'GilmerHeavy',
      color: Colors.grey,
    ),
  floatingLabelStyle: TextStyle(
    color: Color(0xFF009b79),
    fontSize: 18.0,
    fontFamily: 'GilmerHeavy',
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
  border: OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(30),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(0),
    ),
    borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(30),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(0),
    ),
    borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(30),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(0),
    ),
    borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(30),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(0),
    ),
    borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(30),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(0),
    ),
    borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
  ),
  contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
  errorStyle: TextStyle(
    fontFamily: 'GilmerHeavy',
  ),
  errorMaxLines: 3,
),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre mot de passe';
            }
            if (value.length < 8) {
              return 'Le mot de passe doit contenir au moins 8 caractères.';
            }
            if (!RegExp(r'^(?=.*?[A-Z])').hasMatch(value)) {
              return 'Le mot de passe doit contenir au moins une lettre majuscule.';
            }
            if (!RegExp(r'^(?=.*?[a-z])').hasMatch(value)) {
              return 'Le mot de passe doit contenir au moins une lettre minuscule.';
            }
            if (!RegExp(r'^(?=.*?[0-9])').hasMatch(value)) {
              return 'Le mot de passe doit contenir au moins un chiffre.';
            }
            //if (!RegExp(r'^(?=.*?[!@#\$&*~])').hasMatch(value)) {
             // return 'Le mot de passe doit contenir au moins un caractère spécial.';
            //}
            return null;
          },
        ),
        SizedBox(height: 20.0),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_showConfirmPassword,
          decoration: InputDecoration(
             labelText: 'Confirmer le mot de passe',
    labelStyle: TextStyle(
      fontSize: 16.0,
      fontFamily: 'GilmerHeavy',
      color: Colors.grey,
    ),
            suffixIcon: IconButton(
              icon: Icon(
                _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                color: Color(0xFF009b79),
              ),
              onPressed: () {
                setState(() {
                  _showConfirmPassword = !_showConfirmPassword;
                });
              },
            ),
            border: OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(30),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(0),
    ),
    borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(30),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(0),
    ),
    borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(30),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(0),
    ),
    borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(30),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(0),
    ),
    borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(30),
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(0),
    ),
    borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
  ),
            contentPadding: EdgeInsets.all(16.0),
            errorStyle: TextStyle(
    fontFamily: 'GilmerHeavy',
  ),
  errorMaxLines: 3,
),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez confirmer votre mot de passe';
            }
            if (value != _passwordController.text) {
              return 'Les mots de passe ne correspondent pas';
            }
            return null;
          },
        ),
        SizedBox(height: 20.0),
      ],
    ),
  ));
}

}


