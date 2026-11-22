import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/mpasi.dart';
import '../../services/mpasi_service.dart';
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
      color: MpasiColors.background,
      child: RefreshIndicator(
        color: MpasiColors.primary,
        onRefresh: () async {
          _searchDebounce?.cancel();
          await _loadRecipes();
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
                      MpasiSearch(
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
                      const SizedBox(height: 24),
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
                                    child: MpasiRecipeCard(
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
                      if (!_isLoading && _error == null && _recipes.isNotEmpty)
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
}
