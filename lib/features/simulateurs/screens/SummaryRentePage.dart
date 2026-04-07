import 'package:ami_mobile/features/simulateurs/screens/DetailsPage.dart';
import 'package:ami_mobile/features/simulateurs/screens/DetailsRentePage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SummaryRentePage extends StatelessWidget {
  final Map<String, dynamic> renteData;

  // Constructor to receive rente data
  SummaryRentePage({required this.renteData});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF1c3f93); 
    final Color accentColor = Color(0xFF009b79); 

    return Scaffold(
         appBar: AppBar(
         title: Row(
    mainAxisAlignment: MainAxisAlignment.start, 
    children: [
      Expanded(
        child: Text(
          'Résultat Rente',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            // Card for Montant Rente
            buildSummaryCard(
              'Montant Rente',
              _formatNumber(renteData['mnt_rente']?.toString() ?? '0'),
              primaryColor,
            ),
            // Card for Type de Rente
            buildSummaryCard(
              'Type de Rente',
              _mapRenteType(renteData['typE_rente']?.toString() ?? ''),
              primaryColor,
            ),
             // **Ajout conditionnel de la carte 'Durée de la Rente'**
            if (renteData['typE_rente']?.toString() == 'T')
              buildSummaryCard(
                'Durée de la Rente',
                '${renteData['duree_rente_parAN']?.toString() ?? '0'} ans',
                primaryColor,
              ),
            // Card for Fractionnement
            buildSummaryCard(
              'Fractionnement',
              _mapFractionnement(renteData['fract_rente']?.toString() ?? ''),
              primaryColor,
            ),
            // Card for Épargne Constituée
            buildSummaryCard(
              'Épargne Constituée',
              _formatNumber(renteData['mnt_epargne_constitu']?.toString() ?? '0'),
              primaryColor,
            ),
            SizedBox(height: 20),
/*             Center(
  child: ElevatedButton(
    onPressed: () {
      // Action à effectuer lors de l'appui sur le bouton
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailRentePage(renteData: renteData),
        ),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: accentColor, // Couleur du bouton
    ),
    child: Text(
      'Voir les détails',
      style: TextStyle(
        color: Colors.white, // Couleur du texte du bouton
      ),
    ),
  ),
), */

          ],
        ),
      ),
    );
  }

  // Fonction modifiée pour ajouter 'dt' aux valeurs spécifiques
  Widget buildSummaryCard(String title, String value, Color primaryColor) {
    // Liste des titres pour lesquels on veut ajouter 'dt' après la valeur
    List<String> titlesWithDt = ['Montant Rente', 'Épargne Constituée'];

    // Si le titre fait partie de la liste, ajouter 'dt' à la valeur
    String displayValue = titlesWithDt.contains(title) ? '$value dt' : value;

    return Container(
      height: 80,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Color(0xFF009b79),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(
              color: primaryColor,
              fontFamily: 'GilmerBold',
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        trailing: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            displayValue, // Affichage de la valeur avec ou sans 'dt'
            style: TextStyle(
              color: primaryColor,
              fontFamily: 'Roboto',
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }

  String _mapRenteType(String type) {
    switch (type) {
      case 'V':
        return 'Viagère';
      case 'T':
        return 'Temporaire';
      default:
        return 'N/A';
    }
  }

  String _mapFractionnement(String fractionnement) {
    switch (fractionnement) {
      case 'T':
        return 'Trimestriel';
      case 'S':
        return 'Semestriel';
      case 'A':
        return 'Annuel';
      case 'M':
        return 'Mensuel';
      default:
        return 'N/A';
    }
  }

  // Utility method for formatting numbers
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

class DetailRentePage extends StatelessWidget {
  final Map<String, dynamic> renteData;
  final List<dynamic>? allData;

  DetailRentePage({required this.renteData, this.allData});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF1c3f93); // Dark blue
    final Color accentColor = Color(0xFF009b79); 

    // Vérification et calcul du gain fiscal
    double totalGainFiscal = allData != null
        ? allData!.fold(0.0, (sum, item) {
            print('Item: $item'); 
            return sum + (item['Gain_Fiscal'] ?? 0.0);
          })
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détails Rente ',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
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
                  _buildCard('Gain Financier', renteData['mnt_gain_financier'].toString()),
                  _buildCard('Gain Fiscal', renteData['mnt_gain_fiscal'].toString()),
                ],
              ),
            ),
            SizedBox(height: 20),
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
                color: Color(0xFF1c3f93),
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
                      color: Color(0xFF009b79),
                      fontSize: 18.0,
                    ),
                  ),
                  TextSpan(
                    text: ' DT',
                    style: TextStyle(
                      color: Color(0xFF009b79),
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
      final formatter = NumberFormat('#,##0', 'fr_FR');
      return formatter.format(number);
    } catch (e) {
      return value;
    }
  }
}