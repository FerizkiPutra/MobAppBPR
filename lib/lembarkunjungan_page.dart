import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class LembarKunjunganPage extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? existingData;

  const LembarKunjunganPage({super.key, this.docId, this.existingData});

  @override
  State<LembarKunjunganPage> createState() => _LembarKunjunganPageState();
}

class _LembarKunjunganPageState extends State<LembarKunjunganPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  List<String> _existingFotoUrls = [];
  String? _jenisJaminan = "SHM";

  // Controller IDENTITAS & PINJAMAN
  final _nomorRekeningCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _plafonAwalCtrl = TextEditingController();
  final _kolektibilitasCtrl = TextEditingController();
  final _bakiDebetCtrl = TextEditingController();
  final _tunggakanPokokCtrl = TextEditingController();
  final _tunggakanBungaCtrl = TextEditingController();
  final _hasilKunjunganCtrl = TextEditingController();

  // SHM
  final _shmNoCtrl = TextEditingController();
  final _namaPemegangHakCtrl = TextEditingController();
  final _nomorIBCtrl = TextEditingController();
  final _terletakDiCtrl = TextEditingController();
  final _noCtrl = TextEditingController();
  final _luasCtrl = TextEditingController();
  final _keteranganAgunanCtrl = TextEditingController();
  final _nilaiJaminanCtrl = TextEditingController();

  // BPKB
  final _merkCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _tahunCtrl = TextEditingController();
  final _noBPKBCtrl = TextEditingController();
  final _noPolisiCtrl = TextEditingController();
  final _noRangkaCtrl = TextEditingController();
  final _noMesinCtrl = TextEditingController();
  final _warnaCtrl = TextEditingController();
  final _atasNamaBPKBCtrl = TextEditingController();
  final _nilaiJaminanBPKBCtrl = TextEditingController();
  final _nilaiDiperhitungkanCtrl = TextEditingController();
  final _persenPengikatanCtrl = TextEditingController();
  final _jenisPengikatanCtrl = TextEditingController();
  final _keteranganBPKBCtrl = TextEditingController();

  // SK
  final _namaSKCtrl = TextEditingController();
  final _noSkCtrl = TextEditingController();
  final _atasNamaSKCtrl = TextEditingController();
  final _tanggalSKCtrl = TextEditingController();

  // Tanpa Agunan 
  final _keteranganTambahan = TextEditingController();

  // Kunjungan
  final List<Map<String, String>> _kunjunganList = [];

  // Helper
  final _noBorder = const InputDecoration(border: InputBorder.none);

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      final d = widget.existingData!;
      _nomorRekeningCtrl.text = d['nomorRekening'] ?? '';
      _namaCtrl.text = d['nama'] ?? '';
      _alamatCtrl.text = d['alamat'] ?? '';
      _plafonAwalCtrl.text = d['plafonAwal'] ?? '';
      _kolektibilitasCtrl.text = d['kolektibilitas'] ?? '';
      _bakiDebetCtrl.text = d['bakiDebet'] ?? '';
      _tunggakanPokokCtrl.text = d['tunggakanPokok'] ?? '';
      _tunggakanBungaCtrl.text = d['tunggakanBunga'] ?? '';
      _hasilKunjunganCtrl.text = d['hasilKunjungan'] ?? '';

      // SHM
      _shmNoCtrl.text = d['shmNo'] ?? '';
      _namaPemegangHakCtrl.text = d['namaPemegangHak'] ?? '';
      _nomorIBCtrl.text = d['nomorIB'] ?? '';
      _terletakDiCtrl.text = d['terletakDi'] ?? '';
      _noCtrl.text = d['no'] ?? '';
      _luasCtrl.text = d['luas'] ?? '';
      _keteranganAgunanCtrl.text = d['keteranganAgunan'] ?? '';
      _nilaiJaminanCtrl.text = d['nilaiJaminan'] ?? '';

      // BPKB
      _merkCtrl.text = d['merk'] ?? '';
      _typeCtrl.text = d['type'] ?? '';
      _tahunCtrl.text = d['tahun'] ?? '';
      _noBPKBCtrl.text = d['noBPKB'] ?? '';
      _noPolisiCtrl.text = d['noPolisi'] ?? '';
      _noRangkaCtrl.text = d['noRangka'] ?? '';
      _noMesinCtrl.text = d['noMesin'] ?? '';
      _warnaCtrl.text = d['warna'] ?? '';
      _atasNamaBPKBCtrl.text = d['atasNamaBPKB'] ?? '';
      _nilaiJaminanBPKBCtrl.text = d['nilaiJaminanBPKB'] ?? '';
      _nilaiDiperhitungkanCtrl.text = d['nilaiDiperhitungkan'] ?? '';
      _persenPengikatanCtrl.text = d['persenPengikatan'] ?? '';
      _jenisPengikatanCtrl.text = d['jenisPengikatan'] ?? '';
      _keteranganBPKBCtrl.text = d['keteranganBPKB'] ?? '';

      // SK
      _namaSKCtrl.text = d['namaSK'] ?? '';
      _noSkCtrl.text = d['noSK'] ?? '';
      _atasNamaSKCtrl.text = d['atasNamaSK'] ?? '';
      _tanggalSKCtrl.text = d['tanggalSK'] ?? '';

      // Tanpa Agunan
      _keteranganTambahan.text = d['keteranganTambahan'] ?? '';

      // Jenis Jaminan
      if (d['jenisJaminan'] != null) _jenisJaminan = d['jenisJaminan'];

      // Foto & Kunjungan
      if (d['fotoUrls'] is List) _existingFotoUrls = List<String>.from(d['fotoUrls']);
      if (d['kunjungan'] is List) {
        _kunjunganList.addAll((d['kunjungan'] as List).map((e) => Map<String, String>.from(e)));
      }
    }
  }

  @override
  void dispose() {
    // Dispose semua controller
    _nomorRekeningCtrl.dispose();
    _namaCtrl.dispose();
    _alamatCtrl.dispose();
    _plafonAwalCtrl.dispose();
    _kolektibilitasCtrl.dispose();
    _bakiDebetCtrl.dispose();
    _tunggakanPokokCtrl.dispose();
    _tunggakanBungaCtrl.dispose();
    _hasilKunjunganCtrl.dispose();

    _shmNoCtrl.dispose();
    _namaPemegangHakCtrl.dispose();
    _nomorIBCtrl.dispose();
    _terletakDiCtrl.dispose();
    _noCtrl.dispose();
    _luasCtrl.dispose();
    _keteranganAgunanCtrl.dispose();
    _nilaiJaminanCtrl.dispose();

    _merkCtrl.dispose();
    _typeCtrl.dispose();
    _tahunCtrl.dispose();
    _noBPKBCtrl.dispose();
    _noPolisiCtrl.dispose();
    _noRangkaCtrl.dispose();
    _noMesinCtrl.dispose();
    _warnaCtrl.dispose();
    _atasNamaBPKBCtrl.dispose();
    _nilaiJaminanBPKBCtrl.dispose();
    _nilaiDiperhitungkanCtrl.dispose();
    _persenPengikatanCtrl.dispose();
    _jenisPengikatanCtrl.dispose();
    _keteranganBPKBCtrl.dispose();

    _namaSKCtrl.dispose();
    _noSkCtrl.dispose();
    _atasNamaSKCtrl.dispose();
    _tanggalSKCtrl.dispose();
    _keteranganTambahan.dispose();

    super.dispose();
  }

  TableRow _row(String label, Widget field) {
    return TableRow(children: [
      Padding(padding: const EdgeInsets.all(12), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
      Padding(padding: const EdgeInsets.all(8), child: field),
    ]);
  }

  Widget _buildTable(List<TableRow> rows) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
      children: rows,
    );
  }

  Future<void> _selectDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) ctrl.text = "${picked.day}/${picked.month}/${picked.year}";
  }

  Future<void> _pickImages() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Pilih Sumber Foto"),
        actions: [
          TextButton.icon(icon: const Icon(Icons.camera_alt), label: const Text("Kamera"), onPressed: () => Navigator.pop(context, ImageSource.camera)),
          TextButton.icon(icon: const Icon(Icons.photo_library), label: const Text("Galeri"), onPressed: () => Navigator.pop(context, ImageSource.gallery)),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (source == null) return;

    if (source == ImageSource.camera) {
      final file = await _picker.pickImage(source: source, imageQuality: 80);
      if (file != null) setState(() => _selectedImages.add(file));
    } else {
      final files = await _picker.pickMultiImage(imageQuality: 80);
      if (files.isNotEmpty) setState(() => _selectedImages.addAll(files));
    }
  }

  Future<List<String>> _uploadImages(String docId) async {
    List<String> urls = [];
    for (var img in _selectedImages) {
      final ref = FirebaseStorage.instance.ref('kunjungan_foto/$docId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(File(img.path));
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final username = (await FirebaseFirestore.instance.collection('users').doc(user.uid).get()).data()?['username'] ?? 'Petugas';

      final docRef = widget.docId != null
          ? FirebaseFirestore.instance.collection('kunjungan').doc(widget.docId)
          : FirebaseFirestore.instance.collection('kunjungan').doc();

      List<String> allUrls = List.from(_existingFotoUrls);
      if (_selectedImages.isNotEmpty) allUrls.addAll(await _uploadImages(docRef.id));

      await docRef.set({
        "nomorRekening": _nomorRekeningCtrl.text,
        "nama": _namaCtrl.text,
        "alamat": _alamatCtrl.text,
        "plafonAwal": _plafonAwalCtrl.text,
        "kolektibilitas": _kolektibilitasCtrl.text,
        "bakiDebet": _bakiDebetCtrl.text,
        "tunggakanPokok": _tunggakanPokokCtrl.text,
        "tunggakanBunga": _tunggakanBungaCtrl.text,
        "hasilKunjungan": _hasilKunjunganCtrl.text,
        "jenisJaminan": _jenisJaminan,
        "shmNo": _shmNoCtrl.text,
        "namaPemegangHak": _namaPemegangHakCtrl.text,
        "nomorIB": _nomorIBCtrl.text,
        "terletakDi": _terletakDiCtrl.text,
        "no": _noCtrl.text,
        "luas": _luasCtrl.text,
        "keteranganAgunan": _keteranganAgunanCtrl.text,
        "nilaiJaminan": _nilaiJaminanCtrl.text,
        "merk": _merkCtrl.text,
        "type": _typeCtrl.text,
        "tahun": _tahunCtrl.text,
        "noBPKB": _noBPKBCtrl.text,
        "noPolisi": _noPolisiCtrl.text,
        "noRangka": _noRangkaCtrl.text,
        "noMesin": _noMesinCtrl.text,
        "warna": _warnaCtrl.text,
        "atasNamaBPKB": _atasNamaBPKBCtrl.text,
        "nilaiJaminanBPKB": _nilaiJaminanBPKBCtrl.text,
        "nilaiDiperhitungkan": _nilaiDiperhitungkanCtrl.text,
        "persenPengikatan": _persenPengikatanCtrl.text,
        "jenisPengikatan": _jenisPengikatanCtrl.text,
        "keteranganBPKB": _keteranganBPKBCtrl.text,
        "namaSK": _namaSKCtrl.text,
        "noSK": _noSkCtrl.text,
        "atasNamaSK": _atasNamaSKCtrl.text,
        "tanggalSK": _tanggalSKCtrl.text,
        "keteranganTambahan": _keteranganTambahan.text,
        "kunjungan": _kunjunganList,
        "fotoUrls": allUrls,
        "petugasUsername": username,
        "waktuDibuat": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil disimpan!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _tambahKunjungan() async {
    final tanggal = TextEditingController();
    final berhasil = TextEditingController();
    final janjiTanggal = TextEditingController();
    final janjiNominal = TextEditingController();
    final pembayaran = TextEditingController();
    final ttd = TextEditingController();
    final paraf = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Kunjungan Ke-${_kunjunganList.length + 1}"),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: tanggal, decoration: const InputDecoration(labelText: "Tanggal (wajib)")),
            TextField(controller: berhasil, decoration: const InputDecoration(labelText: "Yang Ditemui")),
            TextField(controller: janjiTanggal, decoration: const InputDecoration(labelText: "Janji Tanggal Bayar")),
            TextField(controller: janjiNominal, decoration: const InputDecoration(labelText: "Nominal Janji"), keyboardType: TextInputType.number),
            TextField(controller: pembayaran, decoration: const InputDecoration(labelText: "Pembayaran Hari Ini"), keyboardType: TextInputType.number),
            TextField(controller: ttd, decoration: const InputDecoration(labelText: "TTD Nasabah")),
            TextField(controller: paraf, decoration: const InputDecoration(labelText: "Paraf Petugas")),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              if (tanggal.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tanggal wajib diisi!")));
                return;
              }
              setState(() {
                _kunjunganList.add({
                  'tanggal': tanggal.text,
                  'berhasil': berhasil.text,
                  'janjiTanggal': janjiTanggal.text,
                  'janjiNominal': janjiNominal.text,
                  'pembayaran': pembayaran.text,
                  'ttd': ttd.text,
                  'paraf': paraf.text,
                });
              });
              Navigator.pop(ctx);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalFoto = _existingFotoUrls.length + _selectedImages.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1D37),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.docId != null ? "Edit Kunjungan" : "Lembar Kunjungan Baru",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 16,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Center(child: Text("LEMBAR KUNJUNGAN NASABAH", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                const SizedBox(height: 30),

                // I. IDENTITAS NASABAH
                const Text("I. IDENTITAS NASABAH", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildRow("No. Rekening", _nomorRekeningCtrl),
                _buildRow("Nama", _namaCtrl),
                _buildRow("Alamat", _alamatCtrl, maxLines: 3),
                const SizedBox(height: 25),

                // II. DATA PINJAMAN
                const Text("II. DATA PINJAMAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildRow("Plafon Awal", _plafonAwalCtrl),
                _buildRow("Kolektibilitas", _kolektibilitasCtrl),
                const SizedBox(height: 12),
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  children: [
                    _row("Baki Debet", TextFormField(controller: _bakiDebetCtrl, decoration: _noBorder, keyboardType: TextInputType.number)),
                    _row("Tunggakan Pokok", TextFormField(controller: _tunggakanPokokCtrl, decoration: _noBorder, keyboardType: TextInputType.number)),
                    _row("Tunggakan Bunga", TextFormField(controller: _tunggakanBungaCtrl, decoration: _noBorder, keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 30),

                // JENIS JAMINAN
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField<String>(
                    value: _jenisJaminan,
                    decoration: InputDecoration(
                      labelText: "Jenis Jaminan",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    items: const [
                      DropdownMenuItem(value: "SHM", child: Text("SHM")),
                      DropdownMenuItem(value: "BPKB", child: Text("BPKB")),
                      DropdownMenuItem(value: "SK", child: Text("SK")),
                      DropdownMenuItem(value: "Tanpa Agunan", child: Text("Tanpa Agunan")),
                      DropdownMenuItem(value: "Tidak Ada", child: Text("Tidak Ada Jaminan")),
                    ],
                    onChanged: (v) => setState(() => _jenisJaminan = v),
                  ),
                ),
                const SizedBox(height: 20),

                // JAMINAN DINAMIS — 100% AMAN!
                if (_jenisJaminan == "SHM") _buildTable([
                  _row("SHM No.", TextFormField(controller: _shmNoCtrl, decoration: _noBorder)),
                  _row("Nama Pemegang Hak", TextFormField(controller: _namaPemegangHakCtrl, decoration: _noBorder)),
                  _row("Nomor IB (NIB)", TextFormField(controller: _nomorIBCtrl, decoration: _noBorder)),
                  _row("Terletak Di", TextFormField(controller: _terletakDiCtrl, decoration: _noBorder)),
                  _row("No", TextFormField(controller: _noCtrl, decoration: _noBorder)),
                  _row("Luas (m²)", TextFormField(controller: _luasCtrl, decoration: _noBorder, keyboardType: TextInputType.number)),
                  _row("Keterangan", TextFormField(controller: _keteranganAgunanCtrl, decoration: _noBorder, maxLines: 2)),
                  _row("Nilai Jaminan (Rp)", TextFormField(controller: _nilaiJaminanCtrl, decoration: _noBorder, keyboardType: TextInputType.number)),
                ]),

                if (_jenisJaminan == "BPKB") _buildTable([
                  _row("Merk", TextFormField(controller: _merkCtrl, decoration: _noBorder)),
                  _row("Type", TextFormField(controller: _typeCtrl, decoration: _noBorder)),
                  _row("Tahun", TextFormField(controller: _tahunCtrl, decoration: _noBorder)),
                  _row("No BPKB", TextFormField(controller: _noBPKBCtrl, decoration: _noBorder)),
                  _row("No Polisi", TextFormField(controller: _noPolisiCtrl, decoration: _noBorder)),
                  _row("No Rangka", TextFormField(controller: _noRangkaCtrl, decoration: _noBorder)),
                  _row("No Mesin", TextFormField(controller: _noMesinCtrl, decoration: _noBorder)),
                  _row("Warna", TextFormField(controller: _warnaCtrl, decoration: _noBorder)),
                  _row("Atas Nama", TextFormField(controller: _atasNamaBPKBCtrl, decoration: _noBorder)),
                  _row("Nilai Jaminan", TextFormField(controller: _nilaiJaminanBPKBCtrl, decoration: _noBorder, keyboardType: TextInputType.number)),
                  _row("Nilai Diperhitungkan", TextFormField(controller: _nilaiDiperhitungkanCtrl, decoration: _noBorder, keyboardType: TextInputType.number)),
                  _row("Persen Pengikatan", TextFormField(controller: _persenPengikatanCtrl, decoration: _noBorder)),
                  _row("Jenis Pengikatan", TextFormField(controller: _jenisPengikatanCtrl, decoration: _noBorder)),
                  _row("Keterangan", TextFormField(controller: _keteranganBPKBCtrl, decoration: _noBorder, maxLines: 2)),
                ]),

                if (_jenisJaminan == "SK") _buildTable([
                  _row("Nama SK", TextFormField(controller: _namaSKCtrl, decoration: _noBorder)),
                  _row("Nomor SK", TextFormField(controller: _noSkCtrl, decoration: _noBorder)),
                  _row("Atas Nama", TextFormField(controller: _atasNamaSKCtrl, decoration: _noBorder)),
                  _row("Tanggal SK", TextFormField(
                    controller: _tanggalSKCtrl,
                    decoration: _noBorder,
                    readOnly: true,
                    onTap: () => _selectDate(_tanggalSKCtrl),
                  )),
                ]),

                if (_jenisJaminan == "Tanpa Agunan") _buildTable([
                  _row("Keterangan Tambahan", TextFormField(
                    controller: _keteranganTambahan,
                    decoration: _noBorder,
                    maxLines: 6,
                  )),
                ]),

                if (_jenisJaminan == "Tidak Ada" || _jenisJaminan == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text("Tidak Ada Jaminan", style: TextStyle(fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic)),
                    ),
                  ),

                const SizedBox(height: 30),

                // III. RIWAYAT KUNJUNGAN
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text("III. RIWAYAT KUNJUNGAN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ElevatedButton.icon(onPressed: _tambahKunjungan, icon: const Icon(Icons.add), label: const Text("Tambah")),
                ]),
                const SizedBox(height: 12),
                _kunjunganList.isEmpty
                    ? const Text("Belum ada kunjungan", style: TextStyle(color: Colors.grey))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text("Ke-")),
                            DataColumn(label: Text("Tanggal")),
                            DataColumn(label: Text("Ditemui")),
                            DataColumn(label: Text("Janji Bayar")),
                            DataColumn(label: Text("Nominal")),
                          ],
                          rows: _kunjunganList.asMap().entries.map((e) {
                            final i = e.key + 1;
                            final d = e.value;
                            return DataRow(cells: [
                              DataCell(Text(i.toString())),
                              DataCell(Text(d['tanggal'] ?? '')),
                              DataCell(Text(d['berhasil'] ?? '')),
                              DataCell(Text(d['janjiTanggal'] ?? '')),
                              DataCell(Text(d['janjiNominal'] ?? '')),
                            ]);
                          }).toList(),
                        ),
                      ),

                const SizedBox(height: 30),

                // IV. HASIL KUNJUNGAN
                const Text("IV. HASIL & KESIMPULAN KUNJUNGAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _hasilKunjunganCtrl,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: "Tuliskan hasil kunjungan secara lengkap...",
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 30),

                // FOTO KUNJUNGAN
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text("Foto Kunjungan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.camera_alt),
                    label: Text("Tambah Foto ($totalFoto)"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[700]),
                  ),
                ]),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ..._existingFotoUrls.map((url) => Stack(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(url, width: 110, height: 110, fit: BoxFit.cover)),
                        Positioned(top: 4, right: 4, child: GestureDetector(
                          onTap: () => setState(() => _existingFotoUrls.remove(url)),
                          child: const CircleAvatar(radius: 14, backgroundColor: Colors.red, child: Icon(Icons.close, size: 18, color: Colors.white)),
                        )),
                      ],
                    )),
                    ..._selectedImages.map((file) => Stack(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(file.path), width: 110, height: 110, fit: BoxFit.cover)),
                        Positioned(top: 4, right: 4, child: GestureDetector(
                          onTap: () => setState(() => _selectedImages.remove(file)),
                          child: const CircleAvatar(radius: 14, backgroundColor: Colors.red, child: Icon(Icons.close, size: 18, color: Colors.white)),
                        )),
                      ],
                    )),
                  ],
                ),
                if (totalFoto == 0)
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
                    child: const Center(child: Text("Belum ada foto kunjungan", style: TextStyle(color: Colors.grey))),
                  ),

                const SizedBox(height: 40),

                // TOMBOL SIMPAN
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _simpan,
                    icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save),
                    label: Text(_isLoading ? "Menyimpan..." : "SIMPAN DATA"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text("$label :", style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
            child: TextFormField(
              controller: ctrl,
              maxLines: maxLines,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
            ),
          ),
        ],
      ),
    );
  }
}
