-- ToughYourself 云端同步建表脚本
-- 在 Supabase 项目的 SQL Editor 中执行一次即可。
-- 结构：每个用户一行，data 列存整份决策数据（JSONB）。

create table if not exists public.decisions (
  user_id uuid primary key references auth.users (id) on delete cascade,
  data jsonb not null default '{"decisions":[]}',
  updated_at timestamptz not null default now(),
  constraint decisions_data_is_object check (jsonb_typeof(data) = 'object')
);

-- 新建项目不再自动向 Data API 暴露 SQL 创建的表，因此显式授权。
-- anon 无权访问；登录用户仍需通过下面的 RLS 所有权检查。
revoke all on table public.decisions from anon;
grant select, insert, update, delete on table public.decisions to authenticated;

-- 行级安全：每个登录用户只能读写自己的那一行。
alter table public.decisions enable row level security;

drop policy if exists "own data only" on public.decisions;
drop policy if exists "read own decisions" on public.decisions;
drop policy if exists "insert own decisions" on public.decisions;
drop policy if exists "update own decisions" on public.decisions;
drop policy if exists "delete own decisions" on public.decisions;

create policy "read own decisions"
  on public.decisions for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "insert own decisions"
  on public.decisions for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "update own decisions"
  on public.decisions for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "delete own decisions"
  on public.decisions for delete to authenticated
  using ((select auth.uid()) = user_id);
