// lib/presentation/providers/product_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/models/product_model.dart';

final productProvider = FutureProvider<List<Product>>((ref) async {
  
  // 1. 設定你的 API 網址 (請換成你剛剛複製的那個 URL)
  // 注意：如果你是用模擬器，也可以連線到本地 firebase (但先用雲端比較簡單)
  const String apiUrl = 'https://us-central1-swipe-closet-wayne-v1.cloudfunctions.net/getRecommendations';

  try {
    print("正在呼叫後端 API: $apiUrl");
    
    // 2. 發送 GET 請求
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // 3. 解析回傳的資料
      final jsonResponse = json.decode(response.body);
      
      // 我們後端回傳的格式是 { "success": true, "data": [...] }
      if (jsonResponse['success'] == true) {
        final List data = jsonResponse['data'];
        print("成功取得 ${data.length} 筆資料");
        return data.map((e) => Product.fromJson(e)).toList();
      } else {
         throw Exception('API 回傳失敗: ${jsonResponse['error']}');
      }
    } else {
      throw Exception('HTTP 錯誤: ${response.statusCode}');
    }
  } catch (e) {
    print("連線發生錯誤: $e");
    // 發生錯誤時，回傳空陣列或拋出異常讓 UI 顯示
    throw Exception('無法連線到伺服器: $e');
  }
});