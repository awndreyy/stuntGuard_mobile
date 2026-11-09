import 'dart:async';

import 'package:flutter/material.dart';

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
    'Semua Usia',
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

  void _selectCategory(int index) {
    _searchDebounce?.cancel();
    setState(() => _selectedCategory = index);
    _loadRecipes();
  }

  void _resetFilters() {
    _searchController.clear();
    _selectCategory(0);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return ColoredBox(
      color: _RecipeColors.background,
      child: RefreshIndicator(
        color: _RecipeColors.primary,
        onRefresh: () async {
          _searchDebounce?.cancel();
          await _loadRecipes();
        },
        child: ListView(
          key: const PageStorageKey('mpasi-list'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 120 + bottomInset),
          children: [
            _buildHeader(),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSearch(),
                      const SizedBox(height: 24),
                      const Text(
                        'Kategori Usia Anak',
                        style: TextStyle(
                          color: _RecipeColors.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCategories(),
                      const SizedBox(height: 28),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          const Text(
                            'Pilihan Menu Utama',
                            style: TextStyle(
                              color: _RecipeColors.ink,
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -.5,
                            ),
                          ),
                          Text(
                            _isLoading ? 'Memuat resep...' : '$_total resep',
                            style: const TextStyle(
                              color: _RecipeColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(48),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: _RecipeColors.primary,
                            ),
                          ),
                        )
                      else if (_error != null)
                        _buildMessage(_error!, retry: true)
                      else if (_recipes.isEmpty)
                        _buildMessage(
                          'Belum ada resep yang sesuai. Coba kata kunci atau kategori usia lainnya.',
                          retry: false,
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final largeText =
                                MediaQuery.textScalerOf(context).scale(14) > 21;
                            final columns =
                                largeText || constraints.maxWidth < 300
                                ? 1
                                : constraints.maxWidth >= 700
                                ? 3
                                : 2;
                            final width =
                                (constraints.maxWidth - (columns - 1) * 16) /
                                columns;
                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                for (final recipe in _recipes)
                                  SizedBox(
                                    width: width,
                                    child: _ResepCard(
                                      resep: recipe,
                                      onTap: () => _openDetail(recipe),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      if (_loadMoreError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            _loadMoreError!,
                            style: const TextStyle(
                              color: _RecipeColors.primary,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      if (!_isLoading &&
                          _error == null &&
                          _nextPage != null) ...[
                        const SizedBox(height: 28),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _RecipeColors.primary,
                            minimumSize: const Size.fromHeight(56),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            side: const BorderSide(color: _RecipeColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: _isLoadingMore
                              ? null
                              : () => _loadRecipes(loadMore: true),
                          child: _isLoadingMore
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _RecipeColors.primary,
                                  ),
                                )
                              : Text(
                                  _loadMoreError != null
                                      ? 'Coba Muat Lagi'
                                      : 'Muat Lebih Banyak Resep',
                                ),
                        ),
                      ],
                      if (!_isLoading && _error == null && _recipes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'Menampilkan ${_recipes.length} dari $_total resep',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _RecipeColors.muted,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => ClipPath(
    clipper: _HeaderWaveClipper(),
    child: Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 44),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF922447), Color(0xFFB90F42), _RecipeColors.primary],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Image.asset(
                      'assets/images/logo-StuntGuard.png',
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'StuntGuard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.5,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Jember Bebas Stunting',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'MPASI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'MPASI Sehat, ',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'Si Kecil Lahap!',
                      style: TextStyle(color: _RecipeColors.yellow),
                    ),
                  ],
                ),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: -.8,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Temukan menu bergizi sesuai usia untuk dukung tumbuh kembang optimal si kecil.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildSearch() => TextField(
    controller: _searchController,
    onChanged: (_) => _scheduleSearch(),
    onSubmitted: (_) {
      _searchDebounce?.cancel();
      _loadRecipes();
    },
    maxLength: 100,
    textInputAction: TextInputAction.search,
    style: const TextStyle(color: _RecipeColors.ink, fontSize: 14),
    decoration: InputDecoration(
      counterText: '',
      hintText: 'Cari resep MPASI...',
      hintStyle: const TextStyle(color: _RecipeColors.muted, fontSize: 14),
      prefixIcon: const Icon(
        Icons.search_rounded,
        color: _RecipeColors.primary,
      ),
      suffixIcon: _searchController.text.isEmpty
          ? null
          : IconButton(
              tooltip: 'Hapus pencarian',
              icon: const Icon(Icons.close_rounded, color: _RecipeColors.muted),
              onPressed: () {
                _searchController.clear();
                _searchDebounce?.cancel();
                _loadRecipes();
              },
            ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 19),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: _RecipeColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: _RecipeColors.primary, width: 2),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );

  Widget _buildCategories() => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (var i = 0; i < _categories.length; i++)
        ChoiceChip(
          label: Text(_categories[i]),
          selected: _selectedCategory == i,
          showCheckmark: false,
          selectedColor: _RecipeColors.primary,
          backgroundColor: Colors.white,
          side: BorderSide(
            color: _selectedCategory == i
                ? _RecipeColors.primary
                : _RecipeColors.line,
          ),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          materialTapTargetSize: MaterialTapTargetSize.padded,
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _selectedCategory == i ? Colors.white : _RecipeColors.ink,
          ),
          onSelected: (_) => _selectCategory(i),
        ),
    ],
  );

  Widget _buildMessage(String message, {required bool retry}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 12),
    child: Column(
      children: [
        Icon(
          retry ? Icons.wifi_off_rounded : Icons.ramen_dining_rounded,
          color: _RecipeColors.primary,
          size: 36,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _RecipeColors.muted, height: 1.5),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: _RecipeColors.primary,
            minimumSize: const Size(48, 48),
          ),
          onPressed: retry ? () => _loadRecipes() : _resetFilters,
          icon: Icon(
            retry ? Icons.refresh_rounded : Icons.filter_alt_off_rounded,
          ),
          label: Text(retry ? 'Coba Lagi' : 'Reset Filter'),
        ),
      ],
    ),
  );
}

