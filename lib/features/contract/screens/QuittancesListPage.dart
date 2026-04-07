import 'package:flutter/material.dart';

class QuittancesListPage extends StatelessWidget {
  final List<dynamic> quittances;

  QuittancesListPage({required this.quittances});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Quittances'),
        backgroundColor: Color(0xFF04348C),
      ),
      body: ListView.builder(
        itemCount: quittances.length,
        itemBuilder: (context, index) {
          final quittance = quittances[index];
          return ListTile(
            title: Text('Quittance ${quittance['id']}'),
            subtitle: Text('Montant: ${quittance['montant']} DT'),
          );
        },
      ),
    );
  }
}
