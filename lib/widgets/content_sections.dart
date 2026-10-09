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
            else if (!_repo.hasData)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  'هنوز محصولی متصل نشده — منتظر API فروشگاه',
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
                height: 220,
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
                        width: 155,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppColors.cardShadow,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 112,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ColoredBox(color: AppColors.creamDark),
                                  if (item.imageUrl.isNotEmpty)
                                    AppNetworkImage(
                                      url: item.imageUrl,
                                      width: 155,
                                      height: 112,
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
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.priceLabel,
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
