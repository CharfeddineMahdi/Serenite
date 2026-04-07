import 'package:ami_mobile/features/simulateurs/screens/SummaryPage.dart';
import 'package:ami_mobile/features/simulateurs/screens/SummaryPageObjectif.dart';
import 'package:ami_mobile/features/simulateurs/screens/SummaryPageSelonCapital.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ami_mobile/services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimulateurFormObjectifPage extends StatefulWidget {
  @override
  _SimulateurFormPageState createState() => _SimulateurFormPageState();
}

class _SimulateurFormPageState extends State<SimulateurFormObjectifPage>  with TickerProviderStateMixin{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
bool _isLoading = false;
   late AnimationController _animationController;
  // Controllers for the input fields
  TextEditingController _dateNaissanceController = TextEditingController();
  DateTime? _selectedDate;
  TextEditingController _dureeAnneesController = TextEditingController();
  TextEditingController _fractController = TextEditingController();
  TextEditingController _mnt_epargne_constituController = TextEditingController();
  TextEditingController _salaireImposableController = TextEditingController();

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

      // Initialiser et configurer l'AnimationController
  _animationController = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(); 
  }


  @override
  void dispose() {
    _dureeFocusNode.dispose();
    _dateNaissanceController.dispose();
     _animationController.dispose();
    super.dispose();
  }

  // Set to the 1st of the next month
  DateTime _dateEffet = (DateTime.now().month < 12)
      ? DateTime(DateTime.now().year, DateTime.now().month + 1, 1)
      : DateTime(DateTime.now().year + 1, 1, 1);

  final ApiService _apiService = ApiService();
  //List<dynamic>? _simulationResults;


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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Row(
    mainAxisAlignment: MainAxisAlignment.start, // Align items to the start of the row
    children: [
      Flexible(
        child: Text(
          'Épargne définie',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'GilmerRegular',
            fontSize: 20, // Ajuste la taille du texte si nécessaire
          ),
        ),
      ),
      SizedBox(width: 30), // Réduis l'espace pour faire plus de place au texte
      Image.asset(
        'assets/images/LogoBNA_BLANC.png',
        height: 100, 
        fit: BoxFit.contain, 
      ),
    ],
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
      body: Stack(
        children: [
          Padding(
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
              _buildDropdownField('Périodicité des versements', _fractController),
              SizedBox(height: 15),
               _buildNumericField('Épargne', _mnt_epargne_constituController),
              SizedBox(height: 15),
              _buildNumericField('Salaire Imposable Annuel', _salaireImposableController),
              SizedBox(height: 20),  
              ElevatedButton(
                onPressed: _submitForm2,
              child: Text(
               'Calculer',
               style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF009b79),
                  fixedSize: Size(300, 40),
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      if (_isLoading)
      Positioned.fill(
        child: Container(
                       color: Colors.black.withOpacity(0.3), 
 // Fond gris semi-transparent
          child: Center(
            child: RotationTransition(
              turns: _animationController,
              child: Image.asset(
                'assets/images/Favicon-BNA-Assurances.png',
               width: 50,
                    height: 50,
              ),
            ),
          ),
        ),
      ),
      ],
      )
    );
  }

  // Non-editable date field
  Widget _buildNonEditableDateField(String label, DateTime date) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF1c3f93)),
        hintText: DateFormat('yyyy-MM-dd').format(date),
        hintStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
        ),
        enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
              ),
         focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
              ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF009b79)), // Error border color
          borderRadius: BorderRadius.circular(30.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF009b79)), // Focused error border color
          borderRadius: BorderRadius.circular(30.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      ),
      style: GoogleFonts.lato(fontSize: 16), // Set custom font and size
      readOnly: true,
    );
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
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
      ),
      enabledBorder: OutlineInputBorder(
       borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF009b79)), 
        borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF009b79)), 
         borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
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
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
          borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
        ),
        focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
          borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF009b79)), // Error border color
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF009b79)), // Focused error border color
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
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

// Info text widget
Widget _buildInfoText() {
  return Row(
    //crossAxisAlignment: CrossAxisAlignment.start, // Align the icon to the start
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
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
        ),
        enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
        ),
         focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
                borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
              ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF009b79)), // Error border color
        borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF009b79)), // Focused error border color
        borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
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
      labelStyle: TextStyle(color: Color(0xFF1c3f93)), // Change label color here
      errorStyle: TextStyle(color: Color(0xFF009b79), fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
        borderSide: BorderSide(width: 2, color: Color(0xFF1c3f93)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF009b79)), // Error border color
        borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF009b79)), // Focused error border color
        borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
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



