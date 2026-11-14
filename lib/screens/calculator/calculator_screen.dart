import 'package:flutter/material.dart';

import '../../models/balita.dart';
import '../../services/balita_service.dart';
import '../../services/pengukuran_service.dart';
import '../../theme/sg_theme.dart';
import '../../widgets/sg_components.dart';
import '../../widgets/who_result_card.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorScreen> {
  final form = GlobalKey<FormState>();
  final weight = TextEditingController();
  final height = TextEditingController();
  final headCircumference = TextEditingController();
  final lila = TextEditingController();
  final _balitaService = BalitaService();
  final _pengukuranService = PengukuranService();
  List<Balita> _children = [];
  String? _selectedChildId;
  DateTime get _measurementDate => DateUtils.dateOnly(DateTime.now());
  String _bodyPosition = 'terlentang';
  Map<String, dynamic>? _result;
  bool _resultUnavailable = false;
  String? _loadError;
  bool _loadingChildren = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  @override
  void dispose() {
    weight.dispose();
    height.dispose();
    headCircumference.dispose();
    lila.dispose();
    super.dispose();
  }

  Future<void> _loadChildren() async {
    setState(() {
      _loadingChildren = true;
      _loadError = null;
    });

    try {
      final children = await _balitaService.fetchChildren();
      if (!mounted) return;
      setState(() {
        _children = children;
        if (!_children.any((child) => child.id == _selectedChildId)) {
          _selectedChildId = _children.isEmpty ? null : _children.first.id;
        }
        final child = _selectedChild;
        if (child != null) {
          _bodyPosition = _positionFor(child, _measurementDate);
        }
        _loadingChildren = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingChildren = false;
        _loadError = _messageFromError(error);
      });
    }
  }

  Future<void> _saveMeasurement() async {
    if (!form.currentState!.validate()) return;
    final child = _selectedChild;
    if (child == null) return;

    setState(() {
      _saving = true;
      _result = null;
      _resultUnavailable = false;
    });
    try {
      final response = await _pengukuranService.calculateForChild(
        childId: child.id,
        date: DateUtils.dateOnly(DateTime.now()),
        weight: _parseNumber(weight.text),
        height: _parseNumber(height.text),
        bodyPosition: _bodyPosition,
        headCircumference: _parseOptionalNumber(headCircumference.text),
        lila: _parseOptionalNumber(lila.text),
      );
      if (!mounted) return;
      final result = _extractCalculationResult(response);
      setState(() {
        _result = result;
        _resultUnavailable = result == null;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result == null
                ? 'Server tidak mengirimkan hasil WHO.'
                : 'Perhitungan WHO berhasil. Data tidak disimpan.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_messageFromError(error))));
    }
  }

  Balita? get _selectedChild {
    for (final child in _children) {
      if (child.id == _selectedChildId) return child;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => ScreenContent(
    title: 'Kalkulator Gizi',
    subtitle: 'Hitung Z-score WHO tanpa menyimpan pengukuran ke database.',
    children: [
      if (_loadingChildren)
        const SurfaceCard(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
        )
      else if (_loadError != null)
        SurfaceCard(
          child: Column(
            children: [
              Text(_loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _loadChildren,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            ],
          ),
        )
      else if (_children.isEmpty)
        const SurfaceCard(
          child: Text(
            'Belum ada data anak. Tambahkan data anak terlebih dahulu '
            'sebelum mencatat pengukuran.',
            textAlign: TextAlign.center,
          ),
        )
      else
        SurfaceCard(
          child: Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'A. Input Pengukuran',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  key: ValueKey('child-$_selectedChildId'),
                  initialValue: _selectedChildId,
                  decoration: const InputDecoration(labelText: 'Pilih anak'),
                  items: _children
                      .map(
                        (child) => DropdownMenuItem(
                          value: child.id,
                          child: Text(child.nama),
                        ),
                      )
                      .toList(),
                  onChanged: _saving
                      ? null
                      : (value) => setState(() {
                          _selectedChildId = value;
                          final child = _selectedChild;
                          if (child != null) {
                            _bodyPosition = _positionFor(
                              child,
                              _measurementDate,
                            );
                          }
                          _result = null;
                          _resultUnavailable = false;
                        }),
                ),
                const SizedBox(height: 16),
                const Text(
                  '2. Identitas Anak',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jenis kelamin: ${_genderLabel(_selectedChild?.jenisKelamin)}',
                ),
                const SizedBox(height: 4),
                Text('Usia: ${_ageLabel(_selectedChild, _measurementDate)}'),
                const SizedBox(height: 18),
                const Text(
                  '3. Pengukuran Utama',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: weight,
                  enabled: !_saving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Berat badan (kg)',
                    hintText: 'Contoh: 9,2',
                  ),
                  validator: (value) => _validateNumber(
                    value,
                    minimum: 1,
                    maximum: 50,
                    label: 'Berat badan',
                  ),
                  onChanged: (_) => setState(() {
                    _result = null;
                    _resultUnavailable = false;
                  }),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: height,
                  enabled: !_saving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Panjang / tinggi badan (cm)',
                    hintText: 'Contoh: 74,5',
                  ),
                  validator: (value) => _validateNumber(
                    value,
                    minimum: 20,
                    maximum: 150,
                    label: 'Panjang/tinggi badan',
                  ),
                  onChanged: (_) => setState(() {
                    _result = null;
                    _resultUnavailable = false;
                  }),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey('position-$_selectedChildId-$_bodyPosition'),
                  initialValue: _bodyPosition,
                  decoration: const InputDecoration(labelText: 'Posisi badan'),
                  items: const [
                    DropdownMenuItem(
                      value: 'terlentang',
                      child: Text('Terlentang (panjang badan)'),
                    ),
                    DropdownMenuItem(
                      value: 'berdiri',
                      child: Text('Berdiri (tinggi badan)'),
                    ),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) => setState(() {
                          _bodyPosition = value ?? _bodyPosition;
                          _result = null;
                          _resultUnavailable = false;
                        }),
                ),
                const SizedBox(height: 18),
                const Text(
                  '4. Pengukuran Tambahan (Opsional)',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: headCircumference,
                  enabled: !_saving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Lingkar kepala (cm)',
                    hintText: 'Contoh: 45,5',
                  ),
                  validator: (value) => _validateOptionalNumber(
                    value,
                    minimum: 20,
                    maximum: 70,
                    label: 'Lingkar kepala',
                  ),
                  onChanged: (_) => setState(() {
                    _result = null;
                    _resultUnavailable = false;
                  }),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: lila,
                  enabled: !_saving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'LiLA (cm)',
                    hintText: 'Contoh: 13,5',
                  ),
                  validator: (value) => _validateOptionalNumber(
                    value,
                    minimum: 5,
                    maximum: 40,
                    label: 'LiLA',
                  ),
                  onChanged: (_) => setState(() {
                    _result = null;
                    _resultUnavailable = false;
                  }),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _saving ? null : _saveMeasurement,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.calculate_outlined),
                  label: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _saving ? 'Menghitung...' : '5. Hitung Z-score WHO',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      if (_result != null) ...[
        const SizedBox(height: 16),
        WhoResultCard(result: _result!),
      ],
      if (_resultUnavailable) ...[
        const SizedBox(height: 16),
        const SurfaceCard(
          child: Text(
            'Server belum mengirimkan hasil perhitungan WHO. Tidak ada pengukuran yang disimpan.',
            style: TextStyle(color: SG.muted, height: 1.5),
          ),
        ),
      ],
    ],
  );
}

