/* =========================================================================
   Supabase 雲端同步設定 / Cloud-sync configuration
   -------------------------------------------------------------------------
   填入你自己的 Supabase 專案資訊後，quiz.html 就能跨裝置同步進度。
   這兩個值「可以公開」：anon key 本來就是設計給瀏覽器端使用的金鑰，
   真正的安全由資料庫的 Row-Level Security + RPC 函式（見 supabase_setup.sql）把關。
   因此本檔可以安全地 commit 到 GitHub。

   取得方式：Supabase 後台 → Project Settings → API
     - Project URL        → 貼到 SUPABASE_URL
     - Project API keys → anon public → 貼到 SUPABASE_ANON_KEY

   若留著 YOUR_... 佔位字串，App 會自動退回「純本機模式」（不同步、不報錯）。
   ========================================================================= */
window.SUPABASE_URL = "https://ypljtppczuafiosgofhi.supabase.co";          // 例：https://abcdefgh.supabase.co
window.SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwbGp0cHBjenVhZmlvc2dvZmhpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI3ODQ4MDksImV4cCI6MjA5ODM2MDgwOX0.eO5yyt_m___rdmbiX51MlR1JWTArGIUwJ9mewWmpxPQ"; // 例：eyJhbGciOiJIUzI1NiIsInR5cCI6...
