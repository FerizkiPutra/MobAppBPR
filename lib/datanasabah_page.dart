// data_nasabah_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:visitbpr/lembarkunjungan_page.dart';

class DataNasabahPage extends StatefulWidget {
  const DataNasabahPage({super.key});

  @override
  State<DataNasabahPage> createState() => _DataNasabahPageState();
}

class _DataNasabahPageState extends State<DataNasabahPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1D37),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Daftar Nasabah",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // SEARCH BAR 
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Cari nama atau no. rekening...",
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
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

          // LIST NASABAH 
          Expanded(
            child: FirebaseAnimatedList(
              query: _dbRef.orderByChild("Nama"), 
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemBuilder: (context, snapshot, animation, index) {
                final json = snapshot.value as Map<Object?, Object?>?;
                if (json == null) return const SizedBox.shrink();

                final nama            = (json['Nama Nasabah']?.toString() ?? '').trim();
                final String noRek    = json['Rek Kredit'] != null ? (json['Rek Kredit'] as num).toStringAsFixed(0) : '';                
                final alamat          = (json['Alamat Nasabah']?.toString() ?? '').trim();
                final kol             = (json['Kol']?.toString() ?? '').trim();
                final plafond         = (json['Plafond']?.toString() ?? '').trim();
                final bakiDebet       = (json['Baki Debet']?.toString() ?? '').trim();
                final tPokok          = (json['TPokok']?.toString() ?? '').trim();
                final tBunga          = (json['TBunga']?.toString() ?? '').trim();
                final jaminan         = (json['Jaminan']?.toString() ?? '').trim();
                final keteranganTambah= (json['Keterangan Tambahan']?.toString() ?? '').trim();
                final merk            = (json['Merk']?.toString() ?? '').trim();
                final type            = (json['Type']?.toString() ?? '').trim();
                final tahun           = (json['Tahun']?.toString() ?? '').trim();
                final noBpkb          = (json['No BPKB']?.toString() ?? '').trim();
                final noPolisi        = (json['No Polisi']?.toString() ?? '').trim();
                final noRangka        = (json['No Rangka']?.toString() ?? '').trim();
                final noMesin         = (json['No Mesin']?.toString() ?? '').trim();
                final warna           = (json['Warna']?.toString() ?? '').trim();
                final atasNama        = (json['Atas Nama']?.toString() ?? '').trim();
                final nilaiJamin      = (json['Nilai Jaminan']?.toString() ?? '').trim();
                final nilaihitung     = (json['Nilai Yang Diperhitungkan']?.toString() ?? '').trim();
                final persenIkat      = (json['Persen Pengikatan']?.toString() ?? '').trim();
                final jenisIkat       = (json['Jenis Pengikatan']?.toString() ?? '').trim();
                final keterangann     = (json['Keterangan']?.toString() ?? '').trim();
                final shmNo           = (json['SHM NO']?.toString() ?? '').trim();
                final namaPemhak      = (json['Nama Pemegang Hak']?.toString() ?? '').trim();
                final nomorIB         = (json['Nomor Identifikasi Bidang Tanah (NIB)']?.toString() ?? '').trim();
                final terletakDi      = (json['Terletak Di']?.toString() ?? '').trim();
                final no              = (json['No']?.toString() ?? '').trim();
                final luasTanah       = (json['Luas']?.toString() ?? '').trim();
                final alamatt         = (json['Alamat']?.toString() ?? '').trim();
                final skCpns          = (json['SK CPNS IC NO']?.toString() ?? '').trim();
                final skPengatur      = (json['SK PENGATUR MUDA TINGKAT I (IIB) TANGGAL 1APRIL 2011 NO']?.toString() ?? '').trim();
                final taspenNo        = (json['TASPEN NO']?.toString() ?? '').trim();
                final model           = (json['Model']?.toString() ?? '').trim();
                final skAsli          = (json['SK ASLI NOMOR']?.toString() ?? '').trim();
                final nomor           = (json['Nomor']?.toString() ?? '').trim();
                final skSekdes        = (json['SK SEKDES DESA ALASGUNG KEC SUGIHWARA SK NOMOR']?.toString() ?? '').trim();
                final skKaur          = (json['SK KAUR UMUM DAN TATA USAHA DESA BABADSK NOMOR']?.toString() ?? '').trim();
                final skKepalaSeksi   = (json['SK KEPALA SEKSI PEMRINTAHAN DESA DROKILO KEC KEDUNGADEM NOMOR']?.toString() ?? '').trim();
                final skPerangkatdesa = (json['SK PERANGKAT DESA NOMOR']?.toString() ?? '').trim();

                // FILTER SEARCH
                if (_searchQuery.isNotEmpty) {
                  final lowerNama = nama.toLowerCase();
                  final lowerRek = noRek.toLowerCase();
                  if (!lowerNama.contains(_searchQuery) && !lowerRek.contains(_searchQuery)) {
                    return const SizedBox.shrink();
                  }
                }

                return SizeTransition(
                  sizeFactor: animation,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    margin: const EdgeInsets.only(bottom: 14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LembarKunjunganPage(
                              existingData: {
                                'nomorRekening': noRek,
                                'kolektibilitas': kol,
                                'nama': nama,
                                'alamat': alamat,
                                'plafonAwal': plafond,
                                'bakiDebet': json['Baki Debet']?.toString() ?? '',
                                'tunggakanPokok': json['TPokok']?.toString() ?? '',
                                'tunggakanBunga': json['TBunga']?.toString() ?? '',
                                'jaminan': json['Jaminan']?.toString() ?? '',
                                'keterangan': json['Keterangan']?.toString() ?? '',
                                "nilaiJaminan": json['']?.toString() ?? '',
                                "merk": json['Merk']?.toString() ?? '',
                                "type": json['Type']?.toString() ?? '',
                                "tahun": json['Tahun']?.toString() ?? '',
                                "noBPKB": json['No BPKB']?.toString() ?? '',
                                "noPolisi": json['No Polisi']?.toString() ?? '',
                                "noRangka": json['No Rangka']?.toString() ?? '',
                                "noMesin": json['No Mesin']?.toString() ?? '',
                                "warna": json['Warna']?.toString() ?? '',
                                "atasNamaBPKB": json['Atas Nama']?.toString() ?? '',
                                "nilaiJaminanBPKB": json['Nilai Jaminan']?.toString() ?? '',
                                "nilaiDiperhitungkan": json['Nilai Yang Diperhitungkan']?.toString() ?? '',
                                "persenPengikatan": json['Persen Pengikatan']?.toString() ?? '',
                                "jenisPengikatan": json['Jenis Pengikatan']?.toString() ?? '',
                                "keteranganBPKB": json['Keterangan']?.toString() ?? '',
                                "keteranganAgunan" : json['Keterangan']?.toString() ?? '',
                                "shmNo" : json['SHM NO']?.toString()??'-',
                                "namaPemegangHak": json['Nama Pemegang Hak']?.toString()??'-',
                                "nomorIB" : json['Nomor Identifikasi Bidang Tanah (NIB)']?.toString()??'-',
                                "terletakDi" : json['Terletak Di']?.toString()??'',
                                "no" : json['N0']?.toString()??'-',
                                "luas" : json['Luas']?.toString()??'-',
                                "namaSK": json['']?.toString() ?? '',
                                "noSK": json['']?.toString() ?? '',
                                "atasNamaSK": json['']?.toString() ?? '',
                                "tanggalSK": json['']?.toString() ?? '',                                
                                
                              },
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: const Color(0xFF0A1D37),
                              child: Text(
                                nama.isNotEmpty ? nama[0].toUpperCase() : "?",
                                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Text("No. Rek: $noRek", style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 14, fontWeight: FontWeight.w600)),
                                  Text("Kol: $kol  •  Plafond: $plafond", style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 0, 0, 0))),
                                  const SizedBox(height: 8),
                                  Text(alamat, style: const TextStyle(fontSize: 13, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green[700],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 22),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
