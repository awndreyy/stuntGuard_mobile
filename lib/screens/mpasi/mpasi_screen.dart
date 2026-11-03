import 'package:flutter/material.dart';

import '../../theme/sg_theme.dart';

// Data sementara untuk pratinjau UI.
// Nantinya diganti dengan model dan data dari API Laravel.
const _giziKosong = ['—', '—', '—', '—', '—', '—'];

class _ResepContoh {
  final String nama;
  final String usia;
  final int kategori;
  final int waktuMenit;
  final int jumlahPorsi;
  final IconData ilustrasi;
  final Color warnaIlustrasi;
  final List<String> gizi;
  final List<String> bahan;
  final List<String> langkah;

  const _ResepContoh({
    required this.nama,
    required this.usia,
    required this.kategori,
    required this.waktuMenit,
    required this.jumlahPorsi,
    required this.ilustrasi,
    required this.warnaIlustrasi,
    required this.gizi,
    required this.bahan,
    required this.langkah,
  });
}

class MpasiScreen extends StatefulWidget {
  const MpasiScreen({super.key});

  @override
  State<MpasiScreen> createState() => _MpasiScreenState();
}

class _MpasiScreenState extends State<MpasiScreen> {
  final _searchController = TextEditingController();

  int _selectedCategory = 0;

  static const _categories = [
    'Semua',
    '6–8 bulan',
    '9–11 bulan',
    '12–23 bulan',
  ];

