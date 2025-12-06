import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class InventarisFormPage extends StatefulWidget {
  final Map<String, dynamic>? inventaris;

  const InventarisFormPage({super.key, this.inventaris});

  @override
  State<InventarisFormPage> createState() => _InventarisFormPageState();
}

class _InventarisFormPageState extends State<InventarisFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _tanggalMasukController = TextEditingController();
  final _tanggalKedaluwarsaController = TextEditingController();

  bool _isLoading = false;
  bool get _isEdit => widget.inventaris != null;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _namaController.text = widget.inventaris!['nama'];
      _hargaController.text = widget.inventaris!['harga'].toString();
      _jumlahController.text = widget.inventaris!['jumlah'].toString();
      _tanggalMasukController.text = widget.inventaris!['tanggal_masuk'];
      _tanggalKedaluwarsaController.text =
          widget.inventaris!['tanggal_kedaluwarsa'];
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _jumlahController.dispose();
    _tanggalMasukController.dispose();
    _tanggalKedaluwarsaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.green[800]!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = _dateFormat.format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = _isEdit
        ? await ApiService.updateInventaris(
            id: widget.inventaris!['id'] is int
                ? widget.inventaris!['id']
                : int.parse(widget.inventaris!['id'].toString()),
            nama: _namaController.text,
            harga: int.parse(_hargaController.text),
            jumlah: int.parse(_jumlahController.text),
            tanggalMasuk: _tanggalMasukController.text,
            tanggalKedaluwarsa: _tanggalKedaluwarsaController.text,
          )
        : await ApiService.createInventaris(
            nama: _namaController.text,
            harga: int.parse(_hargaController.text),
            jumlah: int.parse(_jumlahController.text),
            tanggalMasuk: _tanggalMasukController.text,
            tanggalKedaluwarsa: _tanggalKedaluwarsaController.text,
          );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Berhasil'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      String errorMessage =
          result['message']?.toString() ?? 'Terjadi kesalahan';
      if (result['errors'] != null) {
        final errors = result['errors'] as Map<String, dynamic>;
        errorMessage = errors.values.join('\n');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text(
          _isEdit
              ? 'Edit Inventaris Renggomart'
              : 'Tambah Inventaris Renggomart',
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Barang',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Barang',
                          prefixIcon: Icon(Icons.shopping_bag),
                          border: OutlineInputBorder(),
                          hintText: 'Contoh: Beras Premium',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama barang tidak boleh kosong';
                          }
                          if (value.length < 3) {
                            return 'Nama barang minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _hargaController,
                        decoration: const InputDecoration(
                          labelText: 'Harga (Rp)',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                          hintText: 'Contoh: 85000',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harga tidak boleh kosong';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Harga harus berupa angka';
                          }
                          if (int.parse(value) <= 0) {
                            return 'Harga harus lebih dari 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _jumlahController,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah (pcs)',
                          prefixIcon: Icon(Icons.inventory),
                          border: OutlineInputBorder(),
                          hintText: 'Contoh: 50',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah tidak boleh kosong';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Jumlah harus berupa angka';
                          }
                          if (int.parse(value) <= 0) {
                            return 'Jumlah harus lebih dari 0';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tanggalMasukController,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Masuk',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                          hintText: 'Pilih tanggal',
                        ),
                        readOnly: true,
                        onTap: () =>
                            _selectDate(context, _tanggalMasukController),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tanggal masuk tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tanggalKedaluwarsaController,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Kedaluwarsa',
                          prefixIcon: Icon(Icons.warning),
                          border: OutlineInputBorder(),
                          hintText: 'Pilih tanggal',
                        ),
                        readOnly: true,
                        onTap: () =>
                            _selectDate(context, _tanggalKedaluwarsaController),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tanggal kedaluwarsa tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isEdit ? 'UPDATE' : 'SIMPAN',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
