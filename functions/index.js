// functions/index.js

const functions = require("firebase-functions");
const axios = require("axios");
const crypto = require("crypto");

// --- 設定區 ---
// 開發階段設為 true，上線後拿到 Key 改為 false
const IS_MOCK_MODE = true; 

const SHOPEE_PARTNER_ID = process.env.SHOPEE_PARTNER_ID || "YOUR_PARTNER_ID";
const SHOPEE_KEY = process.env.SHOPEE_KEY || "YOUR_SECRET_KEY";

// --- 核心函式 ---
exports.getRecommendations = functions.https.onRequest(async (req, res) => {
  // 1. 設定 CORS (允許跨域請求)
  res.set("Access-Control-Allow-Origin", "*");
  
  // 2. ★ 優化重點：設定快取機制 (CDN 快取 10 分鐘，本地快取 5 分鐘)
  // 這行代碼能幫你省下巨額的 Firebase 運算費用
  res.set('Cache-Control', 'public, max-age=300, s-maxage=600');

  if (req.method === "OPTIONS") {
    res.set("Access-Control-Allow-Methods", "GET");
    res.set("Access-Control-Allow-Headers", "Content-Type");
    res.status(204).send("");
    return;
  }

  try {
    const { keyword = "女裝", limit = 20 } = req.query;
    let items = [];

    if (IS_MOCK_MODE) {
      console.log("⚠️ 模擬模式：回傳假資料");
      items = generateMockData(limit);
    } else {
      console.log("🚀 真實模式：呼叫蝦皮 API");
      items = await fetchFromShopee(keyword, limit);
    }

    res.json({
      success: true,
      data: items,
      source: IS_MOCK_MODE ? "mock_server" : "shopee_api"
    });

  } catch (error) {
    console.error("API Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// --- 輔助函式：產生模擬資料 ---
function generateMockData(count) {
  const mockItems = [];
  const fakeImages = [
    "https://images.pexels.com/photos/1036623/pexels-photo-1036623.jpeg?auto=compress&cs=tinysrgb&w=600",
    "https://images.pexels.com/photos/157675/fashion-men-s-individuality-black-and-white-157675.jpeg?auto=compress&cs=tinysrgb&w=600",
    "https://images.pexels.com/photos/1639729/pexels-photo-1639729.jpeg?auto=compress&cs=tinysrgb&w=600",
    "https://images.pexels.com/photos/1454171/pexels-photo-1454171.jpeg?auto=compress&cs=tinysrgb&w=600",
    "https://images.pexels.com/photos/1031955/pexels-photo-1031955.jpeg?auto=compress&cs=tinysrgb&w=600"
  ];

  for (let i = 0; i < count; i++) {
    const randomImg = fakeImages[Math.floor(Math.random() * fakeImages.length)];
    // 注意：這裡 deepLink 暫時用網頁版連結，前端會負責轉成 App 開啟
    mockItems.push({
      id: `mock_${i}_${Date.now()}`,
      name: `[熱銷] 2025 春季新款風格穿搭 #${i + 1}`,
      price: Math.floor(Math.random() * 1000) + 199,
      imageUrl: randomImg,
      shopUrl: "https://shopee.tw/universal-link/product/123456/789012" 
    });
  }
  return mockItems;
}

// --- 輔助函式：呼叫蝦皮 API (預留區) ---
async function fetchFromShopee(keyword, limit) {
  // 等拿到 Key 後，我們再來填寫這一段
  return [];
}