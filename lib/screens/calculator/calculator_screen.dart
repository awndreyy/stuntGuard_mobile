import 'package:flutter/material.dart';
import '../../theme/sg_theme.dart';
import '../../widgets/sg_components.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorScreen> {
  final form = GlobalKey<FormState>();
  final weight = TextEditingController();
  final height = TextEditingController();
  String gender = 'Laki-laki';
  DateTime? birthDate;

  @override
  void dispose() {
    weight.dispose();
    height.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScreenContent(
        title: 'Kalkulator Gizi',
        subtitle: 'Pengecekan mandiri. Hasil tidak disimpan ke database.',
        children: [
          SurfaceCard(child: Form(
            key: form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('Data pengukuran', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: gender,
                decoration: const InputDecoration(labelText: 'Jenis kelamin'),
                items: const [
                  DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                ],
                onChanged: (v) => setState(() => gender = v ?? gender),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: birthDate ?? DateTime.now().subtract(const Duration(days: 365)),
                    firstDate: DateTime(2015),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => birthDate = picked);
                },
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(birthDate == null ? 'Pilih tanggal lahir' : '${birthDate!.day}/${birthDate!.month}/${birthDate!.year}'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: weight,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Berat badan (kg)', hintText: 'Contoh: 9.2'),
                validator: (s) => (double.tryParse((s ?? '').replaceAll(',', '.')) ?? 0) <= 0 ? 'Masukkan berat yang valid' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: height,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Panjang / tinggi badan (cm)', hintText: 'Contoh: 74.5'),
                validator: (s) => (double.tryParse((s ?? '').replaceAll(',', '.')) ?? 0) <= 0 ? 'Masukkan panjang/tinggi yang valid' : null,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  if (!form.currentState!.validate()) return;
                  if (birthDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih tanggal lahir terlebih dahulu.')));
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Kerangka UI siap. Hubungkan API kalkulator WHO Laravel untuk menampilkan hasil.'),
                  ));
                },
                icon: const Icon(Icons.calculate_outlined),
                label: const Padding(padding: EdgeInsets.all(12), child: Text('Hitung Status Gizi')),
              ),
              const SizedBox(height: 10),
              const Text('Belum ada perhitungan WHO di kerangka ini. Tombol belum mengirim ke server.', style: TextStyle(fontSize: 12, color: SG.muted)),
            ]),
          )),
        ],
      );
}

// Data berikut hanya contoh untuk memvisualisasikan grid 2 kolom.
// Nantinya ganti dengan data resep dari API Laravel.
