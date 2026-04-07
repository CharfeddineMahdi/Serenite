import 'package:ami_mobile/features/simulateurs/screens/SimulateursPage.dart';
import 'package:flutter/material.dart';
import 'package:ami_mobile/features/simulateurs/screens/SimulateurPage.dart'; 
import 'package:ami_mobile/features/simulateurs/screens/RentePage.dart'; 

class SimulateurPage extends StatefulWidget {
  @override
  _SimulateurPageState createState() => _SimulateurPageState();
}

class _SimulateurPageState extends State<SimulateurPage> {
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Simulateur',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'GilmerRegular',
          ),
        ),
        backgroundColor: Color(0xFF04348C),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/greywithOpacity.png'),
            repeat: ImageRepeat.repeat, 
            scale: 3.5, 
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 170.0,
                  height: 250.0,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  child: _buildCard(
                    index: 0,
                    title: 'Constituer une épargne ?',
                    page: SimulateursPage(),
                  ),
                ),
                Container(
                  width: 170.0,
                  height: 250.0,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  child: _buildCard(
                    index: 1,
                    title: 'Simuler une Rente ?',
                    page: RentePage(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required int index, required String title, required Widget page}) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? Color.fromARGB(69, 0, 155, 121) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(30),
            bottomLeft: Radius.circular(60),
            bottomRight: Radius.circular(0),
          ),
          border: Border.all(color: Color(0xFF009b79), width: 2),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'GilmerBold',
                color: isSelected ? Color(0xFF009b79) : Color(0xFF04348C),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
