import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/catalog_models.dart';
import '../state/products_repository.dart';
import '../theme/app_colors.dart';
import '../utils/network_image.dart';
import 'product_detail_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _repo = ProductsRepository.instance;
  String _category = 'همه';

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepo);
    _repo.load();
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepo);
    super.dispose();
  }

  void _onRepo() {
    if (!mounted) return;
    setState(() {
      if (!_repo.categories.contains(_category)) {
        _category = 'همه';
      }
    });
  }

  void _open(ShopProductDto p) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ProductDetailScreen(product: p),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _repo.filtered(_category);
    final categories = _repo.categories;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'محصولات فیزیکی',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.dark900,
                      ),
                    ),
                    Text(
                      'از فروشگاه آکادمی کیک یوسف',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12,
                        color: AppColors.warm400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length} کالا',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold700,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = categories[i];
              final selected = cat == _category;
              return GestureDetector(
                onTap: () => setState(() => _category = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: selected ? AppColors.goldGradient : null,
                    color: selected ? null : AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Text(
                    cat,
                    style: GoogleFonts.vazirmatn(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.dark700,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(child: _buildBody(items)),
      ],
    );
  }

  Widget _buildBody(List<ShopProductDto> items) {
    if (_repo.loading && !_repo.hasData) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold600),
      );
    }

    if (_repo.error != null && !_repo.hasData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _repo.error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.vazirmatn(
                  color: AppColors.dark700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _repo.load(force: true),
                child: Text(
                  'تلاش مجدد',
                  style: GoogleFonts.vazirmatn(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Text(
          'محصولی در این دسته نیست',
          style: GoogleFonts.vazirmatn(
            color: AppColors.warm400,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.gold600,
      onRefresh: () => _repo.load(force: true),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final p = items[index];
          return _ProductCard(product: p, onTap: () => _open(p));
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ShopProductDto product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: AppColors.creamDark),
                      if (product.imageUrl.isNotEmpty)
                        AppNetworkImage(
                          url: product.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      if (product.category.isNotEmpty)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.category,
                              style: GoogleFonts.vazirmatn(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      if (product.discountLabel != null)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.gold600,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.discountLabel!,
                              style: GoogleFonts.vazirmatn(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      if (!product.inStock)
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color:
                                  Colors.red.shade700.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ناموجود',
                              style: GoogleFonts.vazirmatn(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark900,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (product.oldPriceLabel != null)
                      Text(
                        '${product.oldPriceLabel} ت',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 10,
                          color: AppColors.warm400,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      '${product.priceLabel} ت',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.gold700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
