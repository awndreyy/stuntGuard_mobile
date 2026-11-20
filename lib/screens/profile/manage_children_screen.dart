import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/balita.dart';
import '../../services/balita_service.dart';

class ManageChildrenScreen extends StatefulWidget {
  const ManageChildrenScreen({super.key});

  @override
  State<ManageChildrenScreen> createState() => _ManageChildrenScreenState();
}

class _ManageChildrenScreenState extends State<ManageChildrenScreen> {
  final _service = BalitaService();
  final _searchController = TextEditingController();

  List<Balita> _children = [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  String _selectedAgeFilter = 'Semua Usia';

  static const List<String> _ageFilters = [
    'Semua Usia',
    '0–11 bulan',
    '12–23 bulan',
    '24+ bulan',
  ];

  // Palet warna sesuai desain StuntGuard
  static const Color _primary = Color(0xFFA8224A);
  static const Color _surface = Color(0xFFFFFDF9);
  static const Color _surfaceContainer = Color(0xFFFFFFFF);
  static const Color _onSurface = Color(0xFF1F1A1C);
  static const Color _onSurfaceVariant = Color(0xFF6B5E62);
  static const Color _outlineVariant = Color(0xFFE6DFDC);

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  int _calculateAgeInMonths(String birthDateStr) {
    final dob = DateTime.tryParse(birthDateStr);
    if (dob == null) return 0;
    final now = DateTime.now();
    int months = (now.year - dob.year) * 12 + (now.month - dob.month);
    if (now.day < dob.day) months -= 1;
    return months < 0 ? 0 : months;
  }

  List<Balita> get _filteredChildren {
    return _children.where((child) {
      final matchesSearch = _searchQuery.trim().isEmpty ||
          child.nama.toLowerCase().contains(_searchQuery.trim().toLowerCase());
      if (!matchesSearch) return false;

      if (_selectedAgeFilter == 'Semua Usia') return true;
      final months = _calculateAgeInMonths(child.tanggalLahir);
      if (_selectedAgeFilter == '0–11 bulan') return months <= 11;
      if (_selectedAgeFilter == '12–23 bulan') {
        return months >= 12 && months <= 23;
      }
      if (_selectedAgeFilter == '24+ bulan') return months >= 24;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredChildren;

    return Scaffold(
      backgroundColor: _surface,
      body: Stack(
        children: [
          // Pola titik-titik halus pada latar (surface-pattern)
          const Positioned.fill(
            child: CustomPaint(painter: _DotPatternPainter()),
          ),

          // Konten utama dengan RefreshIndicator
          RefreshIndicator(
            color: _primary,
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Curved Crimson-Magenta Gradient Hero Banner
                  const _ModernHeroBanner(
                    badgeText: 'Kelola Anak',
                    headline: 'Data Anak',
                    pillText: 'Si Kecil Terpantau!',
                    subtitle:
                        'Pantau tumbuh kembang dan riwayat gizi si kecil dalam satu tempat.',
                    bottomPadding: 40,
                  ),

                  // Main Content Area
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.22, 0.5],
                        colors: [
                          Color(0xB8F7E5EA),
                          Color(0x38F7E5EA),
                          Color(0x00FFFDF9),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: _surfaceContainer,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: _outlineVariant),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) =>
                                setState(() => _searchQuery = val),
                            style: const TextStyle(
                              fontSize: 14,
                              color: _onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Cari nama anak...',
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: _onSurfaceVariant,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: _primary,
                                size: 20,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: _onSurfaceVariant,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Kategori Usia Anak
                        const Text(
                          'Kategori Usia Anak',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _ageFilters.map((filter) {
                            final isSelected = _selectedAgeFilter == filter;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedAgeFilter = filter),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSelected ? 16 : 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _primary
                                      : _surfaceContainer,
                                  borderRadius: BorderRadius.circular(999),
                                  border: isSelected
                                      ? null
                                      : Border.all(color: _outlineVariant),
                                ),
                                child: Text(
                                  filter,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : _onSurfaceVariant,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Daftar Anak Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              'Daftar Anak',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: _onSurface,
                              ),
                            ),
                            Text(
                              '${filtered.length} anak',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Body Content (Loading / Error / Empty / List)
                        if (_loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 64),
                            child: Center(
                              child: CircularProgressIndicator(color: _primary),
                            ),
                          )
                        else if (_error != null)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: _surfaceContainer,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: _outlineVariant),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.wifi_off_rounded,
                                  size: 44,
                                  color: _onSurfaceVariant,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: _onSurface,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: _refresh,
                                  child: const Text(
                                    'Coba Lagi',
                                    style: TextStyle(
                                      color: _primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (_children.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 64),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.child_care_outlined,
                                  size: 52,
                                  color: _primary,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Belum ada data anak',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _onSurface,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Tekan Tambah Anak untuk mendaftarkan anak.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (filtered.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.search_off_rounded,
                                  size: 44,
                                  color: _onSurfaceVariant,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Tidak ada anak yang sesuai filter.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                      _selectedAgeFilter = 'Semua Usia';
                                    });
                                  },
                                  child: const Text(
                                    'Reset Filter',
                                    style: TextStyle(color: _primary),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final child = filtered[index];
                              return _ChildModernCard(
                                child: child,
                                onEdit: () => _openForm(child),
                                onDelete: () => _delete(child),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Action Button (+ Tambah Anak)
          Positioned(
            right: 20,
            bottom: 24,
            child: Material(
              color: _primary,
              borderRadius: BorderRadius.circular(16),
              elevation: 6,
              shadowColor: const Color(0x47A8224A),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openForm(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Tambah Anak',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildModernCard extends StatelessWidget {
  final Balita child;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ChildModernCard({
    required this.child,
    required this.onEdit,
    required this.onDelete,
  });

  static const Color _primary = Color(0xFFA8224A);
  static const Color _primaryContainer = Color(0xFFF7E5EA);
  static const Color _surface = Color(0xFFFFFDF9);
  static const Color _surfaceContainer = Color(0xFFFFFFFF);
  static const Color _onSurface = Color(0xFF1F1A1C);
  static const Color _onSurfaceVariant = Color(0xFF6B5E62);
  static const Color _outlineVariant = Color(0xFFE6DFDC);
  static const Color _errorColor = Color(0xFFBA1A1A);

  @override
  Widget build(BuildContext context) {
    final isMale = child.jenisKelamin.toLowerCase().contains('laki');

    return Container(
      decoration: BoxDecoration(
        color: _surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header: Avatar + Name + Code
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: _surface, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.child_care_outlined,
                    color: _primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: _onSurface,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _outlineVariant),
                        ),
                        child: Text(
                          child.id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: _onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Child Attributes Grid
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _AttributeRow(
                  icon: isMale ? Icons.male : Icons.female,
                  label: 'Jenis kelamin',
                  value: child.jenisKelamin,
                ),
                const SizedBox(height: 8),
                _AttributeRow(
                  icon: Icons.cake_outlined,
                  label: 'Tanggal lahir',
                  value: child.tanggalLahir,
                ),
                const SizedBox(height: 8),
                _AttributeRow(
                  icon: Icons.show_chart,
                  label: 'Riwayat pengukuran',
                  value: '${child.jumlahPengukuran}',
                ),
              ],
            ),
          ),

          // Card Footer Actions
          Container(
            decoration: const BoxDecoration(
              color: Color(0x99FFFDF9),
              border: Border(top: BorderSide(color: _outlineVariant)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onEdit,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: _primary),
                        SizedBox(width: 6),
                        Text(
                          'Ubah',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onDelete,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: _errorColor,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Hapus',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _errorColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttributeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AttributeRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xB3E6DFDC)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFFA8224A)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B5E62),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F1A1C),
            ),
          ),
        ],
      ),
    );
  }
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

  static const Color _primary = Color(0xFFA8224A);
  static const Color _surface = Color(0xFFFFFDF9);
  static const Color _surfaceContainer = Color(0xFFFFFFFF);
  static const Color _onSurface = Color(0xFF1F1A1C);
  static const Color _onSurfaceVariant = Color(0xFF6B5E62);
  static const Color _outline = Color(0xFF8E7F84);
  static const Color _outlineVariant = Color(0xFFE6DFDC);
  static const Color _errorColor = Color(0xFFBA1A1A);

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.child?.nama ?? '');
    _nik = TextEditingController(text: widget.child?.nik ?? '');
    final existingGender = widget.child?.jenisKelamin;
    _gender = (existingGender == 'Laki-laki' || existingGender == 'Perempuan')
        ? existingGender
        : null;
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

  InputDecoration _modernInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 16, color: _onSurfaceVariant),
      filled: true,
      fillColor: _surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.child != null;

    return Scaffold(
      backgroundColor: _surface,
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _DotPatternPainter()),
          ),
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Banner sesuai desain Tambah Anak
                _ModernHeroBanner(
                  badgeText: isEdit ? 'Ubah Data' : 'Tambah Anak',
                  headline: isEdit ? 'Perbarui,' : 'Daftarkan,',
                  pillText: 'Data Si Kecil',
                  subtitle:
                      'Lengkapi informasi anak untuk pantauan tumbuh kembang dan MPASI.',
                  bottomPadding: 48,
                ),

                // Form Content
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.22, 0.5],
                      colors: [
                        Color(0xB8F7E5EA),
                        Color(0x38F7E5EA),
                        Color(0x00FFFDF9),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // White Form Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _surfaceContainer,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: _outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nama Anak
                              const Text(
                                'Nama Anak',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _name,
                                maxLength: 60,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: _onSurface,
                                ),
                                decoration: _modernInputDecoration('Nama Anak')
                                    .copyWith(
                                      counterStyle: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        color: _onSurfaceVariant,
                                      ),
                                    ),
                                validator: (value) =>
                                    (value?.trim().length ?? 0) < 3
                                        ? 'Nama minimal 3 karakter.'
                                        : null,
                              ),

                              const SizedBox(height: 16),

                              // NIK (opsional)
                              const Text(
                                'NIK (opsional)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _nik,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(16),
                                ],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: _onSurface,
                                ),
                                decoration:
                                    _modernInputDecoration('NIK (opsional)'),
                                validator: (value) => value != null &&
                                        value.isNotEmpty &&
                                        value.length != 16
                                    ? 'NIK harus 16 digit.'
                                    : null,
                              ),

                              const SizedBox(height: 16),

                              // Jenis Kelamin
                              const Text(
                                'Jenis Kelamin',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: _gender,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: _onSurfaceVariant,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: _onSurface,
                                ),
                                decoration:
                                    _modernInputDecoration('Jenis Kelamin'),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Laki-laki',
                                    child: Text('Laki-laki'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Perempuan',
                                    child: Text('Perempuan'),
                                  ),
                                ],
                                onChanged: (value) =>
                                    setState(() => _gender = value),
                                validator: (value) =>
                                    value == null ? 'Pilih jenis kelamin.' : null,
                              ),

                              const SizedBox(height: 20),

                              // Tanggal Lahir
                              const Text(
                                'Tanggal Lahir',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _pickDate,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _primary,
                                    backgroundColor: _surface,
                                    side: const BorderSide(color: _outline),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 24,
                                    ),
                                    shape: const StadiumBorder(),
                                  ),
                                  icon: const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: _primary,
                                  ),
                                  label: Text(
                                    _birthDate == null
                                        ? 'Pilih Tanggal Lahir'
                                        : 'Tanggal Lahir: ${_formatDate(_birthDate!)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Primary Submit CTA
                        ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0x80A8224A),
                            elevation: 6,
                            shadowColor: const Color(0x38A8224A),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 24,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Simpan Data Anak',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernHeroBanner extends StatelessWidget {
  final String badgeText;
  final String headline;
  final String pillText;
  final String subtitle;
  final double bottomPadding;

  const _ModernHeroBanner({
    required this.badgeText,
    required this.headline,
    required this.pillText,
    required this.subtitle,
    this.bottomPadding = 44,
  });

  static const Color _primary = Color(0xFFA8224A);
  static const Color _primaryContainer = Color(0xFFF7E5EA);
  static const Color _onPrimaryContainer = Color(0xFF701230);
  static const Color _surfaceContainer = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.78, 0.92, 1.0],
              colors: [
                Color(0xEB8A153B),
                Color(0xE0981840),
                Color(0x73DC356E),
                Color(0x47F7E5EA),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Material(
                            color: const Color(0x26FFFFFF),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => Navigator.maybePop(context),
                              child: const SizedBox(
                                width: 36,
                                height: 36,
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.health_and_safety,
                              color: _primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'StuntGuard',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                'Jember Bebas Stunting',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xD9FFFFFF),
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    headline,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.15,
                      height: 1.28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      pillText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: -1,
          child: SizedBox(
            height: 36,
            width: double.infinity,
            child: CustomPaint(painter: _HeaderWavePainter()),
          ),
        ),
      ],
    );
  }
}

