import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DetailKunjunganPage extends StatelessWidget {
  final DocumentSnapshot doc;
  const DetailKunjunganPage({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1D37),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Detail Kunjungan", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: () => _generatePDF(data),
            tooltip: "Download PDF",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul
              const Center(
                child: Text(
                  "LEMBAR KUNJUNGAN NASABAH",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(thickness: 1.5, color: Colors.black),
              const SizedBox(height: 16),

              // I. IDENTITAS NASABAH
              _section("I. IDENTITAS NASABAH"),
              _field("a. NOMOR REKENING", data['nomorRekening'] ?? '-'),
              _field("b. NAMA", data['nama'] ?? '-'),
              _field("c. ALAMAT", data['alamat'] ?? '-', maxLines: 2),
              const SizedBox(height: 16),

              // II. DATA PINJAMAN NASABAH
              _section("II. DATA PINJAMAN NASABAH"),
              _field("a. Besar Plafon Awal", _formatRupiah(data['plafonAwal'] ?? '0')),
              _field("b. Kolektibilitas", data['kolektibilitas'] ?? '5', suffix: ": 5"),
              const Divider(thickness: 1),
              _keteranganTable(data),
              const SizedBox(height: 16),

              // III. KUNJUNGAN
              _section("III. KUNJUNGAN"),
              _kunjunganTable(data['kunjungan'] ?? []),
              const SizedBox(height: 16),

              // IV. KETERANGAN KUNJUNGAN
              _section("IV. KETERANGAN KUNJUNGAN"),
              const Text(
                "Diisi tentang kronologi pinjaman, keadaan nasabah (usaha nasabah), kondisi agunan, sumber pendapatan, dan kesimpulan",
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                child: Text(data['keterangan'] ?? '-', style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(height: 8),
              _field("Hasil Kunjungan:", data['hasilKunjungan'] ?? '-', isBold: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _field(String label, String value, {String? suffix, int maxLines = 1, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label)),
          const Text(" : "),
          Expanded(
            child: Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.visible,
              style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
            ),
          ),
          if (suffix != null) Text(" $suffix", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _keteranganTable(Map<String, dynamic> data) {
    return Table(
      border: TableBorder.all(),
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Colors.grey),
          children: [
            _cell("Keterangan", color: Colors.white),
            _cell("Kunjungan", color: Colors.white),
          ],
        ),
        _row("Baki Debet", _formatRupiah(data['bakiDebet'] ?? '0')),
        _row("Sisa Tunggakan :", ""),
        _row(" *Pokok", _formatRupiah(data['tunggakanPokok'] ?? '0')),
        _row(" *Bunga", _formatRupiah(data['tunggakanBunga'] ?? '0')),
        TableRow(children: [
          const Padding(padding: EdgeInsets.all(8), child: Text("*SHM NO. :")),
          Padding(padding: const EdgeInsets.all(8), child: Text(data['shmNo'] ?? '-')),
        ]),
        const TableRow(children: [
          Padding(padding: EdgeInsets.all(8), child: Text("Nama Pemegang Hak : [ Nama ] Terletak Di : BOJONEGORO | Luas : 648 M2 | Keterangan :")),
          Padding(padding: EdgeInsets.all(8), child: Text("BUKTI KEPEMILIKAN LUAS 648, ATAS NAMA TERLETAK DI | Nilai Jaminan :")),
        ]),
      ],
    );
  }

  TableRow _row(String label, String value) {
    return TableRow(children: [
      Padding(padding: const EdgeInsets.all(8), child: Text(label)),
      Padding(padding: const EdgeInsets.all(8), child: Text(value)),
    ]);
  }

  Widget _cell(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Center(child: Text(text, style: TextStyle(color: color ?? Colors.black, fontWeight: FontWeight.bold))),
    );
  }

  Widget _kunjunganTable(List kunjunganList) {
    if (kunjunganList.isEmpty) {
      return const Text("Belum ada kunjungan.");
    }

    return Table(
      border: TableBorder.all(),
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Colors.grey),
          children: [
            _cell("Ke-"), _cell("Tanggal"), _cell("Yang Berhasil\nditemui"),
            _cell("Janji Bayar\nTanggal"), _cell("Nominal"), _cell("Pembayaran"),
            _cell("TTD\nNasabah"), _cell("Paraf\nPetugas"),
          ],
        ),
        ...kunjunganList.asMap().entries.map((e) {
          final i = e.key + 1;
          final d = e.value as Map<String, dynamic>;
          return TableRow(children: [
            _cell(i.toString()),
            _cell(d['tanggal'] ?? '-'),
            _cell(d['berhasil'] ?? '-'),
            _cell(d['janjiTanggal'] ?? '-'),
            _cell(_formatRupiah(d['janjiNominal'] ?? '0')),
            _cell(_formatRupiah(d['pembayaran'] ?? '0')),
            _cell(d['ttd'] ?? '-'),
            _cell(d['paraf'] ?? '-'),
          ]);
        }),
      ],
    );
  }

  String _formatRupiah(String value) {
    final num = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(num);
  }

  // GENERATE PDF
  Future<void> _generatePDF(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(child: pw.Text("LEMBAR KUNJUNGAN NASABAH", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 20),

              pw.Text("I. IDENTITAS NASABAH", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text("   a. NOMOR REKENING : ${data['nomorRekening'] ?? '-'}"),
              pw.Text("   b. NAMA           : ${data['nama'] ?? '-'}"),
              pw.Text("   c. ALAMAT         : ${data['alamat'] ?? '-'}"),
              pw.SizedBox(height: 16),

              pw.Text("II. DATA PINJAMAN NASABAH", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text("   a. Besar Plafon Awal : ${_formatRupiah(data['plafonAwal'] ?? '0')}"),
              pw.Text("   b. Kolektibilitas    : ${data['kolektibilitas'] ?? '5'}"),
              pw.SizedBox(height: 10),

              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [pw.Text("Keterangan"), pw.Text("Kunjungan")].map((t) => pw.Padding(padding: const pw.EdgeInsets.all(6), child: t)).toList(),
                  ),
                  pw.TableRow(children: [pw.Text("Baki Debet"), pw.Text(_formatRupiah(data['bakiDebet'] ?? '0'))]),
                  pw.TableRow(children: [pw.Text("Sisa Tunggakan :"), pw.Text("")]),
                  pw.TableRow(children: [pw.Text(" *Pokok"), pw.Text(_formatRupiah(data['tunggakanPokok'] ?? '0'))]),
                  pw.TableRow(children: [pw.Text(" *Bunga"), pw.Text(_formatRupiah(data['tunggakanBunga'] ?? '0'))]),
                  pw.TableRow(children: [pw.Text("*SHM NO. : ${data['shmNo'] ?? '-'}"), pw.Text("...")]),
                ],
              ),
              pw.SizedBox(height: 16),

              pw.Text("III. KUNJUNGAN", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              if ((data['kunjungan'] as List?)?.isNotEmpty == true)
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: ["Ke-", "Tanggal", "Berhasil", "Janji Tanggal", "Nominal", "Pembayaran", "TTD", "Paraf"]
                          .map((h) => pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(h, style: const pw.TextStyle(fontSize: 9)))).toList(),
                    ),
                    ...(data['kunjungan'] as List).asMap().entries.map((e) {
                      final i = e.key + 1;
                      final d = e.value;
                      return pw.TableRow(children: [
                        i.toString(), d['tanggal'] ?? '-', d['berhasil'] ?? '-', d['janjiTanggal'] ?? '-',
                        _formatRupiah(d['janjiNominal'] ?? '0'), _formatRupiah(d['pembayaran'] ?? '0'),
                        d['ttd'] ?? '-', d['paraf'] ?? '-',
                      ].map((c) => pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(c, style: const pw.TextStyle(fontSize: 9)))).toList());
                    }),
                  ],
                ),

              pw.SizedBox(height: 16),
              pw.Text("IV. KETERANGAN KUNJUNGAN", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(data['keterangan'] ?? '-', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 8),
              pw.Text("Hasil Kunjungan: ${data['hasilKunjungan'] ?? '-'}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    final fileName = "Kunjungan_${data['nomorRekening'] ?? 'Unknown'}_${DateTime.now().millisecondsSinceEpoch}.pdf";
    await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: fileName);
  }
}