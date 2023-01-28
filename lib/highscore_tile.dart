import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HighScoreTile extends StatelessWidget {
  final String documentid;
  const HighScoreTile({
    super.key,
    required this.documentid,
  });

  @override
  Widget build(BuildContext context) {
    //get collection og high scores
    CollectionReference highscores = FirebaseFirestore.instance.collection('highscores');
    return FutureBuilder<DocumentSnapshot>(
      future: highscores.doc(documentid).get(),
      builder: (context, snapshot) {
        // if (snapshot.connectionState == ConnectionState.done) {
        //   Map<String, dynamic> data =
        //       snapshot.data!.data() as Map<String, dynamic>;

        //   return Row(
        //     children: [
        //       Text(data['scores '].toString()),
        //       const SizedBox(width: 10,),
        //       Text(data['name']),
        //     ],
        //   );
        // } else {
          return const Text('loading...');
        // }
      },
    );
  }
}
