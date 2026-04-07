import 'package:ami_mobile/features/simulateurs/screens/DetailsPage.dart';
import 'package:ami_mobile/features/simulateurs/screens/SummaryRentePage.dart';
import 'package:ami_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

class SummaryPageFINAL extends StatefulWidget {
  final Map<String, dynamic> summaryData;
  final List<dynamic>? allData;
  final Map<String, dynamic> formData;
 
  SummaryPageFINAL(
      {required this.summaryData, this.allData, required this.formData});

  @override
  _SummaryPageFINALState createState() => _SummaryPageFINALState();
}

class _SummaryPageFINALState extends State<SummaryPageFINAL> {
  String? _selectedTypeRente; // To store the selected type of rente
  final TextEditingController _dureeRenteParAnController =
      TextEditingController();
  final TextEditingController _fractController = TextEditingController();
  String? selectedValue;
  final ApiService _apiService = ApiService();
 pw.Font? robotoFont;
  @override
  void initState() {
    super.initState();
    _loadFont();
  }

 Future<void> _loadFont() async {
    final ByteData data = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    robotoFont = pw.Font.ttf(data.buffer.asByteData());  // Convert ByteData directly
    setState(() {});
  }
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
               fontFamily: 'GilmerRegular',
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
            Align(
              alignment: Alignment.topRight,
              child: ElevatedButton.icon(
                onPressed: _generateAndPrintPdf,
                icon: Icon(Icons.print, color: Colors.white, size: 20),
                label: Text(
                  'Imprimer devis',
                  style: TextStyle(color: Colors.white, fontSize: 14 ,    fontFamily: 'GilmerRegular',),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF009b79),
                  fixedSize: Size(200, 40),
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
            ),
            SizedBox(height: 16),
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
                      style: TextStyle(color: Colors.white ,   fontFamily: 'GilmerRegular',),
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
                                          color: Color(0xFF009b79)), // Change the color of the "Annuler" button
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
                                          color: Color(0xFF009b79) ,   fontFamily: 'GilmerRegular',), // Change the color of the "Confirmer" button
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
                      style: TextStyle(color: Colors.white ,   fontFamily: 'GilmerRegular',),
                      textAlign: TextAlign.center,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFF1c3f93), // Customize button color
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
        labelStyle: TextStyle(color: Color(0xFF1c3f93),   fontFamily: 'GilmerRegular',),
        errorStyle: TextStyle(color: Color(0xFF009b79), fontSize: 14,   fontFamily: 'GilmerRegular',),
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
    return TextFormField(
      controller: _dureeRenteParAnController,
      enabled: _selectedTypeRente == 'T', // Enabled only for "Temporaire"
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
        borderRadius: BorderRadius.circular(30.0),
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
        if (_selectedTypeRente == 'T' && value != null && value.isEmpty) {
          return 'Veuillez entrer la durée.';
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

void _generateAndPrintPdf() async {
  final pdf = pw.Document();

  // Charger l'image de l'en-tête et du pied de page
  final ByteData imageData = await rootBundle.load('assets/images/Letterhead.png');
  final Uint8List imageBytes = imageData.buffer.asUint8List();
  final image = pw.MemoryImage(imageBytes);
  // Récupérer le username et la date de naissance depuis SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String username = prefs.getString('nom') ?? 'Test';



  // Format date (for example, format as dd/MM/yyyy)
  String formatDate(DateTime date) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    return dateFormat.format(date);
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(10),
      build: (pw.Context context) => pw.Stack(
        children: [
          // Fond d'écran avec l'image
          pw.Positioned.fill(
            child: pw.Image(image, fit: pw.BoxFit.cover),
          ),

          // Contenu du devis centré dans la page
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(horizontal: 30, vertical: 80),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 20),
                // Title centered
                pw.Center(
                  child: pw.Text(
                    'Devis en ligne « AMI Sérénité »',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 10),
                // User's name and personalized message
                pw.Text(
                  'A l\'aimable attention de Mr/Mme : $username\n\n'
                  'Monsieur/Madame, Vous désirez souscrire, auprès de notre société, un contrat d\'assurance Epargne Individuelle « AMI SERENITE » qui vous permet de disposer d\'une réserve d\'épargne pour financer des projets ou des imprévus ou encore de constituer un capital au fil des ans qui peut se transformer en une rente complément de retraite.',
                ),
                pw.SizedBox(height: 20),
                pw.Text('I- Garanties :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Bullet(text: 'En cas de vie au terme du contrat, vous percevrez votre capital prévu.'),
                pw.SizedBox(height: 10),
                pw.Text('II- Détails contrat :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Bullet(text: 'En cas de décès ou d\'invalidité absolue avant le terme du contrat, l\'épargne constituée sera versée aux bénéficiaires désignés.'),
                pw.SizedBox(height: 10),

                // Détails de simulation du client
                pw.Text('Détails de simulation du client :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Bullet(text: 'Date d\'effet : ${formatDate(DateTime.parse(widget.formData['dateEffet']))}'),
                pw.Bullet(text: 'Date de naissance : ${formatDate(DateTime.parse(widget.formData['dateNaissance']))}'),
                pw.Bullet(text: 'Durée en mois : ${widget.formData['durmois']}'),
                pw.Bullet(text: 'Montant prime investi : ${widget.formData['mntprimeInvesti']} DT'),
                pw.Bullet(text: 'Salaire imposable : ${widget.formData['salaireImposable']} DT'),

                pw.SizedBox(height: 20),
                pw.Text('III- Prime et évolution de l\'épargne constituée :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),

                // TABLEAU
                pw.Table.fromTextArray(
                  border: pw.TableBorder.all(width: 0.5),
                  headerAlignment: pw.Alignment.center,
                  columnWidths: {
                    0: pw.FlexColumnWidth(1),
                    1: pw.FlexColumnWidth(2),
                    2: pw.FlexColumnWidth(2),
                    3: pw.FlexColumnWidth(2),
                    4: pw.FlexColumnWidth(2),
                    5: pw.FlexColumnWidth(2),
                  },
                  cellAlignment: pw.Alignment.center,
                  headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  cellStyle: pw.TextStyle(fontSize: 9),
                  data: [
                    <String>[
                      'Année',
                      'Prime Commerciale (DT)',
                      'Cumul des Primes (DT)',
                      'Épargne (DT)',
                      'Gain Financier (DT)',
                      'Gain Fiscal (DT)'
                    ],
                    ...widget.allData!.map((result) {
                      return [
                        result['Annee'].toString(),
                        result['Total_Prime_CumulÃ©e'].toString(),
                        result['Prime_commercial'].toString(),
                        result['Epargne_ConstituÃ©es'].toString(),
                        result['Gain_Financier'].toString(),
                        result['Gain_Fiscal'].toString(),
                      ];
                    }).toList(),
                  ],
                ),

                pw.SizedBox(height: 20),
                pw.Text('Nous restons à votre disposition pour toute information complémentaire.', style: pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
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
        final response = await _apiService.simulateRentePrimeUnique(
          dateEffet: widget.formData['dateEffet'], 
          dateNaissance:
              widget.formData['dateNaissance'], 
          durmois: widget.formData['durmois'], 
          fractRente: selectedValue ?? '', 
          mntprimeInvesti:
              widget.formData['mntprimeInvesti'], 
          salaireImposable:
              widget.formData['salaireImposable'], 
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
