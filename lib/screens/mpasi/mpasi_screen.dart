import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/sg_theme.dart';
import '../../models/mpasi.dart';
import '../../services/mpasi_service.dart';
import '../login_screen.dart';
import '../../widgets/mpasi_recipe_image.dart';
import 'mpasi_detail_screen.dart';

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

  final _service = MpasiService();
  final List<Mpasi> _recipes = [];
  Timer? _searchDebounce;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  String? _loadMoreError;
  int _total = 0;
  int? _nextPage;
  int _requestVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _scheduleSearch() {
    _searchDebounce?.cancel();
    ++_requestVersion;
    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _error = null;
      _loadMoreError = null;
    });
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _loadRecipes();
    });
  }

  Future<void> _loadRecipes({bool loadMore = false}) async {
    if (loadMore && (_isLoading || _isLoadingMore || _nextPage == null)) return;
    final version = ++_requestVersion;
    final page = loadMore ? _nextPage! : 1;
    const ageCodes = [null, '6-8', '9-11', '12-23'];
    setState(() {
      if (loadMore) {
        _isLoadingMore = true;
        _loadMoreError = null;
      } else {
        _isLoading = true;
        _isLoadingMore = false;
        _error = null;
        _loadMoreError = null;
        _recipes.clear();
        _total = 0;
        _nextPage = null;
      }
    });

    try {
      final result = await _service.fetchRecipes(
        query: _searchController.text,
        kategoriUsia: ageCodes[_selectedCategory],
        page: page,
      );
      if (!mounted || version != _requestVersion) return;
      setState(() {
        final ids = _recipes.map((recipe) => recipe.id).toSet();
        _recipes.addAll(result.recipes.where((recipe) => ids.add(recipe.id)));
        _total = result.total;
        _nextPage = result.nextPage;
      });
    } catch (error) {
      if (!mounted || version != _requestVersion) return;
      if (error is MpasiAuthenticationException) {
        _searchDebounce?.cancel();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan login kembali untuk membuka resep MPASI.'),
          ),
        );
        return;
      }
      setState(() {
        const message =
            'Resep belum dapat dimuat. Periksa koneksi lalu coba lagi.';
        if (loadMore) {
          _loadMoreError = message;
        } else {
          _error = message;
        }
      });
    } finally {
      if (mounted && version == _requestVersion) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(Mpasi resep) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => MpasiDetailScreen(resep: resep)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _searchDebounce?.cancel();
        await _loadRecipes();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                        'StuntGuard Jember',
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
                  onChanged: (_) => _scheduleSearch(),
                  maxLength: 100,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Cari resep MPASI...',
                    hintStyle: const TextStyle(color: SG.muted, fontSize: 13),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: SG.muted,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchController.clear();
                              _searchDebounce?.cancel();
                              _loadRecipes();
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
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 120),
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
                          side: BorderSide(
                            color: active ? SG.primary : SG.line,
                          ),
                          shape: const StadiumBorder(),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: active ? Colors.white : SG.muted,
                          ),
                          onSelected: (_) {
                            _searchDebounce?.cancel();
                            setState(() => _selectedCategory = index);
                            _loadRecipes();
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
                        _isLoading ? 'Memuat...' : '$_total resep',
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
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(35),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  Column(
                    children: [
                      Text(_error!, style: const TextStyle(color: SG.muted)),
                      TextButton.icon(
                        onPressed: () => _loadRecipes(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Coba lagi'),
                      ),
                    ],
                  )
                else if (_recipes.isEmpty)
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
                    itemCount: _recipes.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 234,
                        ),
                    itemBuilder: (context, index) {
                      final resep = _recipes[index];

                      return _ResepCard(
                        resep: resep,
                        onTap: () => _openDetail(resep),
                      );
                    },
                  ),

                if (_loadMoreError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _loadMoreError!,
                    style: const TextStyle(color: SG.muted),
                  ),
                ],
                if (!_isLoading && _error == null && _nextPage != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: OutlinedButton(
                      onPressed: _isLoadingMore
                          ? null
                          : () => _loadRecipes(loadMore: true),
                      child: Text(
                        _isLoadingMore ? 'Memuat...' : 'Muat resep lainnya',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// CARD RESEP
class _ResepCard extends StatelessWidget {
  final Mpasi resep;
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
              color: SG.pale,
              child: MpasiRecipeImage(url: resep.gambarUrl, size: 48),
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
