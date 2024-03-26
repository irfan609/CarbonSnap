import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.green),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'CarbonSnap',
                style: GoogleFonts.pacifico(
                  fontSize: 50,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Text(
                'CarbonSnap is a project of the Malaysian Green Technology and Climate Change Corporation, committed to fostering environmental consciousness and promoting sustainable living. Our team of experts and passionate individuals work tirelessly to provide you with a tool that not only tracks your carbon footprint but also empowers you to make a positive difference. Join us in the journey towards a greener, more sustainable future.\n\n Download CarbonSnap today and take the first step towards reducing your carbon footprint, one choice at a time.',
                textAlign: TextAlign.justify,
                style:
                    GoogleFonts.rancho(fontSize: 25, color: Colors.blue[900]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                'We aim to target',
                style: GoogleFonts.rancho(fontSize: 30),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Image.network(
                    'https://www.teamstainless.org/media/jgmi3zww/03-good-health-and-well-being.jpg',
                    width: 350,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Image.network(
                    'https://www.teamstainless.org/media/zyjb1hyl/banners6.jpg',
                    width: 350,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Image.network(
                    'https://www.teamstainless.org/media/ptjinr4i/banners8.jpg',
                    width: 350,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: 10,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: const BorderRadius.all(Radius.circular(15))),
              child: Text(
                'Lets Snap, Track, and Change Together!',
                textAlign: TextAlign.center,
                style: GoogleFonts.rancho(fontSize: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
