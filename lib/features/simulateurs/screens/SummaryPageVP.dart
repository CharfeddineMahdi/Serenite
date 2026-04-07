import 'package:ami_mobile/features/simulateurs/screens/DetailsPage.dart';
import 'package:ami_mobile/features/simulateurs/screens/SummaryRentePage.dart';
import 'package:ami_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SummaryPageVP extends StatefulWidget {
  final Map<String, dynamic> summaryData;
  final List<dynamic>? allData;
  final Map<String, dynamic> formData;

  SummaryPageVP(
      {required this.summaryData, this.allData, required this.formData});

  @override
  _SummaryPageVPState createState() => _SummaryPageVPState();
}

class _SummaryPageVPState extends State<SummaryPageVP> {
  String? _selectedTypeRente; 
  final TextEditingController _dureeRenteParAnController =
      TextEditingController();
  final TextEditingController _fractController = TextEditingController();
  String? selectedValue;
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    // Fix for allData reference
    double totalGainFiscal = widget.allData != null
        ? widget.allData!
            .fold(0.0, (sum, item) => sum + (item['Gain_Fiscal'] ?? 0.0))
        : 0.0;

    return Scaffold(
      appBar: AppBar(
  title: Row(
    mainAxisAlignment: MainAxisAlignment.start, 
    children: [
      Expanded(
        child: Text(
          'Résultats',
          style: TextStyle(
            color: Colors.white,
            overflow: TextOverflow.ellipsis, 
          ),
        ),
      ),
      SizedBox(width: 10), 
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildCard('Épargne Constituée',
                      widget.summaryData['Epargne_ConstituÃ©es'].toString(),false),
                  _buildCard('Versements',
                      widget.summaryData['Total_Prime_CumulÃ©e'].toString(),true),
                  _buildCard('Gain Fiscal', totalGainFiscal.toString(),false),
                  _buildCard('Gain Financier',
                      widget.summaryData['Gain_Financier'].toString(),true),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.only(bottom: 50.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailsPage(allData: widget.allData),
                        ),
                      );
                    },
                    child: Text(
                      'Consulter l\'évolution prévisionnelle de votre épargne',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF009b79),
                      fixedSize: Size(400, 50),
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
                  SizedBox(
                      height: 16.0), // Ajoute un espacement entre les boutons
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return AlertDialog(
                                title: Text('Rente'),
                                content: Form(
                                  key: _formKey, // Associate the form key
                                  child: Column(
                                    mainAxisSize: MainAxisSize
                                        .min, // Make the dialog content fit its children
                                    children: [
                                      _buildDropdownRenteField(setState),
                                      SizedBox(height: 16.0),
                                      _buildDurationRenteField(setState),
                                      SizedBox(height: 16.0),
                                      _buildDropdownField(
                                      'Fractionnement', _fractController),
                                      SizedBox(height: 15),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: Text(
                                      'Annuler',
                                      style: TextStyle(
                                          color: Color(0xFF009b79)), 
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        // Validate form
                                        if (_selectedTypeRente == 'T' &&
                                            _dureeRenteParAnController
                                                .text.isEmpty) {
                                          // Display an error message or handle validation
                                          print(
                                              'Veuillez entrer la durée pour une rente temporaire.');
                                        } else {
                                          // Process the rente choice here
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                          _submitFormRente();
                                          print(
                                              'Type de rente choisi: $_selectedTypeRente');
                                          print(
                                              'Durée de la rente: ${_dureeRenteParAnController.text}');
                                        }
                                      } else {
                                        // Handle invalid form case
                                        print('Form is not valid.');
                                      }
                                    },
                                    child: Text(
                                      'Confirmer',
                                      style: TextStyle(
                                          color: Color(0xFF009b79)), // Change the color of the "Confirmer" button
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Text(
                      'Voulez-vous transformer votre capital en une rente ?',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFF1c3f93), 
                      fixedSize: Size(400, 50),
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
          ],
        ),
      ),
    );
  }

Widget _buildCard(String title, String value, bool isRightSide) {
  final formattedValue = _formatNumber(value);
  return Container(
    margin: EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Colors.white, 
      border: Border.all(
        color: Color(0xFF1c3f93), 
        width: 2.0, // Border width
      ),
      borderRadius: isRightSide
          ? BorderRadius.only(
             topLeft: Radius.circular(20.0),
              topRight: Radius.circular(0.0),
              bottomLeft: Radius.circular(0.0),
              bottomRight: Radius.circular(40.0)
            )
          : BorderRadius.only(
           topLeft: Radius.circular(0.0),
              topRight: Radius.circular(20.0),
              bottomLeft: Radius.circular(40.0),
              bottomRight: Radius.circular(0.0),
            ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 5.0,
          offset: Offset(0, 3), // Shadow position
        ),
      ],
    ),
    child: Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF1c3f93), // Blue color for the title
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              fontFamily: 'GilmerRegular',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.0),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: formattedValue,
                  style: TextStyle(
                    color: Color(0xFF009b79), // Green color for the value
                    fontSize: 18.0,
                    fontFamily: 'GilmerRegular',
                  ),
                ),
                TextSpan(
                  text: ' DT', // Adding "DT" as text
                  style: TextStyle(
                    color: Color(0xFF009b79), // Matching color for "DT"
                    fontSize: 18.0,
                    fontFamily: 'GilmerRegular',
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}


  String _formatNumber(String value) {
    try {
      final number = double.parse(value);
      final formatter =
          NumberFormat('#,##0', 'fr_FR'); // Utilisation de la locale française
      return formatter.format(number);
    } catch (e) {
      return value; // Retourne la valeur originale en cas d'erreur
    }
  }

  Widget _buildDropdownRenteField(StateSetter setState) {
    return DropdownButtonFormField<String>(
      value: _selectedTypeRente,
      items: [
        DropdownMenuItem(
          value: 'V',
          child: Text('Rente à vie'),
        ),
        DropdownMenuItem(
          value: 'T',
          child: Text('Rente à durée déterminée'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedTypeRente = value;
          // Reset the duration if necessary
          if (_selectedTypeRente == 'V') {
            _dureeRenteParAnController.text =
                '0'; // Set duration to 0 for Viagère
          } else if (_selectedTypeRente == 'T') {
            _dureeRenteParAnController.text =
                ''; // Clear the duration for Temporaire
          }
        });
      },
      decoration: InputDecoration(
        labelText: 'Type de rente',
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
      ),
      validator: (value) {
        if (value == null) {
          return 'Veuillez sélectionner le type de rente';
        }
        return null;
      },
    );
  }


Widget _buildDurationRenteField(StateSetter setState) {
  const int maxDuration = 30; // Durée maximale de la rente en années.

  return TextFormField(
    controller: _dureeRenteParAnController,
    enabled: _selectedTypeRente == 'T', // Activé uniquement pour "Temporaire"
    decoration: InputDecoration(
      labelText: 'Durée Rente en année',
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
    style: GoogleFonts.lato(fontSize: 16),
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly, // Restreindre l'entrée aux chiffres seulement.
      LengthLimitingTextInputFormatter(2), // Limiter la durée saisie à 2 chiffres maximum.
    ],
    validator: (value) {
      if (_selectedTypeRente == 'T' && (value == null || value.isEmpty)) {
        return 'Veuillez entrer la durée.';
      }
      // Vérifier si la durée dépasse la durée maximale
      //final int? duration = int.tryParse(value ?? '');
      /* if (_selectedTypeRente == 'T' && duration != null && duration > maxDuration) {
        return 'La durée maximale est de $maxDuration ans.';
      } */
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

  final _formKey = GlobalKey<FormState>();
  void _submitFormRente() async {
    print('dateEffet: ${widget.formData['dateEffet']}');
    print('dateNaissance: ${widget.formData['dateNaissance']}');
    print('durmois: ${widget.formData['durmois']}');
    print('mntprimeInvesti: ${widget.formData['mntprimeInvesti']}');
    print('salaireImposable: ${widget.formData['salaireImposable']}');
    print('typERente: $_selectedTypeRente');
    print('dureeRenteParAN: ${_dureeRenteParAnController.text}');
    if (_formKey.currentState!.validate()) {
      try {
        final response = await _apiService.simulateRenteVersementsPeriodiques(
          dateEffet: widget.formData['dateEffet'], 
          dateNaissance:
              widget.formData['dateNaissance'], 
          durmois: widget.formData['durmois'], 
          fractRente: selectedValue ?? '', 
          mntprimeInvesti:
              widget.formData['mntprimeInvesti'], 
          salaireImposable:
              widget.formData['salaireImposable'], 
          fract: 
             widget.formData['fract'],
          mntversemmentIntial: 
             widget.formData['mntversemmentInitial'],
          txIndexation: 
             widget.formData['txIndexation'],
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
            content:
                Text('Erreur lors de l\'envoi des données: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
