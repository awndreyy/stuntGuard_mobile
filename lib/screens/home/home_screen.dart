import 'package:flutter/material.dart';
import '../../theme/sg_theme.dart';
import '../../widgets/sg_components.dart';
import '../profile/manage_children_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenCalculator;
  const HomeScreen({super.key, required this.onOpenCalculator});

  void _demoInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 17),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF3D7E4))),
          ),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: const Color(0xFFEA2F70), borderRadius: BorderRadius.circular(15)),
              child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 7, children: [
                const Text('StuntGuard', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: SG.ink)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFF9D7E5), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Jember', style: TextStyle(fontSize: 11, color: SG.primary)),
                ),
              ]),
              const SizedBox(height: 2),
              const Text('Monitoring Pertumbuhan Anak', style: TextStyle(color: SG.muted, fontSize: 12)),
            ])),
            IconButton.filledTonal(
              onPressed: () => _demoInfo(context, 'Notifikasi akan dihubungkan pada tahap integrasi.'),
              icon: const Icon(Icons.notifications_none_rounded, color: SG.ink),
              style: IconButton.styleFrom(backgroundColor: Colors.white),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 25, 22, 36),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Halo, Orang Tua! 👋', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: SG.ink)),
            const SizedBox(height: 5),
            const Text('Pantau tumbuh kembang si kecil secara terukur.', style: TextStyle(fontSize: 13, color: SG.muted)),
            const SizedBox(height: 25),
            SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ANAK YANG DIPANTAU', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: SG.muted, letterSpacing: .5)),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageChildrenScreen())),
                child: Row(children: [
                  CircleAvatar(radius: 22, backgroundColor: SG.pale, child: const Icon(Icons.child_care_rounded, color: SG.primary)),
                  const SizedBox(width: 11),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Belum memilih anak', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                    const SizedBox(height: 3),
                    Text.rich(TextSpan(children: [
                      const TextSpan(text: 'Data anak belum dihubungkan  •  ', style: TextStyle(color: SG.muted, fontSize: 11)),
                      TextSpan(text: 'Laravel API', style: TextStyle(color: Colors.teal.shade700, fontSize: 11)),
                    ])),
                  ])),
                  const Icon(Icons.chevron_right, color: SG.muted),
                ]),
              ),
            ])),
            const SizedBox(height: 29),
            Row(children: [
              const Expanded(child: Text('Pengukuran Terakhir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: SG.line), borderRadius: BorderRadius.circular(7)),
                child: const Text('Belum ada data', style: TextStyle(fontSize: 11, color: SG.muted))),
            ]),
            const SizedBox(height: 14),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _HomeMetric(icon: Icons.monitor_weight_outlined, label: 'Berat badan', value: '—', unit: 'kg', status: 'Belum ada pengukuran')),
              const SizedBox(width: 12),
              Expanded(child: _HomeMetric(icon: Icons.straighten_rounded, label: 'Panjang / tinggi', value: '—', unit: 'cm', status: 'Belum ada pengukuran')),
            ]),
            const SizedBox(height: 29),
            SectionHeader('Grafik Pertumbuhan', action: 'Lihat Riwayat  ›', onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
            }),
            const SizedBox(height: 8),
            SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.circle, color: Color(0xFF26B991), size: 12),
                const SizedBox(width: 8),
                const Expanded(child: Text('Grafik Pertumbuhan (Ilustrasi)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                const Text('TINGGI / UMUR', style: TextStyle(color: SG.muted, fontSize: 10)),
              ]),
              const SizedBox(height: 14),
              const Divider(color: SG.line, height: 1),
              const SizedBox(height: 15),
              const SizedBox(height: 134, width: double.infinity, child: Center(child: Text('Grafik menunggu data API pengukuran', textAlign: TextAlign.center, style: TextStyle(color: SG.muted)))),
              const SizedBox(height: 10),
              const Row(children: [
                Text('Usia: 12–24 bln', style: TextStyle(fontSize: 10, color: SG.muted)),
                Spacer(),
                Text('Contoh grafik', style: TextStyle(fontSize: 10, color: SG.primary)),
              ]),
              const SizedBox(height: 15),
              const Divider(color: SG.line, height: 1),
              const SizedBox(height: 13),
              const Text('Grafik hanya ilustrasi. Kurva dan status WHO harus berasal dari data standar WHO dan pengukuran anak sebenarnya.',
                  style: TextStyle(fontSize: 10, height: 1.35, color: SG.muted)),
            ])),
            const SizedBox(height: 29),
            Row(children: [
              const Expanded(child: Text('Aksi Cepat Posyandu', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18))),
              TextButton(onPressed: () => _demoInfo(context, 'Buku KIA Digital belum tersedia.'), child: const Text('Buku KIA Digital', style: TextStyle(fontSize: 11))),
            ]),
            const SizedBox(height: 10),
            Material(
              color: const Color(0xFFF23570),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onOpenCalculator,
                child: Padding(padding: const EdgeInsets.all(17), child: Row(children: [
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Icon(Icons.calculate_outlined, color: Colors.white, size: 18), SizedBox(width: 7),
                      Flexible(child: Text('KALKULATOR STUNTING', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)))]),
                    SizedBox(height: 7),
                    Text('Hitung Z-Score BB/U, TB/U & BB/TB melalui kalkulator.', style: TextStyle(color: Colors.white, fontSize: 11, height: 1.4)),
                  ])),
                  const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: const Text('Cek Skrining', style: TextStyle(color: SG.primary, fontWeight: FontWeight.w800, fontSize: 11))),
                ])),
              ),
            ),
            const SizedBox(height: 17),
            SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.restaurant_menu_rounded, size: 20, color: Color(0xFFD9A11B)),
                const SizedBox(width: 7),
                const Expanded(child: Text('REKOMENDASI MPASI LOKAL JEMBER', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                Container(padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: const Color(0xFFFFFAED), border: Border.all(color: const Color(0xFFF5E6B8)), borderRadius: BorderRadius.circular(6)),
                  child: const Text('Puger &\nSukorambi', style: TextStyle(fontSize: 9, color: Color(0xFFB08427)))),
              ]),
              const SizedBox(height: 16),
              const Row(children: [
                Expanded(child: _MiniRecipe(label: 'Tinggi Protein Hewani', name: 'Bubur Ikan Laut Puger & Labu', age: 'Usia 6–11 bln', color: SG.primary)),
                SizedBox(width: 8),
                Expanded(child: _MiniRecipe(label: 'Cegah Anemia', name: 'Puree Kelor Jember & Hati Ayam', age: 'Usia 12–24 bln', color: Color(0xFF16846E))),
              ]),
              const SizedBox(height: 7),
              const Text('Contoh rekomendasi desain; resep asli akan diambil dari API MPASI.', style: TextStyle(fontSize: 10, color: SG.muted)),
            ])),
          ]),
        ),
      ],
    );
  }
}

