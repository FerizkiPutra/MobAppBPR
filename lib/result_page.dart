import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:visitbpr/detailkunjungan_page.dart';

class ResultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Daftar Kunjungan")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("kunjungan").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map;
              return Card(
                child: ListTile(
                  leading: Icon(Icons.description),
                  title: Text(data['nama'] ?? 'Unknown'),
                  subtitle: Text("No. Rek: ${data['nomorRekening']}"),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    // KE DETAIL PAGE
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailKunjunganPage(doc: docs[index]),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}