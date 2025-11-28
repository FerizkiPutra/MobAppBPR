import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DetailKunjunganPage extends StatelessWidget {
  final DocumentSnapshot doc;
  const DetailKunjunganPage({super.key, required this.doc});

  // Format Rupiah
  String rupiah(dynamic number) {
    if (number == null || number == 0) return "Rp 0";
    final num = int.tryParse(number.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(num);
  }

  Future<void> _generatePdf(BuildContext context) async {
    try {
      final snapshot = doc.data();
      if (snapshot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data tidak ditemukan")),
        );
        return;
      }
      final data = snapshot as Map<String, dynamic>;

      final pdf = pw.Document();

      // Load Logo BPR
      Uint8List? logoBytes;
      try {
        final logoData = await rootBundle.load('img/Bpr.png');
        logoBytes = logoData.buffer.asUint8List();
      } catch (e) {
        debugPrint("Logo tidak ditemukan: $e");
      }

      // Load Foto Kunjungan (maks 6)
      List<Uint8List> fotoBytes = [];
      final fotoUrls = (data['fotoUrls'] as List<dynamic>?) ?? [];
      for (String url in fotoUrls.take(6)) {
        try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            fotoBytes.add(response.bodyBytes);
          }
        } catch (e) {
          debugPrint("Gagal load foto: $e");
        }
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(40, 60, 40, 80),
          header: (_) => pw.Column(
            children: [
            pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [logoBytes != null? pw.Image(pw.MemoryImage(logoBytes),
            width: 300,
            height: 100,
            fit: pw.BoxFit.contain,): pw.Container(width: 180, height: 100, color: PdfColors.grey300),
            ]
            ),
            pw.SizedBox(height: 5),
            pw.SizedBox(height: 10),
            ],
            ),

          footer: (context) => pw.Container(
            alignment: pw.Alignment.center, padding: const pw.EdgeInsets.only(top: 10),
            child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
            pw.Text(
            "Jl. Veteran RT 20 RW 02, Kel. Ngrowo, Bojonegoro Telp. 0353-883956",
            style: const pw.TextStyle(fontSize: 9),
            ),pw.Text(
            "E-mail: bpr_daerah_bjn@yahoo.co.id | Website: https://bankdaerahbojonegoro.com",
            style: const pw.TextStyle(fontSize: 9),
            ),
            pw.SizedBox(height: 8),
            ],
            ),
            ),
          build: (_) => [
            // JUDUL UTAMA
            pw.Center(
              child: pw.Text(
                "LEMBAR KUNJUNGAN NASABAH",
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 30),

            // I. IDENTITAS NASABAH
            pw.Text("I. IDENTITAS NASABAH", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            _buildRow("a. Nomor Rekening", data['nomorRekening']?.toString() ?? '-'),
            _buildRow("b. Nama Nasabah", data['nama']?.toString() ?? '-'),
            _buildRow("c. Alamat", data['alamat']?.toString() ?? '-', maxLines: 3),
            pw.SizedBox(height: 20),

            // II. DATA PINJAMAN
            pw.Text("II. DATA PINJAMAN", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            _buildRow("a. Plafon Awal", rupiah(data['plafonAwal'] ?? 0)),
            _buildRow("b. Kolektibilitas", data['kolektibilitas']?.toString() ?? '5'),
            pw.SizedBox(height: 12),

            // Tabel Baki Debet & Tunggakan
            pw.Table(
              border: pw.TableBorder.all(width: 1),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(4),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text("Keterangan", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text("Jumlah", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                pw.TableRow(children: [pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text("Baki Debet")), pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text(rupiah(data['bakiDebet'] ?? 0)))]),
                pw.TableRow(children: [pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text("Tunggakan Pokok")), pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text(rupiah(data['tunggakanPokok'] ?? 0)))]),
                pw.TableRow(children: [pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text("Tunggakan Bunga")), pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text(rupiah(data['tunggakanBunga'] ?? 0)))]),
              ],
            ),
            pw.SizedBox(height: 0),

            // JAMINAN 
            if (data['jenisJaminan'] == 'SHM' &&
                (data['shmNo']?.toString().isNotEmpty == true ||
                 data['namaPemegangHak']?.toString().isNotEmpty == true ||
                 data['nilaiJaminan'] != null))
              
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1), 
                ),
                child: pw.Text(
                  "SHM No: ${data['shmNo'] ?? '-'} | Pemegang Hak: ${data['namaPemegangHak'] ?? '-'} | NIB: ${data['nomorIB'] ?? '-'} | Terletak: ${data['terletakDi'] ?? '-'} | Luas: ${data['luas'] ?? '-'} m² | Keterangan : ${data['keteranganAgunan'] ?? ''} | Nilai: ${rupiah(data['nilaiJaminan'] ?? 0)}",
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.normal),
                ),
              ),
            

            if (data['jenisJaminan'] == 'BPKB')
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1),
                ),
                child: pw.Text(
                  "Merk : ${data['merk'] ?? ''} | Type : ${data['type'] ?? ''} | Tahun : ${data['tahun'] ?? ''} | No BPKB : ${data['noBPKB'] ?? ''} | Nomor Polisi: ${data['noPolisi'] ?? '-'} | No Rangka : ${data['noRangka'] ?? ''} | No Mesin : ${data['noMesin'] ?? ''} | Warna : ${data['warna'] ?? ''} | Atas Nama: ${data['atasNamaBPKB'] ?? '-'} | Nilai Jaminan: ${rupiah(data['nilaiJaminanBPKB'] ?? 0 )} | Nilai Diperhitungkan : ${data['nilaiDiperhitungkan'] ?? ''} | Persen Pengikatan : ${data['persenPengikatan'] ?? ''} | Jenis Pengikatan : ${data['tahun'] ?? ''} | Keterangan : ${data['keteranganBPKB'] ?? ''} |",
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.normal),
                ),
              ),

            if (data['jenisJaminan'] == 'SK')
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1),
                ),
                child: pw.Text(
                  "SK No: ${data['noSK'] ?? '-'} | Atas Nama: ${data['atasNamaSK'] ?? '-'}",
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.normal),
                ),
              ),

            if (data['jenisJaminan'] == 'Tanpa Agunan')
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1),
                ),
                child: pw.Text(
                  "TANPA AGUNAN • ${data['keteranganTambahan']?.toString().isNotEmpty == true ? data['keteranganTambahan'] : 'Tidak ada keterangan tambahan'}",
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.normal),
                ),
              ),

            if (data['jenisJaminan'] == null || data['jenisJaminan'].toString().trim().isEmpty || data['jenisJaminan'] == 'Tidak Ada')
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                child: pw.Text("Tidak Ada Jaminan", style: pw.TextStyle(fontSize: 11,  fontStyle: pw.FontStyle.italic)),
              ),

            pw.SizedBox(height: 25),

            // III. RIWAYAT KUNJUNGAN
            pw.Text("III. RIWAYAT KUNJUNGAN", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              border: pw.TableBorder.all(width: 1),
              headerDecoration: const pw.BoxDecoration(),
              headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
              cellStyle: const pw.TextStyle(fontSize: 8.5),
              cellAlignment: pw.Alignment.center,
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5),
                1: const pw.FlexColumnWidth(1.2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(1.2),
                4: const pw.FlexColumnWidth(1.4),
                5: const pw.FlexColumnWidth(1.4),
                6: const pw.FlexColumnWidth(0.9),
                7: const pw.FlexColumnWidth(0.9),
              },
              headers: ["Ke-", "Tanggal", "Yang Ditemui", "Janji Bayar", "Nominal", "Pembayaran", "TTD", "Paraf"],
              data: (data['kunjungan'] as List<dynamic>? ?? []).asMap().entries.map((e) {
                final i = e.key + 1;
                final d = e.value as Map<String, dynamic>;
                return [
                  i.toString(),
                  d['tanggal'] ?? '',
                  d['berhasil'] ?? '',
                  d['janjiTanggal'] ?? '',
                  rupiah(d['janjiNominal'] ?? 0),
                  rupiah(d['pembayaran'] ?? 0),
                  d['ttd'] ?? '',
                  d['paraf'] ?? '',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 25),

            // IV. HASIL KUNJUNGAN
            pw.Text("IV. HASIL & KESIMPULAN KUNJUNGAN", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 1) ),
              child: pw.Text(
                data['hasilKunjungan']?.toString().isNotEmpty == true ? data['hasilKunjungan'] : "Belum ada keterangan kunjungan.",
                style: const pw.TextStyle(fontSize: 11),
              ),
            ),

            // FOTO KUNJUNGAN
            if (fotoBytes.isNotEmpty) ...[
              pw.SizedBox(height: 30),
              pw.Center(child: pw.Text("BUKTI FOTO KUNJUNGAN", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 15),
              pw.Wrap(
                spacing: 12,
                runSpacing: 12,
                children: fotoBytes.map((bytes) => pw.Container(
                  width: 180,
                  height: 180,
                  decoration: pw.BoxDecoration(border: pw.Border.all(width: 2, color: PdfColors.grey800)),
                  child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.cover),
                )).toList(),
              ),
            ],
          ],
        ),
      );

      // Simpan & Print
      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
        name: "Kunjungan_${data['nomorRekening'] ?? 'Unknown'}_${DateFormat('ddMMyyyy_HHmm').format(DateTime.now())}.pdf",
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error generate PDF: $e")));
    }
  }

  // Helper Row
  pw.Widget _buildRow(String label, String value, {int maxLines = 1}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 160, child: pw.Text(label, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold))),
          pw.Text(": ", style: const pw.TextStyle(fontSize: 11)),
          pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 11), maxLines: maxLines)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1D37),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Detail Kunjungan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 36),
            onPressed: () => _generatePdf(context),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 90, color: Colors.white70),
            SizedBox(height: 20),
            Text(
              "Klik ikon PDF di kanan atas\nuntuk cetak Lembar Kunjungan Resmi\nBPR Bank Daerah Bojonegoro",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

