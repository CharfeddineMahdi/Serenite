import 'package:ami_mobile/features/simulateurs/screens/SummaryPage.dart';
import 'package:ami_mobile/features/simulateurs/screens/SummaryPageFINAL.dart';
import 'package:ami_mobile/features/simulateurs/screens/SummaryPageVP.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ami_mobile/services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimulateurFormVPPage extends StatefulWidget {
  @override
  _SimulateurFormPageState createState() => _SimulateurFormPageState();
}

class _SimulateurFormPageState extends State<SimulateurFormVPPage> with TickerProviderStateMixin{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
 bool _isLoading = false;
   late AnimationController _animationController;

  // Controllers for the input fields
  TextEditingController _dateNaissanceController = TextEditingController();
  DateTime? _selectedDate;
  TextEditingController _dureeAnneesController = TextEditingController();
  TextEditingController _fractController = TextEditingController();
  TextEditingController _mntprimeInvestiController = TextEditingController();
  TextEditingController _mntversemmentInitialController = TextEditingController();
  TextEditingController _txIndexationController = TextEditingController();
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
        _dateNaissanceController.text = DateFormat('dd/MM/yyyy').format(dateNaissance); 
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
        _dateNaissanceController.text = DateFormat('dd/MM/yyyy').format(picked); 
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
  title: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espace entre le texte et le logo
    children: [
      Flexible(
        child: Text(
          'Versements réguliers',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'GilmerRegular',
            fontSize: 17, 
          ),
        ),
      ),
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
    // Formulaire principal
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
            _buildNumericField('Montant versement initial', _mntversemmentInitialController),
            SizedBox(height: 15),
            _buildNumericField('Versements réguliers', _mntprimeInvestiController),
            SizedBox(height: 15),
            _buildNumericField('Évolution annuelle des versements (%)', _txIndexationController),
            SizedBox(height: 15),
            _buildNumericField('Salaire Imposable Annuel', _salaireImposableController),
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
    // Écran de chargement
    if (_isLoading)
      Positioned.fill(
        child: Container(
                       color: Colors.black.withOpacity(0.3), 

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
),

    
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
      focusNode: focusNode, 
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
    //crossAxisAlignment: CrossAxisAlignment.start, 
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


  // Submit form and call the API
 void _submitForm() async {
  if (_formKey.currentState!.validate()) {
     setState(() {
      _isLoading = true; // Afficher le spinner de chargement
    });
    // Convert date from dd/MM/yyyy to yyyyMMdd format
    String formattedDateEffet = DateFormat('yyyyMMdd').format(_dateEffet);
    String formattedDateNaissance = DateFormat('yyyyMMdd').format(_selectedDate!);

    final response = await _apiService.simulateurVersementPeriodique(
      dateEffet: formattedDateEffet,
      dateNaissance: formattedDateNaissance,
      durmois: int.parse(_dureeAnneesController.text) * 12, 
      fract: _fractController.text,
      mntprimeInvesti: double.parse(_mntprimeInvestiController.text),
      mntversemmentInitial: double.parse(_mntversemmentInitialController.text),
      txIndexation: double.parse(_txIndexationController.text),
      salaireImposable: double.parse(_salaireImposableController.text),
      txTmg: 0.06, // Hidden parameter
    );

    setState(() {
      _simulationResults = response; 
        _isLoading = false;
    });

    if (_simulationResults != null && _simulationResults!.isNotEmpty) {
      final lastResult = _simulationResults!.last;
      final Map<String, dynamic> formData = {
        'dateEffet': formattedDateEffet,
        'dateNaissance': formattedDateNaissance,
        'mntprimeInvesti': double.parse(_mntprimeInvestiController.text),
        'salaireImposable': double.parse(_salaireImposableController.text),
        'durmois': (int.parse(_dureeAnneesController.text) * 12), 
        'fract': _fractController.text,
        'mntversemmentInitial': double.parse(_mntversemmentInitialController.text),
        'txIndexation': double.parse(_txIndexationController.text),
        'txTmg': 0.06, // Paramètre caché si nécessaire
      };
      Navigator.push(
        context,
        MaterialPageRoute(
          //builder: (context) => SummaryPage(summaryData: lastResult, allData: _simulationResults),
          builder: (context) => SummaryPageVP(summaryData: lastResult, allData: _simulationResults,formData:formData),
        ),
      );
    }
  }
}

}
