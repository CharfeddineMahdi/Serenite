import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ApiService {

  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('BASE_URL manquant dans le fichier .env');
    }
    return url;
  }

  static String get baseUrlClient {
    final url = dotenv.env['BASE_URL_CLIENT'];
    if (url == null || url.isEmpty) {
      throw Exception('BASE_URL_CLIENT manquant dans le fichier .env');
    }
    return url;
  }


   Future<void> sendOtp(String phoneNumber) async {  
    final url = Uri.parse('$baseUrl/sendOtpF');
    try { 
      final response = await http.post(
        url,
        headers: { 
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'numTel': phoneNumber,                                                                                                                                                                                                                            
        },
      );
      if (response.statusCode == 200) {
        print('OTP envoyé avec succès');
      } else {
        throw Exception('Failed to send OTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi de l\'OTP : $e');
      throw new Exception("Échec de l'envoi de l'OTP. Veuillez réessayer plus tard.");
    }
  }

 
Future<void> resendOtp(String phoneNumber) async {
  final url = Uri.parse('$baseUrl/resendOtp');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'numTel': phoneNumber,
        },
      );

      if (response.statusCode == 200) {
        print('OTP envoyé avec succès');
      } else {
        throw Exception('Failed to send OTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi de l\'OTP : $e');
      throw Exception('Failed to send OTP: $e');
    }
  }


  Future<void> verifyOtp(String phoneNumber, String otp) async {
   final url = Uri.parse('$baseUrl/verifyOtp');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'numTel': phoneNumber,
          'otp': otp
        },
      );

    if (response.statusCode == 200) {
      print('OTP verified successfully');
    } else {
      throw Exception('Échec de la vérification OTP');
    } } catch (e) {
      print('Échec de la vérification OTP : $e');
      throw Exception( ' $e ');
    }
  }
 Future<void> completeRegistration(String phoneNumber, String username, String email, String prenom, String dateNaissance, String name, String cin, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/completeRegistration'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'numTel': phoneNumber,
        'username': username,
        'email': email,
        'prenom': prenom,
        'name': name,
        'dateNaissance': dateNaissance,
        'cin': cin,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      print('Registration completed successfully');
    } else {
      print('Failed to complete registration: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to complete registration');
    }
  } catch (e) {
    print('Exception during registration: $e');
    throw Exception('Failed to connect to server. Please try again later.');
  }
}

Future<Map<String, dynamic>> signin(String username, String password) async {
  final url = Uri.parse('$baseUrl/signin');
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);

      // Vérification du champ 'accessToken'
      if (responseBody.containsKey('accessToken') && responseBody['accessToken'] != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', responseBody['accessToken']); // Utilisation de 'accessToken'
        prefs.setString('user', jsonEncode(responseBody));
        prefs.setBool('isAuthentificated',responseBody['authentificated']);
        prefs.setBool('isEnabled',responseBody['enabled']);
        prefs.setString('dateNaissance',responseBody['dateNaissance']);
        prefs.setString('prenom',responseBody['prenom']);
        print('Authentication successful: $responseBody');
        print(responseBody['authentificated']);
        print(responseBody['dateNaissance']);
        print(responseBody['enabled']);
        return responseBody;
      } else {
        throw Exception('AccessToken not found in response');
      }
    } else {
      print('Failed to authenticate user: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to authenticate user');
    }
  } catch (e) {
    print('Exception during signin: $e');
    throw Exception('Failed to connect to server. Please try again later.');
  }
}

///////// add Contrat 
Future<String> getContratsClient(String numCNT) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final url = Uri.parse('$baseUrlClient/AddContratsClientV2?numCNT=$numCNT');
  
  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Traitez la réponse ici
      print('Contrats récupérés avec succès: ${response.body}');
      return 'Veuillez vérifier votre boîte mail.'; // Success message
    } else if (response.statusCode == 404) {
      return 'Le contrat demandé est introuvable. Veuillez vérifier le numéro du contrat.'; // 404 message
    } else {
      return 'Erreur lors de la récupération des contrats: ${response.statusCode}'; // General error message
    }
  } catch (e) {
    return 'Exception lors de la requête: $e'; // Exception message
  }
}


//listgContrat 
  Future<String> ListContratsClient() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token'); 

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrlClient/ContratsClientsEnabled'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load contracts');
    }
  }

//Suimulateur Versement périodique 

