import 'dart:convert';
import 'package:ami_mobile/features/contract/screens/ContractCard.dart';
import 'package:ami_mobile/features/simulateurs/screens/SimulateurPage.dart';
import 'package:flutter/material.dart';
import 'package:ami_mobile/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _contratController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isAuthentificated = false; 
  bool _enabled = false; 
  List<dynamic> _contrats = []; 
  int _selectedIndex = 0; 

  @override
  void initState() {
    super.initState();
    _loadAuthenticationStatus();
  }

  
  void _loadAuthenticationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAuthentificated = prefs.getBool('isAuthentificated') ?? false;
      _enabled = prefs.getBool('isEnabled') ?? false;
    });
    if (_isAuthentificated && _enabled) {
      _loadContrats();
    }
  }

  // Method to load contracts from the API
  void _loadContrats() async {
    try {
      String response = await _apiService.ListContratsClient();
      setState(() {
        _contrats = jsonDecode(response);
      });
    } catch (e) {
      _showErrorToast('Erreur lors du chargement des contrats.');
    }
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Color(0xFF1c3f93),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Color(0xFF009b79),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  final List<Widget> _pages = [
   HomePage(),
   SimulateurPage()
   
  ];
@override
Widget build(BuildContext context) {
  return Scaffold(
    key: _scaffoldKey,
appBar: PreferredSize(
  preferredSize: Size.fromHeight(120.0),
  child: Container(
    height: 120.0,
    decoration: BoxDecoration(
      color: Color(0xFF1c3f93),
      image: DecorationImage(
        image: AssetImage('assets/images/appBarPatternBlue.png'),
        repeat: ImageRepeat.repeat, 
        alignment: Alignment.topLeft, 
        scale: 5.0, 
      ),
    ),
    child: Stack(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),
      ],
    ),
  ),
),




    body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: _isAuthentificated
        ? _enabled
          ? ListView.builder(
              itemCount: _contrats.length,
              itemBuilder: (context, index) {
                final contrat = _contrats[index];
                return ContractCard(contrat: contrat);
              },
            )
          : Center(
              child: Container(
                padding: EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                  color: Color(0xFF009b79),
                  borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(40),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(0),
        ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'Veuillez vous rendre vers votre agence pour activer le suivi de vos contrats.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'GilmerRegular',
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
        : Center(
            child: Container(
  padding: EdgeInsets.all(20.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Veuillez ajouter le numéro de votre contrat',
        style: TextStyle(
          fontSize: 17,
          color: Color(0xFF1c3f93),
          fontFamily: 'GilmerRegular',
        ),
      ),
      SizedBox(height: 20),
      Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _contratController,
              decoration: InputDecoration(
                labelText: 'Numéro de contrat',
                labelStyle: TextStyle(
                  color: Color(0xFF1c3f93),
                  fontSize: 18.0,
                  fontFamily: 'GilmerRegular',
                ),
                floatingLabelStyle: TextStyle(
                  color: Color(0xFF1c3f93),
                  fontSize: 18.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(0),
                  ),
                  borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(0),
                  ),
                  borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(0),
                  ),
                  borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(0),
                  ),
                  borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)),
                ),
                errorStyle: TextStyle(
                  color: Color(0xFF009b79),
                  fontSize: 14,
                  height: 1.5,
                ),
                prefixIcon: IconButton(
                  onPressed: () {
                    // Action à effectuer lors du clic sur le bouton
                  },
                  icon: Icon(Icons.qr_code_outlined),
                  color: Color(0xFF009b79),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le numéro de contrat est requis';
                }
                if (value.length != 15) {
                  return 'Le numéro de contrat doit contenir\nexactement 15 chiffres';
                }
                final RegExp contractNumberRegex = RegExp(r'^[0-9.\\\/]+$');
                if (!contractNumberRegex.hasMatch(value)) {
                  return 'Numéro invalide';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _addContract, // Méthode à exécuter lors du clic
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.center,
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
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(0),
                  ),
                ),
                child: Text(
                  'Ajouter',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'GilmerRegular',
                    fontSize: 16,
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
 ),
      ),
    drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(),
            child: Container(
              width: 20,
              height: 20,
              child: Image.asset(
                'assets/images/Logotype-BNA-Assurances-Horizontal.png',
                //fit: BoxFit.scaleDown,
              ),
            ),
          ),
          ListTile(
  leading: Container(
    padding: EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Color(0xFF009b79), // Couleur de fond du cadre
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
    ),
    child: Icon(
      Icons.home_outlined,
      color: Colors.white, // Couleur de l'icône
    ),
  ),
  title: Text(
    'Accueil',
    style: TextStyle(
      color: Colors.white, // Couleur du texte
      fontFamily: 'IBMPlexSans',
    ),
  ),
  selectedTileColor: Color(0xFF1c3f93), // Couleur de fond sélectionnée
  selected: true, // Marque le ListTile comme sélectionné
  onTap: () {
    _scaffoldKey.currentState?.openEndDrawer();
  },
),
          ListTile(
  leading: Container(
    padding: EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Color(0xFF009b79),
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0), 
          topRight: Radius.circular(20), 
          bottomLeft: Radius.circular(10), 
          bottomRight: Radius.circular(0), 
        ), // Coins arrondis
      
    ),
    child: Icon(
      Icons.calculate_outlined,
      color: Colors.white, 
    ),
  ),
  title: Text(
    'Simulateur',
    style: TextStyle(
      color: Color(0xFF1c3f93),
      fontFamily: 'IBMPlexSans',
    ),
  ),
  selectedTileColor: Colors.white,
  onTap: () {
    Navigator.pushNamed(context, '/simulateur'); 
  },
),
ListTile(
  leading: Container(
    padding: EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Color(0xFF009b79), // Couleur de fond du cadre
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0), 
          topRight: Radius.circular(20), 
          bottomLeft: Radius.circular(10), 
          bottomRight: Radius.circular(0), 
        ),
    ),
    child: Icon(
      Icons.notifications_outlined,
      color: Colors.white, // Couleur de l'icône
    ),
  ),
  title: Text(
    'Notifications',
    style: TextStyle(
      color: Color(0xFF1c3f93),
      fontFamily: 'IBMPlexSans',
    ),
  ),
  selectedTileColor: Colors.white,
  onTap: () {
    _scaffoldKey.currentState?.openEndDrawer();
  },
),
         ListTile(
  leading: Container(
    padding: EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Color(0xFF009b79),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
    ),
    child: Icon(
      Icons.assignment_outlined,
      color: Colors.white, 
    ),
  ),
  title: Text(
    'Contrat',
    style: TextStyle(
      color: Color(0xFF1c3f93), 
      fontFamily: 'IBMPlexSans',
    ),
  ),
  selectedTileColor: Colors.white, 
  onTap: () {
    _scaffoldKey.currentState?.openEndDrawer();
  },
),
         ListTile(
  leading: Container(
    padding: EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Color(0xFF009b79), // Couleur de fond du cadre
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
    ),
    child: Icon(
      Icons.person_outlined,
      color: Colors.white, // Couleur de l'icône
    ),
  ),
  title: Text(
    'Profil',
    style: TextStyle(
      color: Color(0xFF1c3f93),
      fontFamily: 'IBMPlexSans',
    ),
  ),
  selectedTileColor: Colors.white, // Couleur de fond sélectionnée
  onTap: () {
    _scaffoldKey.currentState?.openEndDrawer();
  },
),

