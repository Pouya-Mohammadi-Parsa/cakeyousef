import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/product_detail_screen.dart';
import '../state/products_repository.dart';
import '../theme/app_colors.dart';
import '../utils/app_nav.dart';
import '../utils/network_image.dart';
import 'section_header.dart';

class ProductsSection extends StatefulWidget {
  const ProductsSection({super.key});

  @override
  State<ProductsSection> createState() => _ProductsSectionState();
}

class _ProductsSectionState extends State<ProductsSection> {
  final _repo = ProductsRepository.instance;

  @override
  void initState() {
    super.initState();
    _repo.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repo,
      builder: (context, _) {
        final products = _repo.homePreview;
        return Column(
          children: [
            SectionHeader(
              title: 'محصولات فیزیکی',
              onSeeAll: () => MainTabScope.go(context, 3),
            ),
            const SizedBox(height: 12),
            if (_repo.loading && !_repo.hasData)
              const SizedBox(
                height: 120,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.gold600),
                ),
              )
            else if (_repo.error != null && !_repo.hasData)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    Text(
                      _repo.error!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warm400,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _repo.load(force: true),
                      child: Text(
                        'تلاش مجدد',
                        style:
                            GoogleFonts.vazirmatn(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              )
            else if (!_repo.hasData)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  'محصولی برای نمایش نیست',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.vazirmatn(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warm400,
                  ),
                ),
              )
            else
              SizedBox(
                height: 228,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: item),
                          ),
                        );
                      },
                      child: Container(
                        width: 158,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.warm200.withValues(alpha: 0.45),
                          ),
                          boxShadow: AppColors.cardShadow,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 118,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ColoredBox(color: AppColors.creamDark),
                                  if (item.imageUrl.isNotEmpty)
                                    AppNetworkImage(
                                      url: item.imageUrl,
                                      width: 158,
                                      height: 118,
                                    ),
                                  if (item.category.isNotEmpty)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.45),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          item.category,
                                          style: GoogleFonts.vazirmatn(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (!item.inStock)
                                    Positioned(
                                      left: 8,
                                      bottom: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade700
                                              .withValues(alpha: 0.9),
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.vazirmatn(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.dark900,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${item.priceLabel} ت',
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
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
