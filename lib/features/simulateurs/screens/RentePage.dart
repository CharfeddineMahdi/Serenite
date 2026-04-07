import 'package:ami_mobile/features/simulateurs/screens/RenteParObjectif.dart';
import 'package:ami_mobile/features/simulateurs/screens/RentePrimeUnique.dart';
import 'package:ami_mobile/features/simulateurs/screens/RentePrimeUniqueF.dart';
import 'package:ami_mobile/features/simulateurs/screens/RenteVersementsPeriodiques.dart';
import 'package:flutter/material.dart';
import 'package:ami_mobile/features/simulateurs/screens/SimulateurFormVPPage.dart';
import 'package:ami_mobile/features/simulateurs/screens/SimulateurFormObjectifPage.dart';

class RentePage extends StatefulWidget {
  @override
  _RentePageState createState() => _RentePageState();
}

class _RentePageState extends State<RentePage> {
  int _selectedIndex = -1;
  List<bool> _showDescriptions = List.generate(3, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Simuler une Rente',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF04348C),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: 3, // 3 types de rente
          itemBuilder: (context, index) {
            return _buildCard(index);
          },
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    final titles = [
      'Rente à partir d\'une prime unique',
      'Rente à partir de montants réguliers',
      'Rente à partir d\'une épargne définie',
    ];

    final descriptions = [
      'Simulation de la rente à partir d\'une prime unique versée initialement.',
      'Simulation de la rente à partir de versements réguliers.',
      'Simulation de la rente à partir d\'une épargne préalablement définie.',
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
            MaterialPageRoute(builder: (context) => RentePrimeUniqueF()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RenteVersementsPeriodiques()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RenteParObjectif()),
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
}
