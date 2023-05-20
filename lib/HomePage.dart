import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'MyApp.dart';
import 'Season.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var season = appState.season;
    String uid = appState.uid;
    Size screenSize = MediaQuery.of(context).size;
    final Stream<QuerySnapshot> _shoesStreamNC = FirebaseFirestore.instance
        .collection('shoe')
        .where('IdUser', isEqualTo: uid)
        .where('NeedCleaning', isEqualTo: true)
        .snapshots();
    final Stream<QuerySnapshot> _shoesStreamOutfit = FirebaseFirestore.instance
        .collection('shoe')
        .where('IdUser', isEqualTo: uid)
        .where('Seasons', arrayContains: season)
        .orderBy('DateLastWorn')
        .snapshots();
    final Stream<QuerySnapshot> _outfitStream =
        FirebaseFirestore.instance.collection('outfit').snapshots();
    return SingleChildScrollView(
      child: Center(
          child: Column(children: [
        Season(season: season),
        const Text("Try this pair of shoes with this outfit"),
        Row(children: [
          StreamBuilder<QuerySnapshot>(
            stream: _shoesStreamOutfit,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
                return Text('An error occurred');
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text('No matching shoes');
              } else {
                final oldestShoe = snapshot.data!.docs.first;
                Map<String, dynamic> oldestShoeData =
                    oldestShoe.data() as Map<String, dynamic>;

                return Expanded(
                  child: SizedBox(
                    width: screenSize.width * 0.5,
                    height: screenSize.height *
                        0.25, // Ajoutez la hauteur souhaitée pour l'image
                    child: ClipRRect(
                      child: Image.network(
                        oldestShoeData['PhotoURL'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _outfitStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
                return Text('An error occurred');
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text('No matching outfits');
              } else {
                final outfit = snapshot.data!.docs.first;
                Map<String, dynamic> outfitData =
                    outfit.data() as Map<String, dynamic>;

                return Expanded(
                  child: SizedBox(
                    width: screenSize.width * 0.5,
                    height: screenSize.height *
                        0.25, // Ajoutez la hauteur souhaitée pour l'image
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        outfitData['PhotoURL'],
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ]),
        SizedBox(
          height: screenSize.height * 0.03,
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Other Recommendations'),
        ),
        SizedBox(
          height: screenSize.height * 0.03,
        ),
        StreamBuilder<QuerySnapshot>(
          stream: _shoesStreamNC,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }

            return Column(
              children: [
                Text('Need Cleaning:'),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2, // Number of columns
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          appState.changeActualShoe(document.id);
                          appState.changePhotoUrlShoe(data['PhotoURL']);
                          appState.changeNameShoe(data['Name']);
                          appState.changeBrandShoe(data['Brand']);
                          appState.changeColorsShoe(data['Colors']);
                          appState.changeWaterproofShoe(data['Waterproof']);
                          appState.changeSeasonShoe(data['Seasons']);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                              255, 4, 104, 130), // Set the background color
                          foregroundColor: Colors.grey, // Set the text color
                          //padding: const EdgeInsets.all(1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15), // Set the border radius
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.network(
                                data['PhotoURL'],
                              ),
                            ),
                            Text(data['Name'],
                                style: TextStyle(
                                    color: Colors.grey[300]!, fontSize: 20)),
                            Text(data['Brand'],
                                style: TextStyle(
                                    color: Colors.grey[300]!, fontSize: 20)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ])),
    );
  }
}
