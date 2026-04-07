import 'package:ami_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:printing/printing.dart';

class DetailsPage extends StatefulWidget {
  final List<dynamic>? allData;

  DetailsPage({Key? key, this.allData}) : super(key: key); // Constructor

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final ApiService _apiService = ApiService();
  String? contractType; // Declare the variable here

  @override
  void initState() {
    super.initState();
    _loadContractType(); // Load contractType when the widget is initialized
  }

  Future<void> _loadContractType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      contractType = prefs.getString('contractType'); // Load the value
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Détails',
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
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
           children: [
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.allData?.length ?? 0,
                itemBuilder: (context, index) {
                  final result = widget.allData![index];
                  final cumulativeFiscalGain = _calculateCumulativeFiscalGain(index);
                  return Card(
                    color: Colors.white,
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Color(0xFF009b79), width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16.0),
                      title: Center(
                        child: Text(
                          'Année ${result['Annee']}',
                          style: TextStyle(
                            color: Color(0xFF009b79),
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                        _buildDetailRow('Épargne constituée', result['Epargne_ConstituÃ©es'].toString()),
                        _buildDetailRow('Versements de l’année', result['Total_Prime_CumulÃ©e'].toString()),
                        _buildDetailRow('Gain Financier', result['Gain_Financier'].toString()),
                        _buildDetailRow('Gain Fiscal', result['Gain_Fiscal'].toString()),
                      ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _takeAppointment(context);
                  },
                  icon: Icon(Icons.calendar_today_outlined, color: Colors.white, size: 20),
                  label: Text(
                    'Prendre un RDV',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1c3f93),
                    fixedSize: Size(170, 40),
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
                ElevatedButton.icon(
                  onPressed: () async {
                    if (contractType != null) {
                      await _apiService.sendEmailAgence(contractType!).then((_) async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.remove('contractType'); // Remove contractType after success
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Un conseiller vous contactera bientôt !',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            backgroundColor: Color(0xFF1c3f93),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.all(16),
                            duration: Duration(seconds: 5),
                          ),
                        );
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Essayer encore une autre fois',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            backgroundColor: Color(0xFF009b79),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.all(16),
                            duration: Duration(seconds: 5),
                          ),
                        );
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Aucun type de contrat sélectionné',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          backgroundColor: Color(0xFF009b79),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.all(16),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.mail_outline_outlined, color: Colors.white, size: 20),
                  label: Text(
                    'Assistance Client',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF009b79),
                    fixedSize: Size(180, 40),
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
          ],
        ),
      ),
    );
  }

  void _generateAndPrintPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Proposition d\’assurance Epargne Individuelle \”AMI SERENITE\”',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Agence: 0   |   TEL: 0'),
            pw.SizedBox(height: 10),
            pw.Text(
                'A l\'aimable attention de Mr/MM : TEST TEST\n\nMonsieur/Madame, Vous désirez souscrire, auprès de notre société, un contrat d\'assurance Epargne Individuelle « AMI SERENITE » qui vous permet de disposer d\'une réserve d\'épargne pour financer des projets ou des imprévus ou encore de constituer un capital au fil des ans qui peut se transformer en une rente complément de retraite.'),
            pw.SizedBox(height: 20),
            pw.Text('I- Garanties :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Bullet(text: 'En cas de vie au terme du contrat, vous percevrez votre capital prévu.'),
            pw.Text('II- Détails contrat :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Bullet(text: 'En cas de décès ou d\'invalidité absolue avant le terme du contrat, l\'épargne constituée sera versée aux bénéficiaires désignés.'),
            pw.SizedBox(height: 20),
            pw.Text('III- Prime et évolution de l\'épargne constituée :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Table.fromTextArray(
              data: [
                <String>['Année', 'Prime Commerciale en DT ', 'Cumul des Primes en DT', 'Épargne en DT', 'Gain Financier en DT', 'Gain Fiscal en DT'],
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
              cellAlignment: pw.Alignment.center,
            ),
            pw.SizedBox(height: 20),
            pw.Text('Nous restons à votre disposition pour toute information complémentaire.', style: pw.TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
void _takeAppointment(BuildContext context) async {
  // Sélection de la date
  DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(Duration(days: 365)),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Color(0xFF1c3f93),
          colorScheme: ColorScheme.light(primary: Color(0xFF1c3f93)),
          buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
        ),
        child: child!,
      );
    },
  );

  if (selectedDate != null) {
    // Sélection de l'heure
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF1c3f93),
            colorScheme: ColorScheme.light(primary: Color(0xFF1c3f93)),
            textTheme: TextTheme(
              // Customisation des textes AM/PM
              bodyMedium: TextStyle(
                color: Color(0xFF1c3f93), // Changez la couleur ici
                fontWeight: FontWeight.bold,
                fontFamily: 'GilmerBold'
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      // Combinaison de la date et de l'heure
      DateTime finalDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      String formattedDateTime = DateFormat('dd/MM/yyyy').format(finalDateTime) + ' à ' + DateFormat('HH:mm').format(finalDateTime);
      try {
        await _apiService.sendEmailAgenceRDV(contractType!, formattedDateTime);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rendez-vous pris pour le $formattedDateTime. Confirmation envoyée à l\'agence.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF1c3f93),
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de l\'envoi de l\'email à l\'agence.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}


  Widget _buildDetailRow(String title, String value) {
    final formattedValue = _formatNumber(value);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$title: ',
              style: TextStyle(
                color: Color(0xFF1c3f93),
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            TextSpan(
              text: '$formattedValue DT',
              style: TextStyle(
                color: Color(0xFF1c3f93),
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(String value) {
    try {
      final number = double.parse(value);
      final formatter = NumberFormat('#,##0', 'fr_FR');
      return formatter.format(number);
    } catch (e) {
      return value;
    }
  }

  String _calculateCumulativeFiscalGain(int currentIndex) {
    double cumulativeGain = 0.0;
    for (int i = 0; i <= currentIndex; i++) {
      final gainFiscal = double.tryParse(widget.allData![i]['Gain_Fiscal'].toString()) ?? 0.0;
      cumulativeGain += gainFiscal;
    }
    return _formatNumber(cumulativeGain.toString());
  }
}