ListTile(
  leading: Container(
    padding: EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Color(0xFF009b79), // Couleur de fond du cadre
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
    ),
    child: Icon(
      Icons.chat_outlined,
      color: Colors.white, // Couleur de l'icône
    ),
  ),
  title: Text(
    'Réclamations',
    style: TextStyle(
      color: Color(0xFF1c3f93),
      fontFamily: 'IBMPlexSans',
    ),
  ),
  selectedTileColor: Colors.white, // Couleur de fond sélectionnée
  onTap: () {
    Navigator.pushNamed(context, '/reclamations');
  },
),

ListTile(
  leading: Container(
    padding: EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: Color(0xFF009b79), 
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
    ),
    child: Icon(
      Icons.logout_outlined,
      color: Colors.white, 
    ),
  ),
  title: Text(
    'Déconnexion',
    style: TextStyle(
      color: Color(0xFF1c3f93),
      fontFamily: 'IBMPlexSans',
    ),
  ),
  selectedTileColor: Colors.white, 
  onTap: () {
    Navigator.of(context).pop();
    _apiService.logout(context);
  },
),
        ],
      ),
    ),
    bottomNavigationBar: Material(
      elevation: 30,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30.0),
        topRight: Radius.circular(30.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  selectedItemColor: Color(0xFF009b79),
  unselectedItemColor: Color(0xFF1c3f93),
  backgroundColor: Colors.white,
  items: [
    BottomNavigationBarItem(
      icon: _buildIconWithBorderRadius(Icons.home, isSelected: _selectedIndex == 0),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: _buildIconWithBorderRadius(Icons.calculate, isSelected: _selectedIndex == 1),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: _buildIconWithBorderRadius(Icons.credit_card, isSelected: _selectedIndex == 2),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: _buildIconWithBorderRadius(Icons.assignment, isSelected: _selectedIndex == 3),
      label: '',
    ),
    BottomNavigationBarItem(
      icon: _buildIconWithBorderRadius(Icons.person, isSelected: _selectedIndex == 4),
      label: '',
    ),
  ],
  currentIndex: _selectedIndex,
  onTap: _onItemTapped,
),
      ),
    ),
  );
}

void _addContract() async {
 if (_formKey.currentState?.validate() ?? false) {
      try {
        String message = await _apiService.getContratsClient(_contratController.text);
        // Display message based on the response
        if (message.contains('succès')) {
          _showSuccessToast(message);
        } else {
          _showErrorToast(message);
        }
      } catch (e) {
        // Display error message in case of exception
        _showErrorToast('Erreur lors de l\'ajout du contrat.');
      }
    }

  }

 // Méthode appelée lorsque l'utilisateur tape sur un élément
 void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });
  switch (index) {
    case 0:
      Navigator.pushNamed(context, '/home');
      break;
    case 1:
      Navigator.pushNamed(context, '/simulateurs');
      break;
    // Add cases for other navigation as needed
  }
}
Widget _buildIconWithBorderRadius(IconData icon, {required bool isSelected}) {
  return Container(
    padding: EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: isSelected ? Color(0xFF009b79).withOpacity(0.2) : Colors.transparent,
      border: isSelected
          ? Border.all(
              color: Color(0xFF009b79),
              width: 1.0,
            )
          : null, // Pas de bordure si non sélectionné
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
    ),
    child: Icon(
      icon,
      color: isSelected ? Color(0xFF009b79) : Color(0xFF1c3f93),
      size: 24.0,
    ),
  );
}
  Widget _buildCircularIcon(IconData iconData) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color.fromARGB(78, 189, 189, 189)),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
        color: Colors.white,
      ),
      child: Icon(iconData, color: Color(0xFF1c3f93)),
    );
  }
}
