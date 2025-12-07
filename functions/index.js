// functions/index.js

const functions = require("firebase-functions");
const axios = require("axios");
const crypto = require("crypto"); // 用於加密簽名

// --- 設定區 (Configuration) ---
// 1. 如果你還沒有蝦皮 Key，請保持 IS_MOCK_MODE = true
// 2. 拿到 Key 後，改成 false，並在 Firebase Config 設定 ID 和 Key
const IS_MOCK_MODE = true; 

// 這裡之後會從環境變數讀取 (不要直接寫死在程式碼裡上傳 git)
const SHOPEE_PARTNER_ID = process.env.SHOPEE_PARTNER_ID || "YOUR_PARTNER_ID";
const SHOPEE_KEY = process.env.SHOPEE_KEY || "YOUR_SECRET_KEY";
const SHOPEE_HOST = "https://partner.shopeemobile.com"; // 或測試環境 URL

// --- 核心函式: 獲取推薦商品 ---
exports.getRecommendations = functions.https.onRequest(async (req, res) => {
  // 解決 CORS 問題 (允許你的 App 呼叫這個 API)
  res.set("Access-Control-Allow-Origin", "*");
  
  if (req.method === "OPTIONS") {
    // 處理 Preflight 請求
    res.set("Access-Control-Allow-Methods", "GET");
    res.set("Access-Control-Allow-Headers", "Content-Type");
    res.status(204).send("");
    return;
  }

  try {
    const { keyword = "女裝", limit = 20 } = req.query;

    let items = [];

    if (IS_MOCK_MODE) {
      console.log("⚠️ 啟動模擬模式：回傳假資料");
      items = generateMockData(limit);
    } else {
      console.log("🚀 啟動真實模式：呼叫蝦皮 API");
      items = await fetchFromShopee(keyword, limit);
    }

    // 成功回傳 JSON
    res.json({
      success: true,
      data: items,
      source: IS_MOCK_MODE ? "mock_server" : "shopee_api"
    });

  } catch (error) {
    console.error("API Error:", error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// --- 輔助函式: 產生模擬資料 ---
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
    mockItems.push({
      id: `mock_${i}_${Date.now()}`,
      name: `[Server推薦] 2025 春季新款 #${i + 1} (熱銷中騙妳的)`,
      price: Math.floor(Math.random() * 1000) + 100,
      imageUrl: randomImg,
      shopUrl: "https://shopee.tw"
    });
  }
  return mockItems;
}

// --- 輔助函式: 呼叫蝦皮 API (預留區) ---
async function fetchFromShopee(keyword, limit) {
  // 這裡需要實作蝦皮複雜的 V2 簽名邏輯
  // 1. Generate Timestamp
  const timestamp = Math.floor(Date.now() / 1000);
  const path = "/api/v2/item/search"; // 假設的路徑
  
  // 2. Generate Base String & Sign
  // 蝦皮簽名公式: hmac_sha256(partner_id + path + timestamp + body, secret)
  const baseString = `${SHOPEE_PARTNER_ID}${path}${timestamp}`; 
  const sign = crypto.createHmac("sha256", SHOPEE_KEY).update(baseString).digest("hex");

  // 3. Call API
  // const response = await axios.get(...) 
  // 為了防止現在報錯，先回傳空陣列
  return [];
}