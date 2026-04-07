import 'dart:convert';

import 'package:ami_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:ami_mobile/features/simulateurs/screens/SummaryRentePage.dart';

class RenteVersementsPeriodiques extends StatefulWidget {
  @override
  _RenteVersementsPeriodiquesState createState() => _RenteVersementsPeriodiquesState();
}

class _RenteVersementsPeriodiquesState extends State<RenteVersementsPeriodiques> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //TextEditingController _dateEffetController = TextEditingController();
  TextEditingController _dateNaissanceController = TextEditingController();
  TextEditingController _dureeAnneesController = TextEditingController();
  TextEditingController _mntprimeInvestiController = TextEditingController();
  TextEditingController _mntVersementInitialController = TextEditingController();
  TextEditingController _txIndexationController = TextEditingController();
  TextEditingController _salaireImposableController = TextEditingController();
  TextEditingController _dureeRenteParAnController = TextEditingController();
  TextEditingController _fractController = TextEditingController();
  TextEditingController _fractRenteController = TextEditingController();
   DateTime? _selectedDate;

   final ApiService _apiService = ApiService();




   String? _selectedTypeRente; // To store selected value

  FocusNode _dureeFocusNode = FocusNode(); 
  bool _isInfoVisible = false;

  @override
  void initState() {
    super.initState();
  
    _dureeFocusNode.addListener(() {
      setState(() {
        _isInfoVisible = _dureeFocusNode.hasFocus;
      });
    });
     _loadDateNaissance();
  }

  @override
  void dispose() {
    _dureeFocusNode.dispose();
    _dateNaissanceController.dispose();
    super.dispose();
  }

  // Set to the 1st of the next month
  DateTime _dateEffet = (DateTime.now().month < 12)
      ? DateTime(DateTime.now().year, DateTime.now().month + 1, 1)
      : DateTime(DateTime.now().year + 1, 1, 1);

  List<dynamic>? _simulationResults;


Future<void> _loadDateNaissance() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? dateNaissanceString = prefs.getString('dateNaissance');
  
  if (dateNaissanceString != null) {
    try {
      // Utilisez DateFormat pour parser la date dans le format attendu
      DateFormat inputFormat = DateFormat('dd/MM/yyyy');
      DateTime dateNaissance = inputFormat.parse(dateNaissanceString);
      
      setState(() {
        _selectedDate = dateNaissance;
        _dateNaissanceController.text = DateFormat('dd/MM/yyyy').format(dateNaissance); // Format de la date pour l'affichage
      });
    } catch (e) {
      print('Erreur de format de date: $e');
    }
  }
}

Widget _buildDropdownRenteField() {
  return DropdownButtonFormField<String>(
    value: _selectedTypeRente,
    items: [
      DropdownMenuItem(
        value: 'V',
        child: Text('Viagère'),
      ),
      DropdownMenuItem(
        value: 'T',
        child: Text('Temporaire'),
      ),
    ],
    onChanged: (value) {
      setState(() {
        _selectedTypeRente = value;
        print('Type de rente sélectionné : $_selectedTypeRente'); 
        // Réinitialiser la durée si nécessaire
        if (_selectedTypeRente == 'V') {
          _dureeRenteParAnController.text = '0'; // Fixer la durée à 0 pour Viagère
        } else if (_selectedTypeRente == 'T') {
          _dureeRenteParAnController.text = ''; // Réinitialiser la durée pour Temporaire
        }
        print('Durée actuelle : ${_dureeRenteParAnController.text}');
      });
    },
    decoration: InputDecoration(
      labelText: 'Type Rente',
      labelStyle: TextStyle(color: Color(0xFF1c3f93)),
      errorStyle: TextStyle(color: Color(0xFF009b79), fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
      ),
    ),
    validator: (value) {
      if (value == null) {
        return 'Veuillez sélectionner le type de rente';
      }
      return null;
    },
  );
}