class _HomeMetric extends StatelessWidget {
  final IconData icon;
  final String label, value, unit, status;
  const _HomeMetric({required this.icon, required this.label, required this.value, required this.unit, required this.status});

  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: const EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: SG.pale, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 19, color: SG.primary)),
      const SizedBox(height: 12),
      Text(label, style: const TextStyle(fontSize: 12, color: SG.muted)),
      const SizedBox(height: 11),
      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
        child: Text.rich(TextSpan(children: [
          TextSpan(text: value, style: const TextStyle(fontSize: 27, color: SG.ink, fontWeight: FontWeight.w900)),
          TextSpan(text: ' $unit', style: const TextStyle(fontSize: 13, color: SG.muted)),
        ]))),
      const SizedBox(height: 11),
      Row(children: [
        const Icon(Icons.circle, size: 7, color: Color(0xFF21B88F)),
        const SizedBox(width: 4),
        Expanded(child: Text(status, maxLines: 2, style: const TextStyle(color: Color(0xFF16846E), fontSize: 10, fontWeight: FontWeight.w700))),
      ]),
    ]),
  );
}

class _MiniRecipe extends StatelessWidget {
  final String label, name, age;
  final Color color;
  const _MiniRecipe({required this.label, required this.name, required this.age, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(color: const Color(0xFFFFF7FA), border: Border.all(color: const Color(0xFFF5DDE6)), borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text(name, style: const TextStyle(color: SG.ink, fontSize: 12, height: 1.4)),
      const SizedBox(height: 9),
      Text(age, style: const TextStyle(color: SG.muted, fontSize: 10)),
    ]),
  );
}