  static const _recipes = [
    _ResepContoh(
      nama: 'Bubur Ayam Wortel',
      usia: '6–8 bulan',
      kategori: 1,
      waktuMenit: 25,
      jumlahPorsi: 2,
      ilustrasi: Icons.rice_bowl_rounded,
      warnaIlustrasi: Color(0xFFFCE6ED),
      // Angka ilustrasi, bukan hasil analisis gizi.
      gizi: ['185 kkal', '22 g', '7 g', '9 g', '1,8 mg', '1,2 mg'],
      bahan: [
        '50 g beras',
        '30 g daging ayam',
        '20 g wortel',
        'Air secukupnya',
      ],
      langkah: [
        'Masak beras bersama air hingga mulai lunak.',
        'Masukkan ayam dan wortel yang sudah disiapkan.',
        'Masak hingga semua bahan matang.',
        'Sesuaikan tekstur dengan kemampuan makan anak.',
      ],
    ),
    _ResepContoh(
      nama: 'Puree Labu Kuning',
      usia: '6–8 bulan',
      kategori: 1,
      waktuMenit: 15,
      jumlahPorsi: 2,
      ilustrasi: Icons.soup_kitchen_rounded,
      warnaIlustrasi: Color(0xFFFFEBD5),
      gizi: _giziKosong,
      bahan: ['Labu kuning', 'Air matang secukupnya'],
      langkah: [
        'Kupas, cuci, dan potong labu kuning.',
        'Kukus hingga matang dan lunak.',
        'Haluskan dan sesuaikan teksturnya.',
      ],
    ),
    _ResepContoh(
      nama: 'Nasi Tim Ikan',
      usia: '9–11 bulan',
      kategori: 2,
      waktuMenit: 30,
      jumlahPorsi: 2,
      ilustrasi: Icons.set_meal_rounded,
      warnaIlustrasi: Color(0xFFE4F3EB),
      gizi: _giziKosong,
      bahan: ['Nasi', 'Ikan tanpa duri', 'Wortel', 'Air secukupnya'],
      langkah: [
        'Siapkan ikan dan pastikan tidak ada duri.',
        'Masak nasi, ikan, dan sayuran hingga matang.',
        'Sesuaikan tekstur dengan usia anak.',
      ],
    ),
    _ResepContoh(
      nama: 'Bubur Telur Bayam',
      usia: '9–11 bulan',
      kategori: 2,
      waktuMenit: 20,
      jumlahPorsi: 2,
      ilustrasi: Icons.ramen_dining_rounded,
      warnaIlustrasi: Color(0xFFFFF0D7),
      gizi: _giziKosong,
      bahan: ['Nasi', 'Telur', 'Bayam', 'Air secukupnya'],
      langkah: [
        'Masak nasi bersama air hingga lunak.',
        'Tambahkan telur dan masak hingga matang.',
        'Masukkan bayam dan masak hingga matang.',
        'Sesuaikan tekstur sebelum disajikan.',
      ],
    ),
    _ResepContoh(
      nama: 'Nasi Ayam Sayur',
      usia: '12–23 bulan',
      kategori: 3,
      waktuMenit: 30,
      jumlahPorsi: 2,
      ilustrasi: Icons.lunch_dining_rounded,
      warnaIlustrasi: Color(0xFFF8E4EF),
      gizi: _giziKosong,
      bahan: ['Nasi', 'Ayam', 'Wortel', 'Sayuran hijau'],
      langkah: [
        'Siapkan ayam dan sayuran.',
        'Masak ayam hingga matang.',
        'Masukkan sayuran hingga matang.',
        'Sajikan bersama nasi dengan tekstur sesuai usia.',
      ],
    ),
    _ResepContoh(
      nama: 'Sup Tahu Wortel',
      usia: '12–23 bulan',
      kategori: 3,
      waktuMenit: 25,
      jumlahPorsi: 2,
      ilustrasi: Icons.soup_kitchen_rounded,
      warnaIlustrasi: Color(0xFFE5EEFC),
      gizi: _giziKosong,
      bahan: ['Tahu', 'Wortel', 'Sayuran', 'Air secukupnya'],
      langkah: [
        'Cuci dan potong semua bahan.',
        'Rebus wortel hingga mulai lunak.',
        'Tambahkan tahu dan sayuran.',
        'Masak hingga matang dan sajikan.',
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(_ResepContoh resep) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.50),
      builder: (_) => _ResepDetailSheet(resep: resep),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = _recipes.where((resep) {
      final sesuaiKategori =
          _selectedCategory == 0 || resep.kategori == _selectedCategory;

      final sesuaiPencarian =
          query.isEmpty || resep.nama.toLowerCase().contains(query);

      return sesuaiKategori && sesuaiPencarian;
    }).toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // HEADER PINK
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          decoration: const BoxDecoration(
            color: SG.primary,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LOGO DAN StunGuard Jember
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Image.asset(
                      'assets/images/logo-StuntGuard.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Text(
                      'StunGuard Jember',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 27),
              const Text(
                'MPASI Sehat,\nSi Kecil Lahap!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Temukan inspirasi makanan bergizi '
                'sesuai tahap usia buah hati.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari resep MPASI...',
                  hintStyle: const TextStyle(color: SG.muted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: SG.muted),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kategori Usia',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: SG.ink,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Pilih resep sesuai usia anak',
                style: TextStyle(fontSize: 12, color: SG.muted),
              ),
              const SizedBox(height: 15),

              // FILTER USIA
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_categories.length, (index) {
                    final active = _selectedCategory == index;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_categories[index]),
                        selected: active,
                        showCheckmark: false,
                        selectedColor: SG.primary,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: active ? SG.primary : SG.line),
                        shape: const StadiumBorder(),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: active ? Colors.white : SG.muted,
                        ),
                        onSelected: (_) {
                          setState(() => _selectedCategory = index);
                        },
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 26),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Inspirasi Resep',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: SG.ink,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: SG.pale,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${filtered.length} resep',
                      style: const TextStyle(
                        color: SG.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // GRID DUA KOLOM
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 35),
                  child: Center(
                    child: Text(
                      'Resep tidak ditemukan.',
                      style: TextStyle(color: SG.muted),
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 234,
                  ),
                  itemBuilder: (context, index) {
                    final resep = filtered[index];

                    return _ResepCard(
                      resep: resep,
                      onTap: () => _openDetail(resep),
                    );
                  },
                ),