class _ResepCard extends StatelessWidget {
  final Mpasi resep;
  final VoidCallback onTap;
  const _ResepCard({required this.resep, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Show actual nutrition from the API; do not infer health claims.
    final protein = resep.gizi.length > 3 ? resep.gizi[3] : '—';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ColoredBox(
                    color: _RecipeColors.pale,
                    child: MpasiRecipeImage(url: resep.gambarUrl, size: 48),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _RecipeColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        resep.usia,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _RecipeColors.pale,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Protein $protein',
                      maxLines: 2,
                      style: const TextStyle(
                        color: _RecipeColors.dark,
                        fontSize: 11,
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
                      color: _RecipeColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (resep.bahan.isNotEmpty) ...[
                    Text(
                      resep.bahan.first,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _RecipeColors.muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const Divider(height: 1, color: _RecipeColors.line),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _meta(
                        Icons.access_time_rounded,
                        '${resep.waktuMenit} mnt',
                        _RecipeColors.olive,
                      ),
                      _meta(
                        Icons.rice_bowl_outlined,
                        '${resep.jumlahPorsi} porsi',
                        _RecipeColors.primary,
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

  Widget _meta(IconData icon, String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ExcludeSemantics(child: Icon(icon, size: 16, color: color)),
      const SizedBox(width: 4),
      Flexible(
        child: Text(label, style: TextStyle(color: color, fontSize: 12)),
      ),
    ],
  );
}

class _RecipeColors {
  static const primary = Color(0xFFC8103D);
  static const dark = Color(0xFF8B1038);
  static const yellow = Color(0xFFFFD84D);
  static const background = Color(0xFFF7F8FA);
  static const ink = Color(0xFF222629);
  static const muted = Color(0xFF725C62);
  static const line = Color(0xFFEDE8EC);
  static const border = Color(0xFFF0BDCA);
  static const pale = Color(0xFFFFEDF1);
  static const olive = Color(0xFF7C6818);
}

class _HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..lineTo(0, size.height - 16)
    ..quadraticBezierTo(
      size.width * .12,
      size.height,
      size.width * .3,
      size.height - 12,
    )
    ..quadraticBezierTo(
      size.width * .45,
      size.height - 20,
      size.width * .55,
      size.height - 5,
    )
    ..quadraticBezierTo(
      size.width * .75,
      size.height + 2,
      size.width,
      size.height - 12,
    )
    ..lineTo(size.width, 0)
    ..close();

  @override
  bool shouldReclip(covariant _HeaderWaveClipper oldClipper) => false;
}