Widget _buildDurationRenteField() {
  return TextFormField(
    controller: _dureeRenteParAnController,
    enabled: _selectedTypeRente == 'T', // Activé uniquement pour Temporaire
    decoration: InputDecoration(
      labelText: 'Durée Rente en année',
      labelStyle: TextStyle(color: Color(0xFF1c3f93)),
      errorStyle: TextStyle(color: Color(0xFF009b79), fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF009b79)), 
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF009b79)), 
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
    ),
    style: GoogleFonts.lato(fontSize: 16),
    keyboardType: TextInputType.number,
    validator: (value) {
      if (_selectedTypeRente == 'T' && (value == null || value.isEmpty)) {
        return 'Veuillez entrer la durée';
      }
      return null;
    },
    onChanged: (value) {
      print('Durée saisie : $value');
    },
  );
}

Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateNaissanceController.text = DateFormat('dd/MM/yyyy').format(picked); // Update the text field with selected date
      });
    }
  }
// Date picker field
Widget _buildDatePickerField(String label, TextEditingController controller) {
  return TextFormField(
    controller: _dateNaissanceController,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Color(0xFF1c3f93)),
      errorStyle: TextStyle(color: Color(0xFF009b79), fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF009b79)), 
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF009b79)), 
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
    ),
    style: GoogleFonts.lato(fontSize: 16), 
    readOnly: true,
    onTap: () async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(), // Use selected date or current date
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );

      if (pickedDate != null) {
        setState(() {
          _selectedDate = pickedDate; // Update selected date
          controller.text = DateFormat('yyyyMMdd').format(pickedDate); // Format and set the text
        });
      }
    },
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Veuillez entrer $label';
      }
      return null;
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      appBar: AppBar(
        title: Text(
          'Rente Versements Périodiques',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'GilmerHeavy',
            fontSize: 17
          ),
        ),
        backgroundColor: Color(0xFF1c3f93),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
           padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              //_buildNonEditableDateField('Date début', _dateEffet),
              SizedBox(height: 15), 
              _buildDatePickerField('Date Naissance', _dateNaissanceController),
              SizedBox(height: 15),
              _buildDurationField('Durée en années', _dureeAnneesController, _dureeFocusNode),
              SizedBox(height: 10),
              if (_isInfoVisible) _buildInfoText(),
              SizedBox(height: 15),
              _buildNumericField('Versement initial', _mntVersementInitialController),
              SizedBox(height: 15),
              _buildNumericField('Versements périodiques', _mntprimeInvestiController),
              SizedBox(height: 15),
               _buildNumericField('Évolution annuelle des versements', _txIndexationController),
              SizedBox(height: 15),
              _buildNumericField('Salaire Imposable Annuel', _salaireImposableController),
              SizedBox(height: 15),
              _buildDropdownField('Périodicité des versements', _fractController),
              SizedBox(height: 15),
             _buildDropdownFractField('Fractionnement Rente', _fractRenteController),
               SizedBox(height: 15),
              _buildDropdownRenteField(),
              SizedBox(height: 15),
              _buildDurationRenteField(),
              SizedBox(height: 20),
              Container(
              width: 200,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFF009b79),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: ElevatedButton(
                onPressed: _submitForm,
                child: Text(
                  'Calculer',
                  style: TextStyle(color: Colors.white, fontFamily: 'GilmerBold'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  fixedSize: Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  shadowColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildInfoText() {
  return Row(
    children: [
      Icon(
        Icons.info_outline,
        color: Color(0xFF009b79),
        size: 16.0,
      ),
      SizedBox(width: 8), 
      Expanded(
        child: Text(
          'La période minimale pour bénéficier de l’avantage fiscal est de 8 années.',
          style: TextStyle(color: Color(0xFF009b79)),
        ),
      ),
    ],
  );
}
 // Duration input field in years
  Widget _buildDurationField(String label, TextEditingController controller, FocusNode focusNode) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode, // Attach the FocusNode to the field
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF1c3f93)),
        errorStyle: TextStyle(color: Color(0xFF009b79), fontSize: 14),
        border: OutlineInputBorder(
         borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
          borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
          borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF009b79)), // Error border color
           borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF009b79)), // Focused error border color
          borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      ),
      style: GoogleFonts.lato(fontSize: 16), // Set custom font and size
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer $label';
        }
        return null;
      },
    );
  }


 // Numeric input field
  Widget _buildNumericField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF1c3f93)),
        errorStyle: TextStyle(color: Color(0xFF009b79), fontSize: 14),
        border: OutlineInputBorder(
           borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        ),
        enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
        ),
         focusedBorder: OutlineInputBorder(
                 borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
                borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
              ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF009b79)), // Error border color
           borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF009b79)), // Focused error border color
           borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      ),
      style: GoogleFonts.lato(fontSize: 16), // Set custom font and size
      
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer $label';
        }
        return null;
      },
      
    );
  }

 final List<Map<String, String>> options = [
  {'label': 'Annuel', 'value': 'A'},
  {'label': 'Mensuel', 'value': 'M'},
  {'label': 'Trimestriel', 'value': 'T'},
  {'label': 'Semestriel', 'value': 'S'},
];

