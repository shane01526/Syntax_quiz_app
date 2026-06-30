# Core Syntax 題庫測驗 — 部署說明 / Deployment Guide

一個純靜態的雙語題庫測驗站：`index.html`（導覽）＋ `quiz.html`（測驗 App）＋ `questions.json`（282 題）＋ `Ch01–Ch10` 詳解 HTML。
無後端、無建置步驟，可直接部署到 **Render Static Site**（免費）。

---

## 1. 檔案角色

| 檔案 | 是否部署 | 說明 |
|---|---|---|
| `quiz.html` | ✅ | 測驗 App（自包含 HTML/CSS/JS） |
| `questions.json` | ✅ | 題庫（10 章 × 24–30 題，共 282 題） |
| `index.html` | ✅ | 全書導覽頁（含題庫入口卡片） |
| `Ch01`–`Ch10` `*.html` | ✅ | 各章雙語詳解（建議閱讀連結指向這些檔的小節錨點） |
| `render.yaml` | ✅ | Render Blueprint 設定 |
| `*.pdf`、`_txt/` | ❌ | **被 `.gitignore` 排除**：受版權保護的原文與萃取文字，不要公開上傳 |

> 重要：`.gitignore` 已排除所有 PDF 與 `_txt/`。公開部署只會包含你自己撰寫的摘要詳解、題庫與 App。

---

## 2. 部署到 Render（建議：Blueprint）

### 前置
- 一個 GitHub 帳號與一個 Render 帳號（https://render.com，可用 GitHub 登入）。

### 步驟
1. **建立 git repo 並推上 GitHub**（在本資料夾 `Core_Syntax/` 內）：
   ```bash
   git init
   git add quiz.html questions.json index.html Ch*.html render.yaml .gitignore README_DEPLOY.md
   git commit -m "Add Core Syntax quiz app + chapter guides"
   git branch -M main
   git remote add origin https://github.com/<你的帳號>/core-syntax-quiz.git
   git push -u origin main
   ```
   （`git status` 應該看不到任何 `.pdf` 或 `_txt/`，代表 `.gitignore` 生效。）

2. **在 Render 建立服務**：
   - 後台 → **New +** → **Blueprint** → 選剛剛的 GitHub repo → Render 讀 `render.yaml` 自動建立名為 `core-syntax-quiz` 的 Static Site。
   - 或 **New +** → **Static Site** → 手動設定：**Build Command** 留空、**Publish Directory** 填 `.`。

3. 部署完成後得到網址，例如 `https://core-syntax-quiz.onrender.com`，打開即用。

4. **更新內容**：之後改題只需編輯 `questions.json`、`git push`，Render 會自動重新部署。

---

## 3. 本機預覽

HTTPS／http server 下沒有 CORS 問題，最穩定：
```bash
cd Core_Syntax
python -m http.server 8000
# 瀏覽器開 http://localhost:8000/quiz.html
```

直接雙擊 `quiz.html`（`file://`）也可用——若瀏覽器擋住自動載入題庫，App 會顯示「手動選擇 questions.json」的後備選項。

---

## 4. 資料持久化

- 筆記、作答紀錄、收藏、設定都存在瀏覽器 **localStorage**（命名空間 `coreSyntaxQuiz`），重開頁面仍在。
- localStorage 綁定「網域 + 瀏覽器」：本機 `file://` 與線上網址、不同瀏覽器之間**不共用**。
- 換裝置或換網域時，用 App 內 **「⬇ 匯出筆記/紀錄 JSON」** 備份，再到新環境 **「⬆ 匯入備份」** 還原（可選合併或取代）。
- 清除瀏覽器資料會刪掉 localStorage，請先匯出備份。

---

## 5. 跨裝置雲端同步（Supabase）— 可選但建議

預設進度只存在「本機瀏覽器」。要讓任何裝置點進去都同步，加一個免費的 Supabase 雲端資料庫即可（App 本身仍是純靜態，不需自架伺服器）。

### 一次性設定（約 5 分鐘）
1. 到 https://supabase.com 用 GitHub 登入 → **New project**（隨意命名、選個區域、設一組資料庫密碼）。
2. 專案開好後，左側 **SQL Editor** → **New query** → 把本資料夾的 **`supabase_setup.sql`** 全部貼上 → **Run**。（會建立 `quiz_progress` 表與 `quiz_pull` / `quiz_push` 兩個函式，並鎖好權限。）
3. 左側 **Project Settings → API**，複製兩個值，貼進本資料夾的 **`config.js`**：
   - **Project URL** → `window.SUPABASE_URL`
   - **anon public** key → `window.SUPABASE_ANON_KEY`
4. `git add config.js && git commit -m "Enable cloud sync" && git push`，Render 自動重新部署。

> `config.js` 裡的 anon key 是「設計給瀏覽器公開」的金鑰，可放心 commit。真正的安全由資料庫的 RLS（關閉直接存取）＋ 只認「完整同步碼」的 RPC 函式把關。

### 使用方式
- 打開 App → 篩選列最下方「☁ 雲端同步」→ 輸入一組**只有你知道的同步碼**（≥6 字、建議一句別人猜不到的密語）→「連結同步」。
- 之後筆記／作答／收藏會自動上雲；在**任何裝置**輸入**同一組同步碼**即可拉下並合併進度。
- 合併規則：**逐筆、時間戳較新的版本獲勝**，所以兩台裝置各改各的不會互相蓋掉。
- 離線時照常運作（仍寫本機），恢復連線後自動補同步。

### 安全須知（同步碼模式的本質）
- 沒有真正的帳號密碼：**任何知道你完整同步碼的人，都能讀寫你的進度**。
- 個人複習用足夠，但請務必設一組夠長、別人猜不到的密語；不要用 `1234`、自己的名字等。
- 若 `config.js` 留著 `YOUR_...` 佔位字串，App 會自動退回「純本機模式」，不報錯。

---

## 6. 只想公開 App、不公開詳解？（可選）

若不想把 `Ch01–Ch10` 詳解 HTML 一起公開：
1. 把 `quiz.html`、`questions.json`、`index.html` 放進一個 `public/` 子資料夾；
2. `render.yaml` 的 `staticPublishPath` 改成 `public`；
3. 在 `quiz.html` 隱藏「📖 開啟詳解」按鈕（或讓它只在本機可用）。
預設不需要這麼做——詳解屬個人摘要改寫，風險低。
