import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/mpasi.dart';
import '../../services/mpasi_service.dart';
import '../../services/mpasi_favorite_service.dart';
import '../login_screen.dart';
import 'mpasi_detail_screen.dart';
import 'widgets/mpasi_header.dart';
import 'widgets/mpasi_components.dart';

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
  final _favorites = MpasiFavoriteService();
  bool _showSaved = false;
  bool _isLoadingSaved = false;
  final List<Mpasi> _savedRecipes = [];
  Set<String> _savedIds = {};
  final Set<String> _savingIds = {};
  String? _savedError;
  int _savedLoadVersion = 0;
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
    _refreshFavorites();
  }

  Future<void> _refreshFavorites() async {
    try {
      final ids = await _favorites.ids();
      if (mounted) {
        setState(() => _savedIds = ids);
      }
    } catch (error) {
      debugPrint('Gagal membaca penanda resep tersimpan: $error');
    }
  }

  Future<void> _loadSaved() async {
    final request = ++_savedLoadVersion;
    if (!mounted) return;
    setState(() {
      _isLoadingSaved = true;
      _savedError = null;
    });
    try {
      final recipes = await _favorites.list();
      if (!mounted || request != _savedLoadVersion) return;
      setState(() {
        _savedRecipes
          ..clear()
          ..addAll(recipes);
        _savedIds = recipes.map((r) => r.id).toSet();
      });
    } catch (error, stackTrace) {
      debugPrint('Gagal memuat resep tersimpan: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted && request == _savedLoadVersion) {
        setState(
          () => _savedError =
              'Resep simpanan belum bisa dibuka. Silakan coba lagi.',
        );
      }
    } finally {
      if (mounted && request == _savedLoadVersion) {
        setState(() => _isLoadingSaved = false);
      }
    }
  }

  Future<void> _toggleFavorite(Mpasi recipe) async {
    if (_savingIds.contains(recipe.id)) return;
    setState(() => _savingIds.add(recipe.id));
    try {
      if (_savedIds.contains(recipe.id)) {
        await _favorites.remove(recipe.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resep telah dihapus dari daftar simpanan.'),
          ),
        );
      } else {
        await _favorites.save(recipe);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Resep berhasil disimpan. Kamu bisa membacanya kapan saja.',
            ),
          ),
        );
      }
      // Muat langsung dari SQLite, bukan hanya mengandalkan state ikon.
      await _loadSaved();
      await _refreshFavorites();
    } catch (error, stackTrace) {
      debugPrint('Gagal memperbarui resep tersimpan: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Belum berhasil menyimpan perubahan. Silakan coba lagi.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _savingIds.remove(recipe.id));
      }
    }
  }

  void _switchTab(bool saved) {
    setState(() => _showSaved = saved);
    if (saved) {
      _loadSaved();
    } else {
      _refreshFavorites();
    }
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
    if (loadMore && (_isLoading || _isLoadingMore || _nextPage == null)) {
      return;
    }
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

  Future<void> _openDetail(Mpasi resep) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => MpasiDetailScreen(resep: resep)),
    );
    if (!mounted) return;
    await _refreshFavorites();
    if (_showSaved) await _loadSaved();
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
      color: MpasiColors.background,
      child: RefreshIndicator(
        color: MpasiColors.primary,
        onRefresh: () async {
          _searchDebounce?.cancel();
          if (_showSaved) {
            await _loadSaved();
          } else {
            await _loadRecipes();
          }
        },
        child: ListView(
          key: const PageStorageKey('mpasi-list'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 120 + bottomInset),
          children: [
            const MpasiHeader(),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_showSaved) ...[
                        Row(
                          children: [
                            Expanded(
                              child: MpasiSearch(
                                controller: _searchController,
                                onChanged: _scheduleSearch,
                                onSubmitted: () {
                                  _searchDebounce?.cancel();
                                  _loadRecipes();
                                },
                                onCleared: () {
                                  _searchDebounce?.cancel();
                                  _loadRecipes();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Tooltip(
                              message: 'Resep tersimpan',
                              child: Material(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: const BorderSide(
                                    color: MpasiColors.border,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => _switchTab(true),
                                  borderRadius: BorderRadius.circular(18),
                                  child: const SizedBox(
                                    width: 54,
                                    height: 54,
                                    child: Icon(
                                      Icons.bookmark_rounded,
                                      color: MpasiColors.primary,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _switchTab(false),
                              tooltip: 'Kembali ke semua resep',
                              icon: const Icon(Icons.arrow_back_rounded),
                              color: MpasiColors.primary,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: MpasiColors.border,
                                ),
                                minimumSize: const Size(48, 48),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Resep Tersimpan',
                                style: TextStyle(
                                  color: MpasiColors.ink,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (!_showSaved) ...[
                        const Text(
                          'Kategori Usia Anak',
                          style: TextStyle(
                            color: MpasiColors.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        MpasiCategoryFilter(
                          categories: _categories,
                          selectedCategory: _selectedCategory,
                          onSelected: _selectCategory,
                        ),
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
                                color: MpasiColors.ink,
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -.5,
                              ),
                            ),
                            Text(
                              _isLoading ? 'Memuat resep...' : '$_total resep',
                              style: const TextStyle(
                                color: MpasiColors.muted,
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
                                color: MpasiColors.primary,
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
                                  MediaQuery.textScalerOf(context).scale(14) >
                                  21;
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
                                      child: MpasiRecipeCard(
                                        resep: recipe,
                                        onTap: () => _openDetail(recipe),
                                        isSaved: _savedIds.contains(recipe.id),
                                        onToggleSave:
                                            _savingIds.contains(recipe.id)
                                            ? null
                                            : () => _toggleFavorite(recipe),
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
                                color: MpasiColors.primary,
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
                              foregroundColor: MpasiColors.primary,
                              minimumSize: const Size.fromHeight(56),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              side: const BorderSide(color: MpasiColors.border),
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
                                      color: MpasiColors.primary,
                                    ),
                                  )
                                : Text(
                                    _loadMoreError != null
                                        ? 'Coba Muat Lagi'
                                        : 'Muat Lebih Banyak Resep',
                                  ),
                          ),
                        ],
                        if (!_isLoading &&
                            _error == null &&
                            _recipes.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'Menampilkan ${_recipes.length} dari $_total resep',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: MpasiColors.muted,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ),
                      ] else ...[
                        const Text(
                          'Buka kembali resep favoritmu kapan saja, bahkan tanpa internet.',
                          style: TextStyle(color: MpasiColors.muted),
                        ),
                        const SizedBox(height: 18),
                        if (_isLoadingSaved)
                          const Center(child: CircularProgressIndicator())
                        else if (_savedError != null)
                          _buildSavedMessage(_savedError!)
                        else if (_savedRecipes.isEmpty)
                          _buildSavedMessage(
                            'Belum ada resep yang disimpan. Yuk, pilih resep favoritmu!',
                          ),
                        if (!_isLoadingSaved &&
                            _savedError == null &&
                            _savedRecipes.isNotEmpty)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final largeText =
                                  MediaQuery.textScalerOf(context).scale(14) >
                                  21;
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
                                  for (final recipe in _savedRecipes)
                                    SizedBox(
                                      width: width,
                                      child: MpasiRecipeCard(
                                        resep: recipe,
                                        isSaved: true,
                                        onTap: () => _openDetail(recipe),
                                        onToggleSave:
                                            _savingIds.contains(recipe.id)
                                            ? null
                                            : () => _toggleFavorite(recipe),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                      ],
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

  Widget _buildMessage(String message, {required bool retry}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 12),
    child: Column(
      children: [
        Icon(
          retry ? Icons.wifi_off_rounded : Icons.ramen_dining_rounded,
          color: MpasiColors.primary,
          size: 36,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: MpasiColors.muted, height: 1.5),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: MpasiColors.primary,
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

  Widget _buildSavedMessage(String message) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 36),
    child: Column(
      children: [
        const Icon(
          Icons.bookmark_border_rounded,
          size: 40,
          color: MpasiColors.primary,
        ),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _loadSaved,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Muat Ulang'),
        ),
      ],
    ),
  );
}