String? selectedValue;

Widget _buildDropdownField(String label, TextEditingController controller) {
  return DropdownButtonFormField<String>(
    value: selectedValue,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Color(0xFF1c3f93)),
      errorStyle: TextStyle(color: Color(0xFF009b79), fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
      ),
      enabledBorder: OutlineInputBorder(
         borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF009b79)),
         borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF009b79)),
         borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
    ),
    items: options.map((option) {
      return DropdownMenuItem<String>(
        value: option['value'],
        child: Text(option['label']!),
      );
    }).toList(),
    onChanged: (value) {
      setState(() {
        selectedValue = value;
        controller.text = value!;
      });
    },
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Veuillez sélectionner une option';
      }
      return null;
    },
  );
}

String? selectedFractValue;

Widget _buildDropdownFractField(String label, TextEditingController controller) {
  return DropdownButtonFormField<String>(
    value: selectedFractValue,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Color(0xFF1c3f93)),
      errorStyle: TextStyle(color: Color(0xFF009b79), fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF009b79)),
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF009b79)),
        borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(0),
                ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
    ),
    items: options.map((option) {
      return DropdownMenuItem<String>(
        value: option['value'],
        child: Text(option['label']!),
      );
    }).toList(),
    onChanged: (value) {
      setState(() {
        selectedFractValue = value;
        controller.text = value!;
      });
    },
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Veuillez sélectionner une option';
      }
      return null;
    },
  );
}




  void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    try {
      String formattedDateEffet = DateFormat('yyyyMMdd').format(_dateEffet);
      String formattedDateNaissance = DateFormat('yyyyMMdd').format(_selectedDate!);

      // Log les valeurs envoyées
      print('dateEffet: $formattedDateEffet');
      print('dateNaissance: $formattedDateNaissance');
      print('durmois: ${int.parse(_dureeAnneesController.text) * 12}');
      print('mntprimeInvesti: ${double.parse(_mntprimeInvestiController.text)}');
      print('salaireImposable: ${double.parse(_salaireImposableController.text)}');
      print('txTmg: 0.06');
      print('typERente: ${_selectedTypeRente ?? ''}');
      print('fraiServiceRente: 3.5');
      print('fractRente: ${selectedValue ?? ''}');
      print('dureeRenteParAN: ${int.tryParse(_dureeRenteParAnController.text) ?? 0}');

      final response = await _apiService.simulateRenteVersementsPeriodiques(
        dateEffet: formattedDateEffet,
        dateNaissance: formattedDateNaissance,
        durmois: int.parse(_dureeAnneesController.text) * 12,
         fract: selectedValue ?? '',
        fractRente: selectedFractValue ?? '',
        mntprimeInvesti: double.parse(_mntprimeInvestiController.text),
        mntversemmentIntial:double.parse( _mntVersementInitialController.text),
        txIndexation: double.parse(_txIndexationController.text),
        salaireImposable: double.parse(_salaireImposableController.text),
        typERente: _selectedTypeRente ?? '',
        dureeRenteParAN: int.tryParse(_dureeRenteParAnController.text) ?? 0,
        txTmg: 0.06,
        fraiServiceRente: 3.5,
       
      );

      print('Réponse API: $response');
      if (response != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryRentePage(renteData: response),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi des données.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi des données: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
}
