import 'package:ami_mobile/features/simulateurs/screens/SimulateurFormObjectifPage.dart';
import 'package:ami_mobile/features/simulateurs/screens/SimulateurFormVPPage.dart';
import 'package:ami_mobile/features/simulateurs/screens/SimulateurPrimeUniquePage.dart';
import 'package:flutter/material.dart';

class SimulateursPage extends StatefulWidget {
  @override
  _SimulateursPageState createState() => _SimulateursPageState();
}

class _SimulateursPageState extends State<SimulateursPage> {
  int _selectedIndex = -1;
  List<bool> _showDescriptions = List.generate(3, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Row(
    mainAxisAlignment: MainAxisAlignment.start, // Align items to the start of the row
    children: [
      Expanded(
        child: Text(
          'Simulateurs',
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
        padding: EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            return _buildCard(index);
          },
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    final titles = [
      'Je verse un seul montant',
      'Je verse des montants réguliers',
      'Je souhaite constituer une épargne définie',
      //'J\'améliore mon contrat',
      //'Je simule une rente',
    ];

    final descriptions = [
      'Simulation de l\'épargne constituée à partir d\'un montant unique versé initialement dans l\'assurance.',
      'Simulation de l\'épargne constituée à partir de versements réguliers.',
      'Simulation du montant des primes d’assurances à partir des prestations définies.',
      //'Simulation de l\'impact des versements supplémentaires sur l\'amélioration de votre épargne existante.',
      //'Simulation du montant de la rente à partir de votre épargne constituée.',
    ];

    final isSelected = _selectedIndex == index;
    final showDescription = _showDescriptions[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = isSelected ? -1 : index;
        });
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SimulateurPrimeUniquePage()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SimulateurFormVPPage()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SimulateurFormObjectifPage()),
          );
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: SizedBox(
          height: 120.0,
          child: Stack(
            children: [
              Card(
                color: isSelected ? Color(0xFF5230a5) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0), 
            topRight: Radius.circular(30), 
            bottomLeft: Radius.circular(15), 
            bottomRight: Radius.circular(0), 
          ),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      showDescription ? descriptions[index] : titles[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'IBMPlexSans',
                        color: isSelected ? Colors.white : Color(0xFF1c3f93),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 1.0,
                right: 1.0,
                child: IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: isSelected ? Colors.white : Color(0xFF1c3f93),
                  ),
                  onPressed: () {
                    setState(() {
                      _showDescriptions[index] = !showDescription;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

void _showRenteOptionsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Choisissez une option',
          style: TextStyle(
            color: Color(0xFF009b79),
            fontFamily: 'GilmerBold',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Prime Unique',
                style: TextStyle(
                  color: Color(0xFF1c3f93),
                  fontFamily: 'GilmerBold',
                ),
              ),
              onTap: () {
                Navigator.pop(context); 
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SimulateurPrimeUniquePage()),
                );
              },
            ),
            ListTile(
              title: Text(
                'Montant Réguliers',
                style: TextStyle(
                  color: Color(0xFF1c3f93),
                  fontFamily: 'GilmerBold',
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SimulateurFormVPPage()),
                );
              },
            ),
            ListTile(
              title: Text(
                'Épargne Définie',
                style: TextStyle(
                  color: Color(0xFF1c3f93),
                  fontFamily: 'IBMPlexSans',
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SimulateurFormObjectifPage()),
                );
              },
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Fermer',
              style: TextStyle(
                color: Color(0xFFE81917),
                fontFamily: 'IBMPlexSans',
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
      );
    },
  );
}

}
