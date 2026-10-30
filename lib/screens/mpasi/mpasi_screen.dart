import 'package:flutter/material.dart';
import '../../theme/sg_theme.dart';
import '../../widgets/sg_components.dart';

class _ResepContoh {
  final String nama;
  final String usia;
  final int kategori;
  final IconData ilustrasi;

  const _ResepContoh({
    required this.nama,
    required this.usia,
    required this.kategori,
    required this.ilustrasi,
  });
}

class MpasiScreen extends StatefulWidget {
  const MpasiScreen({super.key});

  @override
  State<MpasiScreen> createState() => _MpasiPageState();
}

class _MpasiPageState extends State<MpasiScreen> {
  int category = 0;
  final categories = const ['Semua', '6–8 bulan', '9–11 bulan', '12+ bulan'];

  static const resepContoh = [
    _ResepContoh(nama: 'Bubur Ayam Wortel', usia: '6–8 bulan', kategori: 1, ilustrasi: Icons.rice_bowl_outlined),
    _ResepContoh(nama: 'Puree Labu Kuning', usia: '6–8 bulan', kategori: 1, ilustrasi: Icons.soup_kitchen_outlined),
    _ResepContoh(nama: 'Nasi Tim Ikan', usia: '9–11 bulan', kategori: 2, ilustrasi: Icons.set_meal_outlined),
    _ResepContoh(nama: 'Bubur Telur Bayam', usia: '9–11 bulan', kategori: 2, ilustrasi: Icons.ramen_dining_outlined),
    _ResepContoh(nama: 'Nasi Ayam Sayur', usia: '12+ bulan', kategori: 3, ilustrasi: Icons.lunch_dining_outlined),
    _ResepContoh(nama: 'Sup Tahu Wortel', usia: '12+ bulan', kategori: 3, ilustrasi: Icons.soup_kitchen_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = resepContoh
        .where((resep) => category == 0 || resep.kategori == category)
        .toList();

    return ScreenContent(
      title: 'Resep MPASI',
      subtitle: 'Inspirasi makanan pendamping ASI sesuai tahap usia anak.',
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(categories.length, (i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(categories[i]),
                selected: category == i,
                onSelected: (_) => setState(() => category = i),
              ),
            )),
          ),
        ),
        const SizedBox(height: 18),
        Row(children: [
          const Expanded(
            child: Text('Pilihan Resep', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          ),
          Text('${filtered.length} resep', style: const TextStyle(color: SG.muted, fontSize: 12)),
        ]),
        const SizedBox(height: 12),
        // Karena berada di dalam ScreenContent (ListView), grid menggunakan
        // shrinkWrap dan tidak memiliki scroll terpisah.
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 228,
          ),
          itemBuilder: (context, index) {
            final resep = filtered[index];
            return _ResepCard(
              resep: resep,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _ResepContohDetailPage(resep: resep),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        const Text(
          'Resep dan ilustrasi di atas hanya data contoh desain. '
          'Nantinya akan diganti dengan foto, resep, dan filter dari API Laravel.',
          style: TextStyle(fontSize: 12, color: SG.muted),
        ),
      ],
    );
  }
}

class _ResepCard extends StatelessWidget {
  final _ResepContoh resep;
  final VoidCallback onTap;

  const _ResepCard({required this.resep, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: SG.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder gambar. Saat API tersedia, ganti dengan Image.network
            // atau Image.asset dari path gambar yang valid.
            Container(
              width: double.infinity,
              height: 116,
              color: SG.pale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(resep.ilustrasi, size: 38, color: SG.primary),
                  const SizedBox(height: 5),
                  const Text('Foto resep', style: TextStyle(fontSize: 10, color: SG.muted)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 11, 11, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resep.nama,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      color: SG.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.child_care_outlined, color: SG.primary, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        resep.usia,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: SG.muted, fontSize: 11),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResepContohDetailPage extends StatelessWidget {
  final _ResepContoh resep;

  const _ResepContohDetailPage({required this.resep});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detail Resep MPASI')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: SG.pale,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(resep.ilustrasi, size: 72, color: SG.primary),
        ),
        const SizedBox(height: 18),
        Text(resep.nama, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Usia: ${resep.usia}', style: const TextStyle(color: SG.muted)),
        const SizedBox(height: 20),
        const SurfaceCard(
          child: Text(
            'Ini hanya kerangka halaman detail. Bahan, langkah memasak, '
            'dan foto akan berasal dari API MPASI Laravel.',
          ),
        ),
      ],
    ),
  );
}
