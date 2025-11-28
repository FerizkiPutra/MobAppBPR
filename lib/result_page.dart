import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:visitbpr/detailkunjungan_page.dart';
import 'package:intl/intl.dart';
import 'package:visitbpr/lembarkunjungan_page.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String username = "Petugas";
  bool isLoading = true;
  String _searchQuery = ""; 

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        username = "Petugas";
        isLoading = false;
      });
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        username = doc.exists && doc.data()?['username'] != null
            ? doc.data()!['username']
            : user.email?.split('@').first ?? "Petugas";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        username = user.email?.split('@').first ?? "Petugas";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1D37),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Daftar Kunjungan Nasabah",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                // SEARCH BAR
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Cari nama, no. rekening, atau alamat...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                // LIST KUNJUNGAN
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('kunjungan')
                        .where('petugasUsername', isEqualTo: username)
                        .orderBy('waktuDibuat', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }

                      var docs = snapshot.data!.docs;

                      // FILTER BERDASARKAN SEARCH QUERY
                      if (_searchQuery.isNotEmpty) {
                        docs = docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final nama = (data['nama'] ?? '').toString().toLowerCase();
                          final noRek = (data['nomorRekening'] ?? '').toString().toLowerCase();
                          final alamat = (data['alamat'] ?? '').toString().toLowerCase();
                          return nama.contains(_searchQuery) ||
                              noRek.contains(_searchQuery) ||
                              alamat.contains(_searchQuery);
                        }).toList();
                      }

                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchQuery.isEmpty ? Icons.description_outlined : Icons.search_off,
                                size: 80,
                                color: Colors.white38,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? "Belum ada kunjungan\nKlik + untuk mulai"
                                    : "Tidak ditemukan\nCoba kata kunci lain",
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70, fontSize: 18),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          final docId = docs[index].id;
                          final nama = data['nama'] ?? 'Tanpa Nama';
                          final nomorRek = data['nomorRekening'] ?? '-';
                          final waktu = (data['waktuDibuat'] as Timestamp?)?.toDate();
                          final tanggal = waktu != null
                              ? DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(waktu)
                              : "Tanggal tidak tersedia";
                          final fotoUrls = (data['fotoUrls'] as List<dynamic>?) ?? [];
                          final fotoCount = fotoUrls.length;
                          final thumbnailUrl = fotoCount > 0 ? fotoUrls[0] as String : null;

                          return Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailKunjunganPage(doc: docs[index]),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Thumbnail
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: thumbnailUrl != null
                                          ? Image.network(
                                              thumbnailUrl,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: Colors.grey[300],
                                                  child: const Icon(Icons.camera_alt, color: Colors.grey),
                                                );
                                              },
                                            )
                                          : Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.person, size: 40, color: Colors.grey),
                                            ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Info Utama
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nama,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "No. Rek: $nomorRek",
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.access_time, size: 16, color: Colors.blue),
                                              const SizedBox(width: 4),
                                              Text(tanggal, style: const TextStyle(fontSize: 13)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.photo_camera, size: 16, color: Colors.orange),
                                              const SizedBox(width: 4),
                                              Text("$fotoCount foto", style: const TextStyle(fontSize: 13)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Tombol Edit
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue, size: 28),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => LembarKunjunganPage(
                                              docId: docId,
                                              existingData: data,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, size: 32, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LembarKunjunganPage()),
          );
        },
      ),
    );
  }
}
