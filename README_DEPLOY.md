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

## 5. 只想公開 App、不公開詳解？（可選）

若不想把 `Ch01–Ch10` 詳解 HTML 一起公開：
1. 把 `quiz.html`、`questions.json`、`index.html` 放進一個 `public/` 子資料夾；
2. `render.yaml` 的 `staticPublishPath` 改成 `public`；
3. 在 `quiz.html` 隱藏「📖 開啟詳解」按鈕（或讓它只在本機可用）。
預設不需要這麼做——詳解屬個人摘要改寫，風險低。
