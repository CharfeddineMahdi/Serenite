import 'package:flutter/material.dart';
import 'package:ami_mobile/services/api_service.dart';
import 'package:intl/intl.dart';

class QuittancesPage extends StatefulWidget {
  final String numCNT;

  QuittancesPage({required this.numCNT});

  @override
  _QuittancesPageState createState() => _QuittancesPageState();
}

class _QuittancesPageState extends State<QuittancesPage> {
  late Future<List<dynamic>> quittances;

  @override
  void initState() {
    super.initState();

    final apiService = ApiService();
    quittances = apiService.fetchQuittances(widget.numCNT);
  }

  String _getStatutQuittance(dynamic statut) {
    int statusInt = int.tryParse(statut.toString()) ?? -1;

    if (statusInt == 0) {
      return 'Non payé';
    } else if (statusInt == 1) {
      return 'Payé';
    } else if (statusInt == 2) {
      return 'Annulée';
    } else {
      return 'Inconnu';
    }
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      print("Error parsing date: $e");
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Versements',
          style: TextStyle(color: Colors.white,
           fontFamily: 'GilmerRegular',),
        ),
        backgroundColor: Color(0xFF04348C),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: quittances,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune quittance disponible'));
          } else {
            final quittancesList = snapshot.data!;
            return ListView.builder(
              itemCount: quittancesList.length,
              itemBuilder: (context, index) {
                final quittance = quittancesList[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Color(0xFF5230a5), 
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0), 
            topRight: Radius.circular(30), 
            bottomLeft: Radius.circular(10), 
            bottomRight: Radius.circular(0), 
          ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      /*   Text(
                          'Quittance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold, 
                            color: Color(0xFF04348C),
                          ),
                        ), */
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.date_range, color: Color(0xFF5230a5)),
                            SizedBox(width: 10),
                            Text(
                              'Date d’échéance : ${_formatDate(quittance['DEBEFFQUI'].toString())}',
                              style: TextStyle(
        color: Color(0xFF04348C),
        fontSize: 15,
        fontWeight: FontWeight.bold,
        fontFamily: 'GilmerRegular',
      ),
                            ),
                            
                          ],
                        ),
                        SizedBox(height: 10),
                       Row(
                       children: [
                      Icon(Icons.account_balance_wallet, color: Color(0xFF5230a5)),
                      SizedBox(width: 10),
    Text(
      'Montant : ${quittance['MNTPRNET'].toStringAsFixed(3)} DT',
      style: TextStyle(
        color: Color(0xFF04348C),
        fontSize: 15,
        fontWeight: FontWeight.bold,
        fontFamily: 'GilmerRegular',
      ),
    ),
  ],
),
 SizedBox(height: 10),
                        Row(
  children: [
    Icon(Icons.receipt, color: Color(0xFF5230a5)),
    SizedBox(width: 10),
    RichText(
      text: TextSpan(
        text: 'Statut : ', // Texte "Statut :" en couleur normale
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'GilmerRegular',
          color: Color(0xFF04348C),
        ),
        children: [
          TextSpan(
            text: _getStatutQuittance(quittance['STATQUIT']), 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'GilmerRegular',
              color: _getStatutQuittance(quittance['STATQUIT']) == 'Non payé'
                  ? Color(0xFF009b79) 
                  : Color(0xFF04348C), 
            ),
          ),
        ],
      ),
    ),
  ],
),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  String _formatNumber(String value) {
    try {
      final number = double.parse(value);
      final formatter = NumberFormat('#,000', 'fr_FR');
      return formatter.format(number);
    } catch (e) {
      return value;
    }
  }



}
