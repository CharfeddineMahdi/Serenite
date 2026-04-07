import 'package:ami_mobile/features/auth/screens/SignUpPage.dart';
import 'package:ami_mobile/features/auth/screens/forgotPassword.dart';
import 'package:ami_mobile/screens/home_page.dart';
import 'package:ami_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  String _errorMessage = '';
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;

  Future<void> _login(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    ApiService authService = ApiService();
    try {
      var response = await authService.signin(
        _usernameController.text,
        _passwordController.text,
      );
      print('Authentification réussie: $response');
      // Exemple de navigation vers la page suivante après une connexion réussie
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
    } catch (e) {
      print('Erreur d\'authentification: $e');
      setState(() {
        _errorMessage = 'Échec de l\'authentification. Vérifiez vos identifiants.';
      });
      Fluttertoast.showToast(
        msg: 'Échec de l\'authentification. Vérifiez vos identifiants.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Color(0xFF009b79),
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://www.assurancesami.com/sites/default/files/notice_de_protection_des_donnees_personnelles.pdf');
    if (!await launch(url.toString())) {
      throw 'Impossible de lancer $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 70.0),
              padding: EdgeInsets.all(20.0),
              child: Image.asset(
                'assets/images/LogoTransparent.png',
                height: 80.0,
              ),
            ),
            LoginForm(
              usernameController: _usernameController,
              passwordController: _passwordController,
            ),
            // Mot de passe oublié
            Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>ForgotPasswordPage()),
                    );
                  },
                  child: Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(
                      color: Color(0xFF009b79),
                      fontFamily: 'GilmerRegular',
                    ),
                  ),
                ),
              ),
            ),
          // Boutons de connexion et d'inscription côte à côte
/* Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    // Bouton "Login"
    Container(
      width: 150,
      height: 50,
      decoration: BoxDecoration(
        color: Color(0xFF1c3f93), // Couleur bleue
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0), // Pas d'arrondi
          topRight: Radius.circular(25), // Coin supérieur droit arrondi
          bottomLeft: Radius.circular(10), // Coin inférieur gauche légèrement arrondi
          bottomRight: Radius.circular(0), // Pas d'arrondi
        ),
      ),
      child: Center(
        child: Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'GilmerRegular',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    SizedBox(width: 5), // Espacement entre les boutons
    // Bouton "S'inscrire"
    Container(
      width: 150,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.teal, // Couleur verte
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0), // Pas d'arrondi
          topRight: Radius.circular(25), // Coin supérieur droit arrondi
          bottomLeft: Radius.circular(10), // Coin inférieur gauche légèrement arrondi
          bottomRight: Radius.circular(0), // Pas d'arrondi
        ),
      ),
      child: Center(
        child: Text(
          "S'inscrire",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'GilmerRegular',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ],
), */
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
  
    GestureDetector(
      onTap: _isLoading ? null : () => _login(context),
      child: Container(
        width: 300,
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xFF009b79),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0), 
            topRight: Radius.circular(30), 
            bottomLeft: Radius.circular(10), 
            bottomRight: Radius.circular(0), 
          ),
        ),
        child: Center(
          child: Text(
            'Connexion',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'GilmerRegular',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
    SizedBox(height: 10), // Espacement entre les deux boutons
    // Bouton "S'inscrire"
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUpPage()),
        );
      },
      child: Container(
        width: 300,
        height: 50,
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
        child: Center(
          child: Text(
            'S\'inscrire',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'GilmerRegular',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  ],
),
            // Ligne grise
            Container(
              margin: EdgeInsets.only(top: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 20.0, left: 30.0),
                      height: 1.0,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Ou',
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'GilmerRegular',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 20.0, left: 20.0),
                      height: 1.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15.0),
              alignment: Alignment.center,
              child: Text(
                'Authentification biométrique',
                style: TextStyle(
                  fontFamily: 'GilmerRegular',
                  color: Color(0xFF1c3f93),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Icone de l'empreinte digitale
            GestureDetector(
              onTap: () async {
                final LocalAuthentication auth = LocalAuthentication();
                bool authenticated = false;
                try {
                  authenticated = await auth.authenticate(
                    localizedReason: 'Veuillez vous authentifier pour vous connecter',
                    //useErrorDialogs: true,
                    //stickyAuth: true,
                  );
                  if (authenticated) {
                    // Action à effectuer après l'authentification réussie
                    print('Authentification réussie!');
                  }
                } catch (e) {
                  print(e);
                }
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Icon(
                  Icons.fingerprint,
                  size: 50.0,
                  color: Color(0xFF1c3f93),
                ),
              ),
            ),
            // Lien des conditions générales
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(20.0),
              child: TextButton(
                onPressed: _launchURL,
                child: Text(
                  'Les politiques de confidentialité',
                  style: TextStyle(
                    color: Color(0xFF009b79),
                    fontFamily: 'GilmerRegular',
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF009b79),
                  ),
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  const LoginForm({
    Key? key,
    required this.usernameController,
    required this.passwordController,
  }) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
  controller: widget.usernameController,
  style: TextStyle(
    fontSize: 16.0, 
    fontFamily: 'GilmerHeavy', 
  ),
  decoration: InputDecoration(
    labelText: 'Login',
    labelStyle: TextStyle(
      fontSize: 16.0,
      fontFamily: 'GilmerHeavy',
      color: Colors.grey,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
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
    prefixIcon: Icon(
      Icons.person_outlined,
      color: Color(0xFF009b79),
    ),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Le champ Login est requis';
    }
    return null;
  },
),
          SizedBox(height: 20.0),
          TextField(
            controller: widget.passwordController,
            obscureText: !_showPassword,
            decoration: InputDecoration(
    labelText: 'Mot de passe',  // Définir le texte du label ici
    labelStyle: TextStyle(
      fontSize: 16.0,
      fontFamily: 'GilmerHeavy',  // Appliquez la police au label
      color: Colors.grey,        // Couleur du texte du label
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              border: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)), // Couleur de bordure bleue par défaut
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF1c3f93)), // Couleur de bordure bleue par défaut
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)), // Couleur de bordure lors du focus
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(0),
        topRight: Radius.circular(30),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(0),
      ),
      borderSide: BorderSide(width: 1.5, color: Color(0xFF009b79)), // Couleur de bordure en cas d'erreur
    ),
              prefixIcon: IconButton(
                onPressed: () {},
                icon: Icon(Icons.lock_outline),
                color: Color(0xFF009b79), // Icône du bouton
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
                icon: Icon(
                  _showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                color: Color(0xFF009b79),
              ),
            ),
          ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }
}

