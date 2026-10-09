import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/catalog_models.dart';
import '../state/products_repository.dart';
import '../utils/payment_helper.dart';
import '../theme/app_colors.dart';
import '../utils/network_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final ShopProductDto product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ShopProductDto _product;
  bool _loadingDetail = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    if (_product.hasRichDetail) return;
    setState(() => _loadingDetail = true);
    try {
      final detail = await ProductsRepository.instance.fetchDetail(_product.id);
      if (!mounted) return;
      setState(() => _product = detail);
    } catch (_) {
      // Keep list payload if detail fails.
    } finally {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppColors.dark900,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Material(
                    color: Colors.black45,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: AppColors.creamDark),
                      if (product.imageUrl.isNotEmpty)
                        AppNetworkImage(
                          url: product.imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: Center(
                            child: Icon(Icons.shopping_bag_outlined,
                                size: 64, color: AppColors.warm400),
                          ),
                        ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.1),
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    product.category,
                                    style: GoogleFonts.vazirmatn(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                if (!product.inStock) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade700.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'ناموجود',
                                      style: GoogleFonts.vazirmatn(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.title,
                              style: GoogleFonts.vazirmatn(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_loadingDetail)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: LinearProgressIndicator(
                            color: AppColors.gold600,
                            backgroundColor: AppColors.gold50,
                          ),
                        ),
                      Text(
                        'محصول فیزیکی',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'توضیحات محصول',
                        style: GoogleFonts.vazirmatn(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.dark900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Text(
                          product.plainDescription.isEmpty
                              ? 'توضیحی ثبت نشده است.'
                              : product.plainDescription,
                          style: GoogleFonts.vazirmatn(
                            fontSize: 13.5,
                            height: 1.85,
                            color: AppColors.dark700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, MediaQuery.paddingOf(context).bottom + 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('قیمت',
                            style: GoogleFonts.vazirmatn(
                                fontSize: 11, color: AppColors.warm400)),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: product.priceLabel,
                                style: GoogleFonts.vazirmatn(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.dark900,
                                ),
                              ),
                              TextSpan(
                                text: ' تومان',
                                style: GoogleFonts.vazirmatn(
                                  fontSize: 12,
                                  color: AppColors.warm400,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: !product.inStock
                          ? null
                          : () => checkoutProductOnWebsite(
                                context,
                                productId: product.id,
                              ),
                      child: Opacity(
                        opacity: product.inStock ? 1 : 0.5,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppColors.goldGlow,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            product.inStock ? 'خرید / پرداخت' : 'ناموجود',
                            style: GoogleFonts.vazirmatn(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