double _parseNumber(String value) =>
    double.parse(value.trim().replaceAll(',', '.'));

String? _validateNumber(
  String? value, {
  required double minimum,
  required double maximum,
  required String label,
}) {
  final parsed = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
  if (parsed == null ||
      !parsed.isFinite ||
      parsed < minimum ||
      parsed > maximum) {
    return '$label harus antara $minimum dan $maximum.';
  }
  return null;
}

double? _parseOptionalNumber(String value) =>
    value.trim().isEmpty ? null : _parseNumber(value);

String? _validateOptionalNumber(
  String? value, {
  required double minimum,
  required double maximum,
  required String label,
}) {
  if (value == null || value.trim().isEmpty) return null;
  return _validateNumber(
    value,
    minimum: minimum,
    maximum: maximum,
    label: label,
  );
}

String _genderLabel(String? value) {
  final lower = (value ?? '').toLowerCase();
  if (lower == 'l' || lower.contains('laki')) return 'Laki-laki';
  if (lower == 'p' || lower.contains('perempuan')) return 'Perempuan';
  return '-';
}

String _ageLabel(Balita? child, DateTime date) {
  if (child == null) return '-';
  final birth = DateTime.tryParse(child.tanggalLahir);
  if (birth == null) return '-';
  var months = (date.year - birth.year) * 12 + date.month - birth.month;
  if (date.day < birth.day) months--;
  return '${months < 0 ? 0 : months} bulan';
}

String _positionFor(Balita child, DateTime measurementDate) {
  final birthDate = DateTime.parse(child.tanggalLahir);
  var ageInMonths =
      (measurementDate.year - birthDate.year) * 12 +
      measurementDate.month -
      birthDate.month;
  if (measurementDate.day < birthDate.day) ageInMonths--;
  return ageInMonths < 24 ? 'terlentang' : 'berdiri';
}

String _messageFromError(Object error) =>
    error.toString().replaceFirst('Exception: ', '');

Map<String, dynamic>? _extractCalculationResult(Map<String, dynamic> response) {
  final nestedResult = response['hasil'];
  if (nestedResult is Map) {
    final result = Map<String, dynamic>.from(nestedResult);
    final child = response['balita'];
    final measurement = response['pengukuran'];
    if (child is Map) {
      result['usia_bulan'] = child['usia_bulan'];
      result['jenis_kelamin'] = child['jenis_kelamin'];
    }
    if (measurement is Map) {
      result['berat_badan'] = measurement['berat_badan'];
      result['tinggi_badan'] = measurement['tinggi_badan'];
      result['posisi_badan'] = measurement['posisi_badan'];
    }
    result['catatan'] =
        'Hasil hanya ditampilkan saat ini dan tidak disimpan ke database.';
    return result;
  }

  const resultKeys = [
    'z_score_tbu',
    'z_score',
    'z_bbu',
    'pbu',
    'status_stunting',
    'ringkasan',
  ];
  return resultKeys.any(response.containsKey) ? response : null;
}
