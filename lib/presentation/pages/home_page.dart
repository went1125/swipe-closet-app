// lib/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

// 引入剛剛寫好的 Model 和 Provider
import '../../data/models/product_model.dart';
import '../providers/product_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // 卡片控制器，用來控制左右滑動按鈕
  final CardSwiperController controller = CardSwiperController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 監聽 Provider 的狀態 (Loading / Data / Error)
    final productAsyncValue = ref.watch(productProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "滑滑衣櫥",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: productAsyncValue.when(
        // 1. 資料載入中：顯示轉圈圈
        loading: () => const Center(child: CircularProgressIndicator()),
        
        // 2. 發生錯誤：顯示錯誤訊息
        error: (err, stack) => Center(child: Text("發生錯誤: $err")),
        
        // 3. 資料載入成功：顯示卡片堆疊
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text("目前沒有商品，晚點再來！"));
          }

          return Column(
            children: [
              // --- 卡片滑動區 ---
              Expanded(
                child: CardSwiper(
                  controller: controller,
                  cardsCount: products.length,
                  numberOfCardsDisplayed: 3, // 一次顯示幾張卡片在後面
                  backCardOffset: const Offset(0, 40), // 後面卡片的位移距離
                  padding: const EdgeInsets.all(24.0), // 卡片外邊距
                  
                  // 卡片滑動回調函數
                  onSwipe: (previousIndex, currentIndex, direction) {
                    final product = products[previousIndex];
                    return _onSwipe(product, direction);
                  },
                  
                  // 建構每一張卡片
                  cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                    return _buildCard(products[index]);
                  },
                ),
              ),

              // --- 底部按鈕區 (X 和 愛心) ---
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0, top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.close,
                      color: Colors.red,
                      onPressed: () => controller.swipe(CardSwiperDirection.left),
                    ),
                    _buildActionButton(
                      icon: Icons.favorite,
                      color: Colors.green,
                      onPressed: () => controller.swipe(CardSwiperDirection.right),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- 抽取出來的卡片 UI 元件 ---
  Widget _buildCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. 商品圖片 (使用快取)
            CachedNetworkImage(
              imageUrl: product.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error, color: Colors.grey),
              ),
            ),

            // 2. 黑色漸層遮罩 (讓文字更清楚)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 3. 商品資訊文字
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "NT\$ ${product.price.toInt()}",
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 抽取出來的圓形按鈕 ---
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        iconSize: 32,
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  // --- 邏輯處理區 ---
  bool _onSwipe(Product product, CardSwiperDirection direction) {
    if (direction == CardSwiperDirection.right) {
      debugPrint("喜歡商品: ${product.name}");
      // TODO: 這裡加入收藏邏輯
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("已收藏: ${product.name}"), duration: const Duration(milliseconds: 500)),
      );
    } else if (direction == CardSwiperDirection.left) {
      debugPrint("跳過商品: ${product.name}");
    } else if (direction == CardSwiperDirection.top) {
       // 上滑購買
       _launchShopee(product.deepLink);
    }
    return true; // 允許滑動
  }

  // 開啟蝦皮連結
  Future<void> _launchShopee(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("無法開啟連結")),
        );
      }
    }
  }
}