              const SizedBox(height: 20),
              const Text(
                'Resep dan nilai gizi masih berupa data contoh. '
                'Nantinya seluruh informasi diambil dari API Laravel.',
                style: TextStyle(color: SG.muted, fontSize: 11, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// CARD RESEP
class _ResepCard extends StatelessWidget {
  final _ResepContoh resep;
  final VoidCallback onTap;

  const _ResepCard({required this.resep, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: const BorderSide(color: SG.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 118,
              width: double.infinity,
              color: resep.warnaIlustrasi,
              child: Icon(resep.ilustrasi, color: SG.primary, size: 48),
            ),
            Padding(
              padding: const EdgeInsets.all(11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: SG.pale,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      resep.usia,
                      style: const TextStyle(
                        color: SG.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resep.nama,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SG.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: SG.muted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${resep.waktuMenit} menit',
                        style: const TextStyle(color: SG.muted, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// POPUP DETAIL RESEP
class _ResepDetailSheet extends StatelessWidget {
  final _ResepContoh resep;

  const _ResepDetailSheet({required this.resep});

  static const _nutritionLabels = [
    'Energi',
    'Karbohidrat',
    'Lemak',
    'Protein',
    'Zat Besi',
    'Seng',
  ];

  static const _nutritionIcons = [
    Icons.bolt_rounded,
    Icons.grain_rounded,
    Icons.water_drop_rounded,
    Icons.fitness_center_rounded,
    Icons.health_and_safety_rounded,
    Icons.science_rounded,
  ];

  static const _nutritionColors = [
    Color(0xFFD81B60),
    Color(0xFFC85B18),
    Color(0xFFB77500),
    Color(0xFF1976D2),
    Color(0xFF00896B),
    Color(0xFF7B1FA2),
  ];

  static const _nutritionBackgrounds = [
    Color(0xFFFCECF2),
    Color(0xFFFFF4E9),
    Color(0xFFFFF9E9),
    Color(0xFFEDF5FF),
    Color(0xFFEAFBF4),
    Color(0xFFF5F0FF),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Container(
      height: screenHeight * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // HANDLE MODAL
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E4E9),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // HEADER POPUP
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Detail Resep',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: SG.ink,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Tutup',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: SG.primary),
                ),
              ],
            ),
          ),

          // KONTEN MODAL BISA DI-SCROLL
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
              children: [
                // FOTO / ILUSTRASI RESEP
                Container(
                  height: 175,
                  decoration: BoxDecoration(
                    color: resep.warnaIlustrasi,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(resep.ilustrasi, size: 80, color: SG.primary),
                ),

                const SizedBox(height: 18),

                Text(
                  resep.nama,
                  style: const TextStyle(
                    color: SG.primary,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _metaChip(
                      Icons.child_care_rounded,
                      resep.usia,
                      highlighted: true,
                    ),
                    _metaChip(
                      Icons.schedule_rounded,
                      '${resep.waktuMenit} menit',
                    ),
                    _metaChip(
                      Icons.restaurant_rounded,
                      '${resep.jumlahPorsi} porsi',
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                _sectionTitle(
                  Icons.monitor_heart_rounded,
                  'Kandungan Gizi per Porsi',
                ),

                const SizedBox(height: 12),

                // ENAM NILAI GIZI DALAM DUA KOLOM
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _nutritionLabels.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 82,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _nutritionBackgrounds[index],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _nutritionIcons[index],
                            color: _nutritionColors[index],
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nutritionLabels[index],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: SG.muted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  resep.gizi[index],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: _nutritionColors[index],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 26),

                _sectionTitle(
                  Icons.shopping_basket_rounded,
                  'Bahan yang Dibutuhkan',
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: SG.line),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      for (final bahan in resep.bahan)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: SG.primary,
                                size: 19,
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Text(
                                  bahan,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: SG.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                _sectionTitle(Icons.restaurant_menu_rounded, 'Cara Pembuatan'),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: SG.line),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      for (
                        var index = 0;
                        index < resep.langkah.length;
                        index++
                      ) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: SG.pale,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: SG.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    resep.langkah[index],
                                    style: const TextStyle(
                                      color: SG.ink,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (index < resep.langkah.length - 1)
                          const Divider(color: SG.line),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Data resep dan kandungan gizi hanya contoh '
                  'untuk pratinjau tampilan, bukan acuan gizi. '
                  'Data sebenarnya akan berasal dari API Laravel.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: SG.muted, fontSize: 11, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String label, {bool highlighted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: highlighted ? SG.pale : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: highlighted ? SG.primary : SG.muted),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: highlighted ? SG.primary : SG.ink,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: SG.primary, size: 21),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: SG.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
