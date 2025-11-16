import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class LembarKunjunganPage extends StatefulWidget {
  const LembarKunjunganPage({super.key});

  @override
  State<LembarKunjunganPage> createState() => _LembarKunjunganPageState();
}

class _LembarKunjunganPageState extends State<LembarKunjunganPage> {
  // === CONTROLLER ===
  final _nomorRekeningCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _plafonAwalCtrl = TextEditingController();
  final _kolektibilitasCtrl = TextEditingController(text: "5");
  final _bakiDebetCtrl = TextEditingController(text: "0");
  final _tunggakanPokokCtrl = TextEditingController(text: "0");
  final _tunggakanBungaCtrl = TextEditingController(text: "0");
  final _shmNoCtrl = TextEditingController();
  final _keteranganCtrl = TextEditingController();
  final _hasilKunjunganCtrl = TextEditingController();

  // Tabel Kunjungan
  final List<Map<String, String>> _kunjunganList = [];

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nomorRekeningCtrl.dispose();
    _namaCtrl.dispose();
    _alamatCtrl.dispose();
    _plafonAwalCtrl.dispose();
    _kolektibilitasCtrl.dispose();
    _bakiDebetCtrl.dispose();
    _tunggakanPokokCtrl.dispose();
    _tunggakanBungaCtrl.dispose();
    _shmNoCtrl.dispose();
    _keteranganCtrl.dispose();
    _hasilKunjunganCtrl.dispose();
    super.dispose();
  }

  // === FUNGSI TAMBAH KUNJUNGAN ===
  void _tambahKunjungan() {
    final tanggalCtrl = TextEditingController();
    final berhasilCtrl = TextEditingController();
    final janjiTanggalCtrl = TextEditingController();
    final janjiNominalCtrl = TextEditingController();
    final pembayaranCtrl = TextEditingController();
    final ttdCtrl = TextEditingController();
    final parafCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tambah Kunjungan"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _field("Tanggal (dd/mm/yyyy)", tanggalCtrl),
              _field("Yang Berhasil Ditemui", berhasilCtrl),
              _field("Janji Bayar Tanggal", janjiTanggalCtrl),
              _field("Janji Bayar Nominal", janjiNominalCtrl),
              _field("Pembayaran", pembayaranCtrl),
              _field("TTD Nasabah", ttdCtrl),
              _field("Paraf Petugas", parafCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _kunjunganList.add({
                  "tanggal": tanggalCtrl.text,
                  "berhasil": berhasilCtrl.text,
                  "janjiTanggal": janjiTanggalCtrl.text,
                  "janjiNominal": janjiNominalCtrl.text,
                  "pembayaran": pembayaranCtrl.text,
                  "ttd": ttdCtrl.text,
                  "paraf": parafCtrl.text,
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

  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  // === SIMPAN KE FIRESTORE ===
  Future<void> _simpanKeFirestore() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection("kunjungan").add({
        "nomorRekening": _nomorRekeningCtrl.text.trim(),
        "nama": _namaCtrl.text.trim(),
        "alamat": _alamatCtrl.text.trim(),
        "plafonAwal": _plafonAwalCtrl.text.trim(),
        "kolektibilitas": _kolektibilitasCtrl.text.trim(),
        "bakiDebet": _bakiDebetCtrl.text.trim(),
        "tunggakanPokok": _tunggakanPokokCtrl.text.trim(),
        "tunggakanBunga": _tunggakanBungaCtrl.text.trim(),
        "shmNo": _shmNoCtrl.text.trim(),
        "kunjungan": _kunjunganList,
        "keterangan": _keteranganCtrl.text.trim(),
        "hasilKunjungan": _hasilKunjunganCtrl.text.trim(),
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lembar Kunjungan berhasil disimpan!"), backgroundColor: Colors.green),
      );

      // Reset form
      _formKey.currentState!.reset();
      setState(() => _kunjunganList.clear());
      _kolektibilitasCtrl.text = "5";
      _bakiDebetCtrl.text = "0";
      _tunggakanPokokCtrl.text = "0";
      _tunggakanBungaCtrl.text = "0";
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // === WIDGET BUILD ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1D37),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Lembar Kunjungan Nasabah", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "LEMBAR KUNJUNGAN NASABAH",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(thickness: 1.5),
                const SizedBox(height: 16),

                // I. IDENTITAS NASABAH
                _section("I. IDENTITAS NASABAH"),
                _inputField("a. NOMOR REKENING", _nomorRekeningCtrl),
                _inputField("b. NAMA", _namaCtrl),
                _inputField("c. ALAMAT", _alamatCtrl, maxLines: 2),
                const SizedBox(height: 16),

                // II. DATA PINJAMAN NASABAH
                _section("II. DATA PINJAMAN NASABAH"),
                _inputField("a. Besar Plafon Awal", _plafonAwalCtrl, hint: "Contoh: 30104188"),
                _inputField("b. Kolektibilitas", _kolektibilitasCtrl, readOnly: true, suffix: ": 5"),
                const Divider(thickness: 1),
                _keteranganTable(),
                const SizedBox(height: 16),

                // III. KUNJUNGAN
                _section("III. KUNJUNGAN"),
                _kunjunganTable(),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _tambahKunjungan,
                  icon: const Icon(Icons.add),
                  label: const Text("Tambah Kunjungan"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
                ),
                const SizedBox(height: 16),

                // IV. KETERANGAN KUNJUNGAN
                _section("IV. KETERANGAN KUNJUNGAN"),
                const Text(
                  "Diisi tentang kronologi pinjaman, keadaan nasabah (usaha nasabah), kondisi agunan, sumber pendapatan, dan kesimpulan",
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _keteranganCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Tuliskan keterangan di sini...",
                  ),
                  validator: (value) => value?.isEmpty == true ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 16),
                _inputField("Hasil Kunjungan:", _hasilKunjunganCtrl, isMultiline: true),

                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _simpanKeFirestore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("SIMPAN", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // === WIDGET HELPER (PINDAHKAN KE SINI) ===
  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, {String? hint, int maxLines = 1, bool readOnly = false, String? suffix, bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label)),
          const Text(" : "),
          Expanded(
            child: TextFormField(
              controller: ctrl,
              maxLines: isMultiline ? null : maxLines,
              readOnly: readOnly,
              decoration: InputDecoration(
                hintText: hint,
                border: const UnderlineInputBorder(),
                isDense: true,
              ),
              validator: (value) => value?.isEmpty == true ? "Wajib diisi" : null,
            ),
          ),
          if (suffix != null) Text(" $suffix", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _keteranganTable() {
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
        _row("Baki Debet", _bakiDebetCtrl),
        _row("Sisa Tunggakan :", null),
        _row(" *Pokok", _tunggakanPokokCtrl),
        _row(" *Bunga", _tunggakanBungaCtrl),
        TableRow(children: [
          const Padding(padding: EdgeInsets.all(8), child: Text("*SHM NO. :")),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _shmNoCtrl,
              decoration: const InputDecoration(border: InputBorder.none),
              validator: (value) => value?.isEmpty == true ? "Wajib diisi" : null,
            ),
          ),
        ]),
        const TableRow(children: [
          Padding(padding: EdgeInsets.all(8), child: Text("Nama Pemegang Hak : [ Nama ] Terletak Di : BOJONEGORO | Luas : 648 M2 | Keterangan :")),
          Padding(padding: EdgeInsets.all(8), child: Text("BUKTI KEPEMILIKAN LUAS 648, ATAS NAMA TERLETAK DI | Nilai Jaminan :")),
        ]),
      ],
    );
  }

  TableRow _row(String label, TextEditingController? ctrl) {
    return TableRow(children: [
      Padding(padding: const EdgeInsets.all(8), child: Text(label)),
      Padding(
        padding: const EdgeInsets.all(8),
        child: ctrl != null
            ? TextFormField(
                controller: ctrl,
                decoration: const InputDecoration(border: InputBorder.none),
                validator: (value) => value?.isEmpty == true ? "Wajib diisi" : null,
              )
            : const SizedBox(),
      ),
    ]);
  }

  Widget _cell(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Center(child: Text(text, style: TextStyle(color: color ?? Colors.black, fontWeight: FontWeight.bold))),
    );
  }

  Widget _kunjunganTable() {
    if (_kunjunganList.isEmpty) {
      return const Text("Belum ada kunjungan. Tekan tombol untuk menambah.");
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
        ..._kunjunganList.asMap().entries.map((e) {
          final i = e.key + 1;
          final d = e.value;
          return TableRow(children: [
            _cell(i.toString()),
            _cell(d['tanggal'] ?? ''),
            _cell(d['berhasil'] ?? ''),
            _cell(d['janjiTanggal'] ?? ''),
            _cell(d['janjiNominal'] ?? ''),
            _cell(d['pembayaran'] ?? ''),
            _cell(d['ttd'] ?? ''),
            _cell(d['paraf'] ?? ''),
          ]);
        }),
      ],
    );
  }
}