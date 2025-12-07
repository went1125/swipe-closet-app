import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/product_model.dart';
import '../providers/product_provider.dart';
import 'wishlist_page.dart';

// 引入剛剛拆分出來的 Widgets
import '../widgets/home/product_card.dart';
import '../widgets/home/home_action_buttons.dart';
import '../widgets/common/skeleton_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final CardSwiperController controller = CardSwiperController();
  int _swipeCount = 0;
  final int _adFrequency = 10;

  @override
  void initState() {
    super.initState();
    _signInAnonymously();
  }

  Future<void> _signInAnonymously() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
    } catch (e) {
      debugPrint("登入失敗: $e");
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsyncValue = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("滑滑衣櫥", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WishlistPage()),
            ),
          )
        ],
      ),
      body: productAsyncValue.when(
        // 使用 SkeletonCard
        loading: () => const Center(
            child: Padding(
                padding: EdgeInsets.all(24.0), child: SkeletonCard())),
        error: (err, stack) => Center(child: Text("錯誤: $err")),
        data: (products) {
          if (products.isEmpty) return const Center(child: Text("沒有商品了"));

          return Column(
            children: [
              Expanded(
                child: CardSwiper(
                  controller: controller,
                  cardsCount: products.length,
                  numberOfCardsDisplayed: 3,
                  padding: const EdgeInsets.all(24.0), // 統一 Padding
                  onSwipe: (previousIndex, currentIndex, direction) {
                    final product = products[previousIndex];
                    return _onSwipe(context, product, direction);
                  },
                  // 使用 ProductCard
                  cardBuilder: (context, index, x, y) =>
                      ProductCard(product: products[index]),
                ),
              ),
              // 使用 HomeActionButtons
              HomeActionButtons(
                onSwipeLeft: () => controller.swipe(CardSwiperDirection.left),
                onSwipeRight: () => controller.swipe(CardSwiperDirection.right),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _onSwipe(
      BuildContext context, Product product, CardSwiperDirection direction) {
    _swipeCount++;
    if (_swipeCount % _adFrequency == 0) {
      debugPrint("📢 廣告時間！");
    }

    if (direction == CardSwiperDirection.right) {
      _saveToWishlist(product);
    } else if (direction == CardSwiperDirection.top) {
      _launchShopee(product.deepLink);
    }
    return true;
  }

  Future<void> _saveToWishlist(Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(product.id)
          .set({
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'deepLink': product.deepLink,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("已收藏：${product.name}"),
            duration: const Duration(milliseconds: 500),
            backgroundColor: Colors.pinkAccent,
          ),
        );
      }
    } catch (e) {
      debugPrint("收藏失敗: $e");
    }
  }

  Future<void> _launchShopee(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri,
          mode: LaunchMode.externalNonBrowserApplication)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("跳轉失敗");
    }
  }
}