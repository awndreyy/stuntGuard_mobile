import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/balita.dart';
import '../../models/mandiri_record.dart';
import '../../services/auth_service.dart';
import '../../services/balita_service.dart';
import '../../services/mandiri_history_service.dart';
import '../../services/pengukuran_service.dart';
import '../../widgets/who_result_card.dart';
import 'mandiri_history_screen.dart';
import 'widgets/calculator_components.dart';
import 'widgets/calculator_header.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key, this.isActive = true});

  final bool isActive;

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
  final _historyService = MandiriHistoryService();
  final _authService = AuthService();
  final _preferences = SharedPreferencesAsync();

  String _lastChildKey(String accountId) => 'last_selected_child_$accountId';
  List<Balita> _children = [];
  String? _selectedChildId;
  DateTime get _measurementDate => DateUtils.dateOnly(DateTime.now());
  String _bodyPosition = 'terlentang';
  Map<String, dynamic>? _result;
  bool _resultUnavailable = false;
  String? _loadError;
  bool _loadingChildren = true;
  bool _saving = false;
  bool _savingLocal = false;
  bool _savedLocally = false;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  @override
  void didUpdateWidget(covariant CalculatorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _syncLastSelectedChild();
    }
  }

  Future<void> _syncLastSelectedChild() async {
    try {
      final accountId = await _authService.localAccountId();
      final savedId = await _preferences.getString(_lastChildKey(accountId));
      if (!mounted || _loadingChildren) return;

      final childExists =
          savedId != null && _children.any((child) => child.id == savedId);
      if (_children.isEmpty || (savedId != null && !childExists)) {
        await _loadChildren();
        return;
      }

      final nextId = childExists ? savedId : _children.first.id;
      if (_selectedChildId == nextId) return;

      setState(() {
        _selectedChildId = nextId;
        final child = _selectedChild;
        if (child != null) {
          _bodyPosition = _positionFor(child, _measurementDate);
        }
        _result = null;
        _resultUnavailable = false;
        _savedLocally = false;
      });
    } catch (error) {
      debugPrint('Gagal memuat anak terakhir di kalkulator: $error');
    }
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
      final accountId = await _authService.localAccountId();
      final children = await _balitaService.fetchChildren();
      final rememberedId = await _preferences.getString(
        _lastChildKey(accountId),
      );
      if (!mounted) return;
      setState(() {
        _children = children;
        _selectedChildId = _children.any((child) => child.id == rememberedId)
            ? rememberedId
            : (_children.isEmpty ? null : _children.first.id);
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

  Future<void> _rememberSelectedChild(String childId) async {
    try {
      final accountId = await _authService.localAccountId();
      await _preferences.setString(_lastChildKey(accountId), childId);
    } catch (error) {
      debugPrint('Tidak dapat menyimpan pilihan anak terakhir: $error');
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
      _savedLocally = false;
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
                ? 'Hasil pengecekan belum tersedia. Silakan coba lagi.'
                : 'Pengecekan selesai! Lihat hasilnya di bawah.',
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

  Future<void> _saveToLocalHistory() async {
    final child = _selectedChild;
    final result = _result;
    if (child == null || result == null || _savingLocal || _savedLocally) {
      return;
    }
    setState(() => _savingLocal = true);
    try {
      final accountId = await _historyService.accountId();
      await _historyService.save(
        MandiriRecord(
          accountId: accountId,
          childId: child.id,
          childName: child.nama,
          gender: child.jenisKelamin,
          measuredAt: _measurementDate,
          weight: _parseNumber(weight.text),
          height: _parseNumber(height.text),
          bodyPosition: _bodyPosition,
          headCircumference: _parseOptionalNumber(headCircumference.text),
          lila: _parseOptionalNumber(lila.text),
          result: Map<String, dynamic>.from(result),
        ),
      );
      if (!mounted) return;
      setState(() => _savedLocally = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Berhasil disimpan! Kamu bisa melihatnya lagi di Riwayat Mandiri.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_messageFromError(error))));
      if (mounted) setState(() => _savingLocal = false);
    }
  }

  Balita? get _selectedChild {
    for (final child in _children) {
      if (child.id == _selectedChildId) return child;
    }
    return null;
  }

  void _resetFormFields() {
    setState(() {
      _result = null;
      _resultUnavailable = false;
      _savedLocally = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return ColoredBox(
      color: CalcColors.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gutter = constraints.maxWidth > 600 ? 32.0 : 20.0;
          return ListView(
            key: const PageStorageKey('calculator-scroll'),
            padding: EdgeInsets.only(bottom: 120 + bottomInset),
            children: [
              CalculatorHeader(
                gutter: gutter,
                onOpenHistory: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MandiriHistoryScreen(),
                  ),
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(gutter, 20, gutter, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_loadingChildren)
                          const CalcCard(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 28),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: CalcColors.primary,
                                ),
                              ),
                            ),
                          )
                        else if (_loadError != null)
                          _buildErrorCard()
                        else if (_children.isEmpty)
                          _buildEmptyChildrenCard()
                        else ...[
                          CalcChildSelectorCard(
                            childrenList: _children,
                            selectedChild: _selectedChild,
                            selectedChildId: _selectedChildId,
                            enabled: !_saving,
                            genderText: _genderLabel(
                              _selectedChild?.jenisKelamin,
                            ),
                            ageText: _ageLabel(
                              _selectedChild,
                              _measurementDate,
                            ),
                            ageBuilder: (child) =>
                                _ageLabel(child, _measurementDate),
                            onSelected: (value) {
                              setState(() {
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
                                _savedLocally = false;
                              });
                              _rememberSelectedChild(value);
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildMeasurementFormCard(),
                        ],

                        if (_result != null) ...[
                          const SizedBox(height: 24),
                          const CalcSectionTitle(
                            title: 'Hasil Analisis',
                            subtitle:
                                'Evaluasi pertumbuhan berdasarkan standar antropometri.',
                          ),
                          const SizedBox(height: 12),
                          WhoResultCard(result: _result!),
                          const SizedBox(height: 14),
                          _buildSaveHistoryCard(),
                        ],

                        if (_resultUnavailable) ...[
                          const SizedBox(height: 20),
                          const CalcCard(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: CalcColors.primary,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Server belum mengirimkan hasil perhitungan. Tidak ada pengukuran yang disimpan.',
                                    style: TextStyle(
                                      color: CalcColors.muted,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMeasurementFormCard() {
    return CalcCard(
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pengukuran Utama',
              style: TextStyle(
                color: CalcColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Masukkan hasil timbang dan ukur hari ini.',
              style: TextStyle(color: CalcColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 320;
                final weightField = TextFormField(
                  controller: weight,
                  enabled: !_saving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: calcInputDecoration(
                    label: 'Berat badan (kg)',
                    hint: 'Contoh: 9,2',
                    icon: Icons.monitor_weight_outlined,
                  ),
                  validator: (value) => _validateNumber(
                    value,
                    minimum: 1,
                    maximum: 50,
                    label: 'Berat badan',
                  ),
                  onChanged: (_) => _resetFormFields(),
                );
                final heightField = TextFormField(
                  controller: height,
                  enabled: !_saving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: calcInputDecoration(
                    label: 'Panjang / tinggi (cm)',
                    hint: 'Contoh: 74,5',
                    icon: Icons.straighten_rounded,
                  ),
                  validator: (value) => _validateNumber(
                    value,
                    minimum: 20,
                    maximum: 150,
                    label: 'Panjang/tinggi badan',
                  ),
                  onChanged: (_) => _resetFormFields(),
                );

                if (stacked) {
                  return Column(
                    children: [
                      weightField,
                      const SizedBox(height: 14),
                      heightField,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: weightField),
                    const SizedBox(width: 12),
                    Expanded(child: heightField),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            const Text(
              'Posisi Pengukuran',
              style: TextStyle(
                color: CalcColors.ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CalcPositionOption(
                    title: 'Terlentang',
                    subtitle: 'Panjang badan (< 2 th)',
                    icon: Icons.airline_seat_flat_rounded,
                    selected: _bodyPosition == 'terlentang',
                    onTap: _saving
                        ? null
                        : () => setState(() {
                            _bodyPosition = 'terlentang';
                            _result = null;
                            _resultUnavailable = false;
                            _savedLocally = false;
                          }),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CalcPositionOption(
                    title: 'Berdiri',
                    subtitle: 'Tinggi badan (≥ 2 th)',
                    icon: Icons.accessibility_new_rounded,
                    selected: _bodyPosition == 'berdiri',
                    onTap: _saving
                        ? null
                        : () => setState(() {
                            _bodyPosition = 'berdiri';
                            _result = null;
                            _resultUnavailable = false;
                            _savedLocally = false;
                          }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Divider(height: 1, color: CalcColors.line),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pengukuran Tambahan',
                    style: TextStyle(
                      color: CalcColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: CalcColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CalcColors.line),
                  ),
                  child: const Text(
                    'Opsional',
                    style: TextStyle(
                      color: CalcColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 320;
                final headField = TextFormField(
                  controller: headCircumference,
                  enabled: !_saving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: calcInputDecoration(
                    label: 'Lingkar kepala (cm)',
                    hint: 'Contoh: 45,5',
                    icon: Icons.face_retouching_natural_rounded,
                  ),
                  validator: (value) => _validateOptionalNumber(
                    value,
                    minimum: 20,
                    maximum: 70,
                    label: 'Lingkar kepala',
                  ),
                  onChanged: (_) => _resetFormFields(),
                );
                final lilaField = TextFormField(
                  controller: lila,
                  enabled: !_saving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: calcInputDecoration(
                    label: 'LiLA (cm)',
                    hint: 'Contoh: 13,5',
                    icon: Icons.fitness_center_rounded,
                  ),
                  validator: (value) => _validateOptionalNumber(
                    value,
                    minimum: 5,
                    maximum: 40,
                    label: 'LiLA',
                  ),
                  onChanged: (_) => _resetFormFields(),
                );

                if (stacked) {
                  return Column(
                    children: [
                      headField,
                      const SizedBox(height: 14),
                      lilaField,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: headField),
                    const SizedBox(width: 12),
                    Expanded(child: lilaField),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _saveMeasurement,
              style: FilledButton.styleFrom(
                backgroundColor: CalcColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.calculate_outlined, size: 22),
              label: Text(_saving ? 'Menghitung...' : 'Hitung Z-score'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveHistoryCard() {
    return CalcCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: _savingLocal || _savedLocally
                ? null
                : _saveToLocalHistory,
            style: FilledButton.styleFrom(
              backgroundColor: _savedLocally
                  ? CalcColors.green
                  : CalcColors.primary,
              disabledBackgroundColor: _savedLocally
                  ? CalcColors.greenPale
                  : null,
              disabledForegroundColor: _savedLocally
                  ? CalcColors.green
                  : null,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: Icon(
              _savedLocally
                  ? Icons.check_circle_rounded
                  : Icons.bookmark_add_outlined,
            ),
            label: Text(
              _savingLocal
                  ? 'Menyimpan...'
                  : _savedLocally
                  ? 'Tersimpan di Riwayat Mandiri'
                  : 'Simpan ke Riwayat Mandiri',
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Riwayat ini hanya disimpan pada perangkat dan tidak memengaruhi pengukuran resmi petugas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CalcColors.muted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() => CalcCard(
    child: Column(
      children: [
        const Icon(
          Icons.wifi_off_rounded,
          color: CalcColors.primary,
          size: 36,
        ),
        const SizedBox(height: 12),
        Text(
          _loadError!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: CalcColors.muted, height: 1.5),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _loadChildren,
          style: OutlinedButton.styleFrom(
            foregroundColor: CalcColors.primary,
            side: const BorderSide(color: CalcColors.line),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Coba lagi'),
        ),
      ],
    ),
  );

  Widget _buildEmptyChildrenCard() => CalcCard(
    child: const Column(
      children: [
        Icon(
          Icons.child_care_rounded,
          color: CalcColors.primary,
          size: 38,
        ),
        SizedBox(height: 12),
        Text(
          'Belum ada data anak. Tambahkan data anak terlebih dahulu di menu Profil sebelum mencatat pengukuran.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: CalcColors.muted,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    ),
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
  final birthDate = DateTime.tryParse(child.tanggalLahir);
  if (birthDate == null) return 'terlentang';
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
        'Hasil pengecekan mandiri, bukan pengukuran resmi petugas.';
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