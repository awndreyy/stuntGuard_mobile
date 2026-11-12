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
  final _balitaService = BalitaService();
  final _pengukuranService = PengukuranService();
  List<Balita> _children = [];
  String? _selectedChildId;
  DateTime _measurementDate = DateUtils.dateOnly(DateTime.now());
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

  Future<void> _pickMeasurementDate() async {
    final selectedChild = _selectedChild;
    final birthDate = selectedChild == null
        ? DateTime(2015)
        : DateTime.parse(selectedChild.tanggalLahir);
    final picked = await showDatePicker(
      context: context,
      initialDate: _measurementDate.isBefore(birthDate)
          ? DateUtils.dateOnly(DateTime.now())
          : _measurementDate,
      firstDate: birthDate,
      lastDate: DateUtils.dateOnly(DateTime.now()),
    );
    if (picked != null) {
      setState(() {
        _measurementDate = DateUtils.dateOnly(picked);
        final child = _selectedChild;
        if (child != null) {
          _bodyPosition = _positionFor(child, _measurementDate);
        }
        _result = null;
        _resultUnavailable = false;
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
      final response = await _pengukuranService.saveForChild(
        childId: child.id,
        date: _measurementDate,
        weight: _parseNumber(weight.text),
        height: _parseNumber(height.text),
        bodyPosition: _bodyPosition,
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
                ? 'Pengukuran tersimpan, tetapi server tidak mengirimkan hasil WHO.'
                : 'Pengukuran berhasil disimpan.',
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
    subtitle: 'Catat pengukuran dan lihat hasil perhitungan standar WHO.',
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
                  'Data pengukuran',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
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
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _pickMeasurementDate,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(
                    'Tanggal pengukuran: ${_formatDate(_measurementDate)}',
                  ),
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _saving ? null : _saveMeasurement,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_saving ? 'Menyimpan...' : 'Simpan pengukuran'),
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
            'Pengukuran tersimpan, tetapi API belum mengirimkan hasil perhitungan WHO lengkap. Periksa respons endpoint pengukuran.',
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

String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

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
    return Map<String, dynamic>.from(nestedResult);
  }

  const resultKeys = [
    'z_score',
    'z_bbu',
    'pbu',
    'status_stunting',
    'ringkasan',
  ];
  return resultKeys.any(response.containsKey) ? response : null;
}
