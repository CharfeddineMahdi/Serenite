import 'package:ami_mobile/features/simulateurs/screens/SummaryPage.dart';
import 'package:ami_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class RentePrimeUnique extends StatefulWidget {
  @override
  _RentePrimeUniqueState createState() => _RentePrimeUniqueState();
}

class _RentePrimeUniqueState extends State<RentePrimeUnique> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for the input fields
  TextEditingController _dateEffetController = TextEditingController();
  TextEditingController _dateNaissanceController = TextEditingController();
  TextEditingController _durmoisController = TextEditingController(); // Durée en mois pour épargne
  TextEditingController _dureeRenteParAnController = TextEditingController(); // Durée de la rente en années
  TextEditingController _fractController = TextEditingController();
  TextEditingController _fractRenteController = TextEditingController();
  TextEditingController _mntPrimeInvestiController = TextEditingController();
  TextEditingController _salaireImposableController = TextEditingController();
  TextEditingController _typERenteController = TextEditingController();
  TextEditingController _txTmgController = TextEditingController();
  TextEditingController _fraiServiceRenteController = TextEditingController();

  final ApiService _apiService = ApiService();

  DateTime _selectedDateEffet = (DateTime.now().month < 12)
      ? DateTime(DateTime.now().year, DateTime.now().month + 1, 1)
      : DateTime(DateTime.now().year + 1, 1, 1);

  @override
  void initState() {
    super.initState();
    _dateEffetController.text = DateFormat('yyyy-MM-dd').format(_selectedDateEffet);
  }

  @override
  void dispose() {
    // Dispose of controllers
    _dateEffetController.dispose();
    _dateNaissanceController.dispose();
    _durmoisController.dispose();
    _dureeRenteParAnController.dispose();
    _fractController.dispose();
    _fractRenteController.dispose();
    _mntPrimeInvestiController.dispose();
    _salaireImposableController.dispose();
    _typERenteController.dispose();
    _txTmgController.dispose();
    _fraiServiceRenteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rente Prime Unique',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF04348C),
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
              _buildDatePickerField('Date Effet', _dateEffetController),
              SizedBox(height: 15),
              _buildDatePickerField('Date Naissance', _dateNaissanceController),
              SizedBox(height: 15),
              _buildNumericField('Durée d\'Épargne (mois)', _durmoisController), // Champ Durée d'Épargne en mois
              SizedBox(height: 15),
              _buildNumericField('Durée Rente par An (années)', _dureeRenteParAnController), // Champ Durée de la Rente en années
              SizedBox(height: 15),
              _buildDropdownField('Périodicité des Versements', ['Mensuel', 'Trimestriel', 'Annuel'], _fractController),
              SizedBox(height: 15),
              _buildDropdownField('Type de Rente', ['Rente Vie Entière', 'Rente Temporaire'], _typERenteController),
              SizedBox(height: 15),
              _buildNumericField('Montant Prime Investi', _mntPrimeInvestiController),
              SizedBox(height: 15),
              _buildNumericField('Salaire Imposable', _salaireImposableController),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(
                  'Calculer',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF04348C),
                  fixedSize: Size(300, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF04348C)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(width: 2, color: Color(0xFF04348C)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(width: 2, color: Color(0xFF04348C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(width: 2, color: Color(0xFF04348C)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE81917)),
          borderRadius: BorderRadius.circular(30.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE81917)),
          borderRadius: BorderRadius.circular(30.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      ),
      style: GoogleFonts.lato(fontSize: 16),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDateEffet,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDateEffet = pickedDate;
            controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
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

  Widget _buildNumericField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF04348C)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(width: 2, color: Color(0xFF04348C)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(width: 2, color: Color(0xFF04348C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(width: 2, color: Color(0xFF04348C)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE81917)),
          borderRadius: BorderRadius.circular(30.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE81917)),
          borderRadius: BorderRadius.circular(30.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      ),
      keyboardType: TextInputType.number,
      style: GoogleFonts.lato(fontSize: 16),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField(String label, List<String> options, TextEditingController controller) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF04348C)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(width: 2, color: Color(0xFF04348C)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(width: 2, color: Color(0xFF04348C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide(width: 2, color: Color(0xFF04348C)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE81917)),
          borderRadius: BorderRadius.circular(30.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE81917)),
          borderRadius: BorderRadius.circular(30.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      ),
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      value: controller.text.isEmpty ? null : controller.text,
      onChanged: (value) {
        setState(() {
          controller.text = value ?? '';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner $label';
        }
        return null;
      },
    );
  }

  void _submitForm() async {
  if (_formKey.currentState?.validate() ?? false) {
    // Gather data from controllers
    final dateEffet = _dateEffetController.text;
    final dateNaissance = _dateNaissanceController.text;
    final durmois = int.tryParse(_durmoisController.text) ?? 0; // Durée en mois pour épargne
    final dureeRenteParAN = int.tryParse(_dureeRenteParAnController.text) ?? 0; // Durée de rente en années
    final fract = _fractController.text;
    final fractRente = _fractRenteController.text;
    final mntPrimeInvesti = double.tryParse(_mntPrimeInvestiController.text) ?? 0.0;
    final salaireImposable = double.tryParse(_salaireImposableController.text) ?? 0.0;
    final typERente = _typERenteController.text;
    final txTmg = 0.06; // Valeur fixe pour _Tx_tmg
    final fraisServiceRente = 3.5; // Valeur fixe pour frai_Service_Rente

    try {
      final response = await _apiService.simulateRentePrimeUnique(
        dateEffet: dateEffet,
        dateNaissance: dateNaissance,
        durmois: durmois, // En mois
        fractRente: fractRente,
        mntprimeInvesti: mntPrimeInvesti,
        salaireImposable: salaireImposable,
        typERente: typERente,
        dureeRenteParAN: dureeRenteParAN, // En années
        txTmg: 0.06, // Valeur fixe
        fraiServiceRente: 3.5, // Valeur fixe
      );

      if (response != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryPage(summaryData: response),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi des données.'),
            backgroundColor: Color(0xFF009b79),
          ),
        );
      }
    } catch (e) {
      // Gestion des exceptions
      print('Exception lors de la simulation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Une erreur s\'est produite lors de la simulation.'),
          backgroundColor: Color(0xFF009b79),
        ),
      );
    }
  }
}


}

