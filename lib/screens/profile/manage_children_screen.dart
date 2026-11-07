import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/balita.dart';
import '../../services/balita_service.dart';
import '../../theme/sg_theme.dart';

class ManageChildrenScreen extends StatefulWidget {
  const ManageChildrenScreen({super.key});

  @override
  State<ManageChildrenScreen> createState() => _ManageChildrenScreenState();
}

class _ManageChildrenScreenState extends State<ManageChildrenScreen> {
  final _service = BalitaService();
  List<Balita> _children = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final children = await _service.fetchChildren();
      if (!mounted) return;
      setState(() => _children = children);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openForm([Balita? child]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _ChildFormScreen(service: _service, child: child),
      ),
    );
    if (changed == true) _refresh();
  }

  Future<void> _delete(Balita child) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus data anak?'),
        content: Text(
          'Data ${child.nama} akan dihapus. Anak yang sudah memiliki riwayat pengukuran tidak dapat dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _service.deleteChild(child.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data anak berhasil dihapus.')),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: SG.background,
    appBar: AppBar(title: const Text('Kelola Anak')),
    floatingActionButton: FloatingActionButton.extended(
      backgroundColor: SG.primary,
      foregroundColor: Colors.white,
      onPressed: () => _openForm(),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Tambah Anak'),
    ),
    body: RefreshIndicator(
      onRefresh: _refresh,
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: SG.primary))
          : _error != null
          ? ListView(
              children: [
                const SizedBox(height: 90),
                const Icon(Icons.wifi_off_rounded, size: 44, color: SG.muted),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(_error!, textAlign: TextAlign.center),
                ),
                TextButton(onPressed: _refresh, child: const Text('Coba Lagi')),
              ],
            )
          : _children.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 90),
                Icon(Icons.child_care_rounded, size: 58, color: SG.primary),
                SizedBox(height: 12),
                Text(
                  'Belum ada data anak',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  'Tekan Tambah Anak untuk mendaftarkan anak.',
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _children.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final child = _children[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: SG.pale,
                              child: Icon(
                                Icons.child_care_rounded,
                                color: SG.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    child.nama,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    child.id,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: SG.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Jenis kelamin: ${child.jenisKelamin}'),
                        Text('Tanggal lahir: ${child.tanggalLahir}'),
                        Text('Riwayat pengukuran: ${child.jumlahPengukuran}'),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _openForm(child),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Ubah'),
                            ),
                            TextButton.icon(
                              onPressed: () => _delete(child),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Hapus'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    ),
  );
}

class _ChildFormScreen extends StatefulWidget {
  final BalitaService service;
  final Balita? child;
  const _ChildFormScreen({required this.service, this.child});

  @override
  State<_ChildFormScreen> createState() => _ChildFormScreenState();
}

class _ChildFormScreenState extends State<_ChildFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _nik;
  DateTime? _birthDate;
  String? _gender;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.child?.nama ?? '');
    _nik = TextEditingController(text: widget.child?.nik ?? '');
    _gender = widget.child?.jenisKelamin;
    _birthDate = widget.child == null
        ? null
        : DateTime.tryParse(widget.child!.tanggalLahir);
  }

  @override
  void dispose() {
    _name.dispose();
    _nik.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal lahir wajib diisi.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.service.saveChild(
        id: widget.child?.id,
        nama: _name.text,
        nik: _nik.text,
        tanggalLahir: _formatDate(_birthDate!),
        jenisKelamin: _gender!,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.child == null ? 'Tambah Anak' : 'Ubah Data Anak'),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _name,
            maxLength: 60,
            decoration: const InputDecoration(
              labelText: 'Nama Anak',
              border: OutlineInputBorder(),
            ),
            validator: (value) => (value?.trim().length ?? 0) < 3
                ? 'Nama minimal 3 karakter.'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nik,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
            decoration: const InputDecoration(
              labelText: 'NIK (opsional)',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value != null && value.isNotEmpty && value.length != 16
                ? 'NIK harus 16 digit.'
                : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: const InputDecoration(
              labelText: 'Jenis Kelamin',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
              DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
            ],
            onChanged: (value) => setState(() => _gender = value),
            validator: (value) => value == null ? 'Pilih jenis kelamin.' : null,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              _birthDate == null
                  ? 'Pilih Tanggal Lahir'
                  : 'Tanggal Lahir: ${_formatDate(_birthDate!)}',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan Data Anak'),
            ),
          ),
        ],
      ),
    ),
  );
}