Future<List<dynamic>> simulateurVersementPeriodique({
  required String dateEffet,
  required String dateNaissance,
  required int durmois,
  required String fract,
  required double mntprimeInvesti,
  required double mntversemmentInitial,
  required double txIndexation,
  required double salaireImposable,
  required double txTmg,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final url = Uri.parse('$baseUrlClient/SimulateurVersementPeriodique');

  final body = jsonEncode({
    "date_Effet": dateEffet,
    "date_naissance": dateNaissance,
    "durmois": durmois,
    "fract": fract,
    "mntprime_investi": mntprimeInvesti,
    "mntversemment_intial": mntversemmentInitial,
    "_Tx_indexation": txIndexation,
    "salaire_imposable": salaireImposable,
    "_Tx_tmg": txTmg,
  });

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      List<dynamic> responseBody = jsonDecode(response.body);
       print(responseBody);
      return responseBody; // Return the raw JSON data
     
    } else {
      throw Exception('Failed to get simulation');
    }
  } catch (e) {
    print('Exception during simulation: $e');
    throw Exception('Failed to connect to server');
  }
}

//Simulateur PrimeUnique

Future<List<dynamic>> simulateurPrimeUnique({
  required String dateEffet,
  required String dateNaissance,
  required int durmois,
  required double mntprimeInvesti,
  required double salaireImposable,
  required double txTmg,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final url = Uri.parse('$baseUrlClient/SimulateurPrimeUnique');

  final body = jsonEncode({
    "date_Effet": dateEffet,
    "date_naissance": dateNaissance,
    "durmois": durmois,
    "mntprime_investi": mntprimeInvesti,
    "salaire_imposable": salaireImposable,
    "_Tx_tmg": txTmg,
  });

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      List<dynamic> responseBody = jsonDecode(response.body);
       print(responseBody);
      return responseBody; 
     
    } else {
      throw Exception('Failed to get simulation');
    }
  } catch (e) {
    print('Exception during simulation: $e');
    throw Exception('Failed to connect to server');
  }

  
}

//Simulateur Versement périodique 

Future<List<dynamic>> simulateurParObjectif({
  required String dateEffet,
  required String dateNaissance,
  required int durmois,
  required String fract,
  required double mnt_epargne_constitu,
  required double salaireImposable,
  required double txTmg,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final url = Uri.parse('$baseUrlClient/SimulateurParObjectif');

  final body = jsonEncode({
    "date_Effet": dateEffet,
    "date_naissance": dateNaissance,
    "durmois": durmois,
    "fract": fract,
    "mnt_epargne_constitu": mnt_epargne_constitu,
    "salaire_imposable": salaireImposable,
    "_Tx_tmg": txTmg,
  });

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      List<dynamic> responseBody = jsonDecode(response.body);
       print(responseBody);
      return responseBody; // Return the raw JSON data
     
    } else {
      throw Exception('Failed to get simulation');
    }
  } catch (e) {
    print('Exception during simulation: $e');
    throw Exception('Failed to connect to server');
  }
}
// Simuler Rente Prime Unique
Future<Map<String, dynamic>> simulateRentePrimeUnique({
  required String dateEffet,
  required String dateNaissance,
  required int durmois,
  required String fractRente,
  required double mntprimeInvesti,
  required double salaireImposable,
  required String typERente,
  required int dureeRenteParAN,
  required double txTmg,
  required double fraiServiceRente,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final url = Uri.parse('$baseUrlClient/RentePrimeUnique');

  final body = jsonEncode({
    "date_Effet": dateEffet,
    "date_naissance": dateNaissance,
    "durmois": durmois,
    "fract_rente": fractRente,
    "mntprime_investi": mntprimeInvesti,
    "salaire_imposable": salaireImposable,
    "typE_rente": typERente,
    "duree_rente_parAN": dureeRenteParAN,
    "_Tx_tmg": txTmg,
    "frai_Service_Rente": fraiServiceRente,
  });

  print('Corps de la requête : $body');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );
    print('Corps de la requêteBODY : ${jsonEncode(jsonDecode(body))}');

    if (response.statusCode == 200) {
  final responseBody = jsonDecode(response.body);
  print('Réponse du serveur : $responseBody');
  return responseBody;
} else {
  print('Erreur lors de la requête : ${response.statusCode}');
  print('Réponse du serveur : ${response.body}');
  final errorDetails = jsonDecode(response.body);
  throw Exception('Échec de la simulation Rente Prime Unique: ${errorDetails['error'] ?? 'Erreur inconnue'}');
}

  } catch (e) {
    print('Exception lors de la simulation: $e');
    throw Exception('Échec de la connexion au serveur');
  }
}