class _HeaderWavePainter extends CustomPainter {
  const _HeaderWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final backPaint = Paint()
      ..color = const Color(0x99F7E5EA)
      ..style = PaintingStyle.fill;

    final backPath = Path()
      ..moveTo(0, h * (16 / 44))
      ..cubicTo(
        w * (110 / 480),
        h * (38 / 44),
        w * (220 / 480),
        h * (2 / 44),
        w * (340 / 480),
        h * (16 / 44),
      )
      ..cubicTo(
        w * (400 / 480),
        h * (23 / 44),
        w * (448 / 480),
        h * (28 / 44),
        w,
        h * (18 / 44),
      )
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(backPath, backPaint);

    final frontPaint = Paint()
      ..color = const Color(0xFFFFFDF9)
      ..style = PaintingStyle.fill;

    final frontPath = Path()
      ..moveTo(0, h * (24 / 44))
      ..cubicTo(
        w * (120 / 480),
        h * (42 / 44),
        w * (230 / 480),
        h * (10 / 44),
        w * (350 / 480),
        h * (24 / 44),
      )
      ..cubicTo(
        w * (410 / 480),
        h * (31 / 44),
        w * (452 / 480),
        h * (34 / 44),
        w,
        h * (26 / 44),
      )
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(frontPath, frontPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DotPatternPainter extends CustomPainter {
  const _DotPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paintPrimary = Paint()..color = const Color(0x11A8224A);
    final paintAccent = Paint()..color = const Color(0x0CDC356E);
    const spacing = 24.0;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.1, paintPrimary);
        canvas.drawCircle(Offset(x + 12, y + 12), 1.1, paintAccent);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}