import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailsRentePage extends StatelessWidget {
  final Map<String, dynamic> renteData;
  final List<dynamic>? allData;

  DetailsRentePage({required this.renteData, this.allData});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF04348C); // Dark blue
    final Color accentColor = Color(0xFF009b79); 

    // If allData is not null, calculate total gain fiscal
    double totalGainFiscal = allData != null
        ? allData!.fold(0.0, (sum, item) => sum + (item['Gain_Fiscal'] ?? 0.0))
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détails Rente',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor, // AppBar color
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
                  _buildCard('Épargne Constituée', renteData['mnt_epargne_constitu'].toString()),
                  _buildCard('Versements', renteData['mntprimetotal'].toString()),
                  _buildCard('Durée de Rente', renteData['duree_rente_parAN'].toString()),
                  _buildCard('Gain Fiscal', totalGainFiscal.toString()),
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
                      // Action for the button
                      print('Action for "Consulter l\'évolution prévisionnelle de votre épargne"');
                    },
                    child: Text(
                      'Consulter l\'évolution prévisionnelle de votre épargne',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      fixedSize: Size(400, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // Action for the button
                      print('Voulez-vous transformer votre capital en une rente ?');
                    },
                    child: Text(
                      'Voulez-vous transformer votre capital en une rente ?',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      fixedSize: Size(400, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
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
                      color: Color(0xFF009b79), // Red color for the value
                      fontSize: 18.0,
                    ),
                  ),
                  TextSpan(
                    text: ' DT', // Adding "DT" as text
                    style: TextStyle(
                      color: Color(0xFF009b79), // Matching color for "DT"
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

  String _formatNumber(String value) {
    try {
      final number = double.parse(value);
      final formatter = NumberFormat('#,##0', 'fr_FR'); // French locale
      return formatter.format(number);
    } catch (e) {
      return value; // Return the original value in case of error
    }
  }
}
