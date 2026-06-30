-- =====================================================================
-- Core Syntax 題庫測驗 — Supabase 雲端同步建置 SQL
-- ---------------------------------------------------------------------
-- 用法：Supabase 後台 → SQL Editor → New query → 貼上全部 → Run。
-- 安全模型（同步碼模式）：
--   * 進度存在 quiz_progress 一張表，主鍵是「同步碼的 SHA-256 雜湊」。
--   * 開啟 RLS 但「不給任何直接存取政策」→ 前端無法用 anon key 直接讀寫整張表，
--     也無法列舉（enumerate）有哪些同步碼存在。
--   * 只透過兩個 SECURITY DEFINER 的 RPC 函式存取：必須提供「完整同步碼」
--     才能讀/寫對應那一列。原始同步碼永不入庫，資料庫只看得到雜湊。
--   * 取捨：任何「知道你完整同步碼」的人都能讀寫你的進度（無真正帳號）。
--     個人複習用足夠，請設一組夠長、別人猜不到的密語。
-- =====================================================================

-- 需要 digest()（雜湊）函式。Supabase 會把 pgcrypto 裝在 extensions schema，
-- 所以下面一律用 extensions.digest(...) 完整限定，避免 search_path 找不到。
create extension if not exists pgcrypto with schema extensions;

-- 進度表：一列 = 一組同步碼的全部進度
create table if not exists public.quiz_progress (
  code_hash  text primary key,                       -- sha256(sync code)
  data       jsonb       not null default '{}'::jsonb, -- {notes, answers, starred, settings, *_ts}
  updated_at timestamptz not null default now()
);

-- 鎖死：開 RLS，且不建立任何 policy → anon 角色無法直接 select/insert/update
alter table public.quiz_progress enable row level security;
revoke all on public.quiz_progress from anon, authenticated;

-- ---------------------------------------------------------------------
-- 讀取：給完整同步碼，回傳該列 data（找不到回傳空物件）
-- ---------------------------------------------------------------------
create or replace function public.quiz_pull(p_code text)
returns jsonb
language sql
security definer
set search_path = public, extensions
as $$
  select coalesce(
    (select data from public.quiz_progress
       where code_hash = encode(extensions.digest(p_code, 'sha256'), 'hex')),
    '{}'::jsonb);
$$;

-- ---------------------------------------------------------------------
-- 寫入（upsert）：給完整同步碼 + 整包 data，覆蓋該列並回傳存好的 data
-- 前端負責「逐筆 last-write-wins 合併」後，再把完整結果丟進來覆寫。
-- ---------------------------------------------------------------------
create or replace function public.quiz_push(p_code text, p_data jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  h text := encode(extensions.digest(p_code, 'sha256'), 'hex');
begin
  insert into public.quiz_progress as q (code_hash, data, updated_at)
  values (h, p_data, now())
  on conflict (code_hash)
  do update set data = excluded.data, updated_at = now();
  return p_data;
end;
$$;

-- 只允許用 anon / authenticated 角色「執行這兩個函式」，不開放表本身
revoke all on function public.quiz_pull(text)  from public;
revoke all on function public.quiz_push(text, jsonb) from public;
grant execute on function public.quiz_pull(text)  to anon, authenticated;
grant execute on function public.quiz_push(text, jsonb) to anon, authenticated;

-- 完成。回到 quiz.html，輸入任一組同步碼即可開始跨裝置同步。