//Simulateur Rente VersementsPériodiques
Future<Map<String, dynamic>> simulateRenteVersementsPeriodiques({
  required String dateEffet,
  required String dateNaissance,
  required int durmois,
  required String fract,
  required String fractRente,
  required int dureeRenteParAN,
  required double mntprimeInvesti,
  required double mntversemmentIntial,
  required double txIndexation,
  required double salaireImposable,
  required String typERente,
  required double txTmg,
  required double fraiServiceRente,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final url = Uri.parse('$baseUrlClient/RenteVersementsPeriodiques');


print('Valeurs envoyées :');
print('date_Effet: $dateEffet');
print('date_naissance: $dateNaissance');
print('durmois: $durmois');
print('fract: $fract');
print('fract_rente: $fractRente');
print('mntprime_investi: $mntprimeInvesti');
print('mntversemment_intial: $mntversemmentIntial');
print('_Tx_indexation: $txIndexation');
print('salaire_imposable: $salaireImposable');
print('typE_rente: $typERente');
print('_Tx_tmg: $txTmg');
print('frai_Service_Rente: $fraiServiceRente');
  final body = jsonEncode({
    "date_Effet": dateEffet,
    "date_naissance": dateNaissance,
    "durmois": durmois,
    "fract": fract,
    "fract_rente": fractRente,
    "duree_rente_parAN": dureeRenteParAN,
    "mntprime_investi": mntprimeInvesti,
    "mntversemment_intial": mntversemmentIntial,
    "_Tx_indexation": txIndexation,
    "salaire_imposable": salaireImposable,
    "typE_rente": typERente,
    "_Tx_tmg": txTmg,
    "frai_Service_Rente": fraiServiceRente,
  });

  print('Corps de la requête : $body');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );
  print('Réponse du serveur : ${response.body}');
  final responseBody = jsonDecode(response.body);
  print('Réponse décodée : $responseBody');
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody;
    } else {
      print('Erreur lors de la requête : ${response.statusCode}');
      final errorDetails = jsonDecode(response.body);
      throw Exception('Échec de la simulation Rente Versements Périodiques: ${errorDetails['error'] ?? 'Erreur inconnue'}');
    }
  } catch (e) {
    print('Exception lors de la simulation: $e');
    throw Exception('Échec de la connexion au serveur');
  }
}


//Simulateur Rente Par objectif
Future<Map<String, dynamic>> simulateRenteParObjectif({
  required String dateEffet,
  required String dateNaissance,
  required int durmois,
  required String fract,
  required String fractRente,
  required int dureeRenteParAN,
  required double capital,
  required double salaireImposable,
  required String typERente,
  required double txTmg,
  required double fraiServiceRente,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final url = Uri.parse('$baseUrlClient/RenteObjectif');

  final body = jsonEncode({
    "date_Effet": dateEffet,
    "date_naissance": dateNaissance,
    "durmois": durmois,
    "fract": fract,
    "fract_rente": fractRente,
    "duree_rente_parAN": dureeRenteParAN,
    "capital": capital,
    "salaire_imposable": salaireImposable,
    "typE_rente": typERente,
    "_Tx_tmg": txTmg,
    "frai_Service_Rente": fraiServiceRente,
  });

  print('Corps de la requête : $body');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );
    print('Réponse du serveur : ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody;
    } else {
      print('Erreur lors de la requête : ${response.statusCode}');
      final errorDetails = jsonDecode(response.body);
      throw Exception('Échec de la simulation Rente Objectif: ${errorDetails['error'] ?? 'Erreur inconnue'}');
    }
  } catch (e) {
    print('Exception lors de la simulation: $e');
    throw Exception('Échec de la connexion au serveur');
  }
}
//Simulateur selon Capital 
Future<Map<String, dynamic>> simulateurSelonCapital({
  required String dateEffet,
  required String dateNaissance,
  required int durmois,
  required String fract,
  required double capital,
  required double salaireImposable,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final url = Uri.parse('$baseUrlClient/SimulateurSelonCapital');

  final body = jsonEncode({
    "date_Effet": dateEffet,
    "date_naissance": dateNaissance,
    "durmois": durmois,
    "fract": fract,
    "capital": capital,
    "salaire_imposable": salaireImposable,
  });

  print('Corps de la requête : $body');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );
    print('Réponse du serveur : ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody;
    } else {
      print('Erreur lors de la requête : ${response.statusCode}');
      final errorDetails = jsonDecode(response.body);
      throw Exception('Échec de la simulation selon capital: ${errorDetails['error'] ?? 'Erreur inconnue'}');
    }
  } catch (e) {
    print('Exception lors de la simulation: $e');
    throw Exception('Échec de la connexion au serveur');
  }
}

