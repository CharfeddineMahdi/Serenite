import 'package:ami_mobile/features/contract/screens/QuittancesPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class ContractCard extends StatelessWidget {
  final Map<String, dynamic> contrat;

  ContractCard({required this.contrat});

@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContractDetailPage(contrat: contrat),
        ),
      );
    },
    child: Padding ( padding: const EdgeInsets.only(bottom: 20.0),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF009b79),
            Color(0xFF1c3f93),
            Color(0xFF5230a5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(60),
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(0),
        ),
        border: Border.all(color: Color(0xFF009b79), width: 0.1),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(60),
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(0), 
          ),
        ),
        elevation: 5,
        color: Colors.white, 
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF009b79),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(4, 4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    '${contrat['NUMCNT']}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                       fontFamily: 'GilmerRegular',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Produit: Sérénité ',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'GilmerRegular',
                  color: Color(0xFF04348C),
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Épargne constituée: ${contrat['EPARGNE']} DT',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'GilmerRegular',
                  color: Color(0xFF04348C),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 20, color: Color(0xFF009b79)),
                  SizedBox(width: 8),
                  Text(
                    _formatDate(contrat['DEBCNT']),
                    style: TextStyle(fontSize: 16, color: Color(0xFF04348C), fontFamily: 'GilmerRegular'),
                  ),
                  SizedBox(width: 20),
                  Transform.scale( 
                    scaleX: 1.5,
                    child: Icon(Icons.arrow_forward, size: 20, color: Color(0xFF009b79)),
                  ),
                  SizedBox(width: 20),
                  Icon(Icons.calendar_today, size: 20, color: Color(0xFF009b79)),
                  SizedBox(width: 8),
                  Text(
                    _formatDate(contrat['FINCNT']),
                    style: TextStyle(fontSize: 16, color: Color(0xFF04348C), fontFamily: 'GilmerRegular'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Align(
  alignment: Alignment.centerRight, // Aligne le bouton à droite
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContractDetailPage(contrat: contrat),
        ),
      );
    },
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Color(0xFF04348C),
      fixedSize: Size(150, 40),
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(0),
        ),
      ),
      textStyle: TextStyle( 
        fontFamily: 'GilmerBold', 
      ),
    ),
    child: Text('Détails'),
  ),
),
              SizedBox(height: 5),
            ],
          ),
        ),
      ),
    ),)
  );
}
}
  String _getFractionnementLabel(String fract) {
    switch (fract) {
      case 'A':
        return 'Annuel';
      case 'S':
        return 'Semestriel';
      case 'M':
        return 'Mensuel';
      default:
        return fract;
    }
  }

  String _getSituationLabel(String situat) {
    switch (situat) {
      case 'E':
        return 'En cours';
      case 'R':
        return 'Résilié';
      default:
        return situat;
    }
  }
String _formatDate(String dateString) {
    // Extract year, month, and day from the date string
    final String year = dateString.substring(0, 4);
    final String month = dateString.substring(4, 6);
    final String day = dateString.substring(6, 8);

    // Return formatted date
    return '$day/$month/$year';
  }


class ContractDetailPage extends StatelessWidget {
  final Map<String, dynamic> contrat;

  ContractDetailPage({required this.contrat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détails du contrat',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'GilmerRegular', 
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
      body: SingleChildScrollView( 
        padding: EdgeInsets.all(20.0),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(60),
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(0),
        ),
        //border: Border.all(color: Color(0xFF009b79), width: 0.1),
      ),
          elevation: 5,
          borderOnForeground: true,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Center(
  child: Container(
    padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
    decoration: BoxDecoration(
      color: Color(0xFF04348C),
      borderRadius: BorderRadius.circular(5.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          offset: Offset(4, 4),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Text(
      'SÉRÉNITÉ',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'GilmerRegular',
      ),
    ),
  ),
),
 SizedBox(height: 20),
                    Column(
  crossAxisAlignment: CrossAxisAlignment.start, 
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Épargne constituée',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
             fontFamily: 'GilmerRegular',
            color: Color(0xFF04348C),
          ),
        ),
        Text(
          '${contrat['EPARGNE']} DT',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF009b79), 
          ),
        ),
      ],
    ),
    SizedBox(height: 4), 
    Row(
      children: [
         Icon(
          Icons.info_outline,
          color: Color(0xFF009b79),
          size: 18, 
        ),
        SizedBox(width: 5), 
        Text(
          'calculée le ${_formatDate(contrat['DATECALPM'])}',
          style: TextStyle(
            fontSize: 14, 
            color: Color(0xFF04348C),
          ),
        ),
     
       
      ],
    ),
  ],
),
 SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TimelineEntry(
                            icon: Icons.person_outlined,
                            label: 'Nom: ${contrat['NOMREDCL']}',
                          ),
                          _TimelineSeparator(),
                          _TimelineEntry(
                            icon: Icons.calendar_today_outlined,
                            label: 'Date début: ${_formatDate(contrat['DEBCNT'])}',
                          ),
                          _TimelineSeparator(),
                          _TimelineEntry(
                            icon: Icons.autorenew_outlined,
                            label: 'Périodicité des versements: ${_getFractionnementLabel(contrat['FRACT'])}',
                          ),
                          _TimelineSeparator(),
                          _TimelineEntry(
                            icon: Icons.circle_outlined,
                            label: 'Situation: ${_getSituationLabel(contrat['SITUAT'])}',
                          ),
                          _TimelineSeparator(),
                          _TimelineEntry(
                            icon: Icons.access_time_outlined,
                            label: 'Durée: ${contrat['DUREE']} ans',
                          ),
                          _TimelineSeparator(),
                          _TimelineEntry(
                            icon: Icons.monetization_on_outlined,
                            label: 'Montant versé: ${contrat['MNTPRNET']} DT',
                          ),
                          _TimelineSeparator(),
                           _TimelineEntry(
                            icon: Icons.group_outlined,
                            label: 'Bénéficiaire(s) : ${contrat['BENEFDECE']} ',
                          ),
                          _TimelineSeparator(),
                          _TimelineEntry(
                            icon: Icons.calendar_today_outlined,
                            label: 'Date fin: ${_formatDate(contrat['FINCNT'])}',
                          ),
                        ],
                      ),
                      Center(
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuittancesPage(
            numCNT: contrat['NUMCNT'],
          ),
        ),
      );
    },
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Color(0xFF009b79),
      fixedSize: Size(150, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(0),
        ),
      ),
    ),
    child: Text('Versements'),
  ),
),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


  Widget _TimelineEntry({required IconData icon, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFF009b79), width: 1),
            ),
            child: Icon(icon, color: Color(0xFF009b79), size: 16),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
             style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'GilmerRegular',
                  color: Color(0xFF04348C),
                ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _TimelineSeparator() {
  return Padding(
    padding: const EdgeInsets.only(left: 10.0), // Adjust the padding as needed
    child: Container(
      width: 1,
      height: 30,
      color: Color(0xFF009b79),
    ),
  );
}
