import 'package:flutter/material.dart';

import '../widgets/content_sections.dart';
import '../widgets/courses_section.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_access_grid.dart';
import '../widgets/stories_row.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      physics: BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(child: HomeHeader()),
        SliverToBoxAdapter(child: SizedBox(height: 6)),
        SliverToBoxAdapter(child: StoriesRow()),
        SliverToBoxAdapter(child: SizedBox(height: 14)),
        SliverToBoxAdapter(child: QuickAccessGrid()),
        SliverToBoxAdapter(child: SizedBox(height: 28)),
        SliverToBoxAdapter(child: PopularCoursesSection()),
        SliverToBoxAdapter(child: SizedBox(height: 28)),
        SliverToBoxAdapter(child: ProductsSection()),
        SliverToBoxAdapter(child: SizedBox(height: 28)),
      ],
    );
  }
}
