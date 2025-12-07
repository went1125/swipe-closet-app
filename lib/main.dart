// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 引入你的首頁
import 'presentation/pages/home_page.dart';

void main() {
  // 這裡一定要包一層 ProviderScope，不然 Riverpod 無法運作
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '滑滑衣櫥',
      debugShowCheckedModeBanner: false, // 去掉右上角的 debug 標籤
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home: const HomePage(), // 設定首頁
    );
  }
}