//Quittances par contrat 
  Future<List<dynamic>> fetchQuittances(String numCNT) async {
    final url = Uri.parse('$baseUrlClient/Quittances?numCNT=$numCNT');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // If you are using token-based auth
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to fetch quittances. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching quittances: $e');
      return [];
    }
  }


  Future<void> sendEmailAgence(String contractType) async {
  final url = Uri.parse('$baseUrlClient/sendEmailAgence?contractType=$contractType'); 
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  try {
    // Envoyer la requête GET
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('Email envoyé avec succès.');
      // Traite la réponse si nécessaire
    } else {
      throw Exception('Échec de l\'envoi de l\'email. Code d\'état : ${response.statusCode}');
    }
  } catch (e) {
    print('Erreur lors de l\'envoi de l\'email : $e');
  }
}

//sendMailAgenceRDV
Future<void> sendEmailAgenceRDV(String contractType, String formattedDateTime) async {
  final url = Uri.parse('$baseUrlClient/sendEmailAgenceRDV?contractType=$contractType&additionalInfo=$formattedDateTime'); 
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('Email envoyé avec succès.');
    } else {
      throw Exception('Échec de l\'envoi de l\'email. Code d\'état : ${response.statusCode}');
    }
  } catch (e) {
    print('Erreur lors de l\'envoi de l\'email : $e');
  }

}

 // Méthode de déconnexion
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken'); // Récupérer le token JWT

    if (token == null) {
      // Aucun token, rediriger vers la page de connexion directement
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Suppression des données de session si l'API renvoie une réponse correcte
      await prefs.remove('jwtToken');
      await prefs.remove('isAuthentificated');
      await prefs.remove('isEnabled');

      
      Navigator.pushReplacementNamed(context, '/login');

      Fluttertoast.showToast(
        msg: "Déconnexion réussie",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Color(0xFF04348C),
        textColor: Colors.white,
      );
    } else {
     
      Fluttertoast.showToast(
        msg: "Erreur lors de la déconnexion",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Color(0xFF009b79),
        textColor: Colors.white,
      );
    }
 
 }
Future<void> changePassword(String numTel, String otp, String newPassword) async {
  final String url = '$baseUrl/changePassword'; 

  // Construire l'URI avec les paramètres de requête
  final Uri uri = Uri.parse(url).replace(queryParameters: {
    'numTel': numTel,
    'otp': otp,
    'newPassword': newPassword,
  });

  try {
    final response = await http.post(uri);

    if (response.statusCode == 200) {
      // Réponse réussie
      print('Mot de passe changé avec succès: ${response.body}');
    } else {
      // Gérer les erreurs
      print('Échec du changement de mot de passe: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Erreur lors de la requête: $e');
  }
}

Future<Map<String, dynamic>> submitReclamation({
  required String subject,
  required String description,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    throw Exception("Token non trouvé. Veuillez vous reconnecter.");
  }

  // Construire l'URL avec les query params
  final url = Uri.parse("$baseUrlClient/createTicket").replace(
    queryParameters: {
      "subject": subject.trim(),
      "description": description.trim(),
    },  
  );

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {"statusCode": response.statusCode, "message": "Votre réclamation a été créée avec succès"};
    } else if (response.statusCode == 401) {
      throw Exception("Non autorisé. Veuillez vérifier vos identifiants.");
    } else if (response.statusCode == 500) {
      throw Exception("Erreur interne du serveur. Réessayez plus tard.");
    } else {
      throw Exception(
          "Erreur lors de l'envoi : ${response.statusCode} - ${response.body}");
    }
  } catch (error) {
    throw Exception("Erreur de connexion : $error");
  }
}









}

