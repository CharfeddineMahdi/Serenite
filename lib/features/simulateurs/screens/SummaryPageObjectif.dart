import 'package:ami_mobile/features/simulateurs/screens/DetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryPageObjectif extends StatelessWidget {
  final Map<String, dynamic> summaryData;
  final List<dynamic>? allData;
  final double primePerPeriod;
final String fractLabel; // Add this line for the label

  SummaryPageObjectif({required this.summaryData, this.allData, required this.primePerPeriod, required this.fractLabel});

  @override
  Widget build(BuildContext context) {
    // Vérifier si allData est null, sinon utiliser fold pour calculer la somme
    double totalGainFiscal = allData != null
        ? allData!.fold(0.0, (sum, item) => sum + (item['Gain_Fiscal'] ?? 0.0))
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Résultats',
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
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildCard('Épargne Constituée', summaryData['Epargne_ConstituÃ©es'].toString()),
                  _buildCard('Prime par ${_getReadableFractLabel(fractLabel)}', primePerPeriod.toString()),
                  //_buildCard('Versements', summaryData['Total_Prime_CumulÃ©e'].toString()),
                  _buildCard('Gain Fiscal', totalGainFiscal.toString()), 
                  //_buildCard('Gain Fiscal', summaryData['Gain_Fiscal'].toString()), 
                  _buildCard('Gain Financier', summaryData['Gain_Financier'].toString()),
                  //_buildCard('Prime par ${_getReadableFractLabel(fractLabel)}', primePerPeriod.toString()),
                  //_buildCard('Fréquence', fractLabel), // Display fractLabel with label

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
                          builder: (context) => DetailsPage(allData: allData),
                        ),
                      );
                    },
                    child: Text(
                      'Consulter l\'évolution prévisionnelle de votre épargne',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE81917),
                      fixedSize: Size(400, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  /* SizedBox(height: 16.0), // Ajoute un espacement entre les boutons
                  ElevatedButton(
                    onPressed: () {
                      // Ajoutez ici l'action que vous voulez pour ce bouton
                      print('Voulez-vous transformer votre capital en une rente ?');
                    },
                    child: Text(
                      'Voulez-vous transformer votre capital en une rente ?',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF04348C), // Différente couleur si souhaité
                      fixedSize: Size(400, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ), */
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String value) {
    final formattedValue = _formatNumber(value);
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Color(0xFF04348C), // Blue color for the title
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
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
                      color: Color(0xFFE81917), // Red color for the value
                      fontSize: 18.0,
                    ),
                  ),
                  TextSpan(
                    text: ' DT', // Adding "DT" as text
                    style: TextStyle(
                      color: Color(0xFFE81917), // Matching color for "DT"
                      fontSize: 18.0,
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

  String _getReadableFractLabel(String fractLabel) {
  switch (fractLabel) {
    case 'M':
      return 'Mois';
    case 'A':
      return 'An';
    case 'T':
      return 'Trimestre';
    case 'S':
      return 'Semestre';
    default:
      return fractLabel; 
  }
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
}