Map<String, dynamic>? _simulationResults2;

List<Map<String, dynamic>>? _simulationResults;

void _submitForm2() async {
  if (_formKey.currentState!.validate()) {
     setState(() {
      _isLoading = true; // Afficher le spinner de chargement
    });
    // Convert date from dd/MM/yyyy to yyyyMMdd format
    String formattedDateEffet = DateFormat('yyyyMMdd').format(_dateEffet);
    String formattedDateNaissance = DateFormat('yyyyMMdd').format(_selectedDate!);

    // Call the API to get simulation results
    final response = await _apiService.simulateurSelonCapital(
      dateEffet: formattedDateEffet,
      dateNaissance: formattedDateNaissance,
      durmois: int.parse(_dureeAnneesController.text) * 12, // Convert years to months
      fract: _fractController.text,
      capital: double.parse(_mnt_epargne_constituController.text),
      salaireImposable: double.parse(_salaireImposableController.text),
    );

    setState(() {
      _simulationResults2 = response;
         _isLoading = false; // Update the result
    });

    final responseDetails = await _apiService.simulateurParObjectif(
      dateEffet: formattedDateEffet,
      dateNaissance: formattedDateNaissance,
      durmois: int.parse(_dureeAnneesController.text) * 12, // Convert years to months
      fract: _fractController.text,
      mnt_epargne_constitu: double.parse(_mnt_epargne_constituController.text),
      salaireImposable: double.parse(_salaireImposableController.text),
      txTmg: 0.06, // Hidden parameter
    );

    // Ensure the responseDetails is of the correct type (List<Map<String, dynamic>>)
    setState(() {
      _simulationResults = List<Map<String, dynamic>>.from(responseDetails); // Cast the response to the correct type
    });

    if (_simulationResults2 != null) {
      // Convert the single Map to a List of Maps
      List<Map<String, dynamic>> simulationResultsList = [_simulationResults2!];
 final Map<String, dynamic> formData = {
        'dateEffet': formattedDateEffet,
        'dateNaissance': formattedDateNaissance,
        'salaireImposable': double.parse(_salaireImposableController.text),
        'durmois': (int.parse(_dureeAnneesController.text) * 12), 
        'fract': _fractController.text,
        'capital': double.parse(_mnt_epargne_constituController.text),
        'txTmg': 0.06, // Paramètre caché si nécessaire
      };
      // Navigate to the summary page with the frequency label
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryPageSelonCapital(
            summaryData: _simulationResults2!,
            allData: _simulationResults,
            formData:formData
          ),
        ),
      );
    }
  }
}

  /* void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    // Convert date from dd/MM/yyyy to yyyyMMdd format
    String formattedDateEffet = DateFormat('yyyyMMdd').format(_dateEffet);
    String formattedDateNaissance = DateFormat('yyyyMMdd').format(_selectedDate!);

    // Call the API to get simulation results
    final response = await _apiService.simulateurParObjectif(
      dateEffet: formattedDateEffet,
      dateNaissance: formattedDateNaissance,
      durmois: int.parse(_dureeAnneesController.text) * 12, // Convert years to months
      fract: _fractController.text,
      mnt_epargne_constitu: double.parse(_mnt_epargne_constituController.text),
      salaireImposable: double.parse(_salaireImposableController.text),
      txTmg: 0.06, // Hidden parameter
    );

    setState(() {
      _simulationResults = response; // Update the results to display
    });

    if (_simulationResults != null && _simulationResults!.isNotEmpty) {
      final lastResult = _simulationResults!.last;
       //partie jdidaaaa
        // Assume the response contains 'Prime_commercial' for one year
       // Extract the 'Prime_commercial' value from the last result
      double primeCommercial = lastResult.containsKey('Prime_commercial') 
          ? (lastResult['Prime_commercial'] as double) 
          : 0.0;

      // Determine the number of periods based on the selected frequency
      int periods;
      switch (_fractController.text) {
        case 'Annuel': // Annuel
          periods = 1;
          break;
        case 'Mensuel': // Mensuel
          periods = 12;
          break;
        case 'Trimestriel': // Trimestriel
          periods = 4;
          break;
        case 'Semestriel': // Semestriel
          periods = 2;
          break;
        default:
          periods = 12; // Default to Monthly
      }

      // Calculate the prime per period
      double primePerPeriod = primeCommercial / periods;
      // Navigate to the summary page with calculated prime per period
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryPageObjectif(
            summaryData: lastResult,
            allData: _simulationResults,
            primePerPeriod: primePerPeriod,
            fractLabel: _fractController.text,
          ),
        ),
      );
    }
  } */
}




