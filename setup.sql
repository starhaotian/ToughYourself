-- ToughYourself 云端同步建表脚本
-- 在 Supabase 项目的 SQL Editor 中执行一次即可。
-- 结构：每个用户一行，data 列存整份决策数据（JSONB）。

create table if not exists public.decisions (
  user_id uuid primary key references auth.users (id) on delete cascade,
  data jsonb not null default '{"decisions":[]}',
  updated_at timestamptz not null default now()
);

-- 行级安全：每个登录用户只能读写自己的那一行
alter table public.decisions enable row level security;

drop policy if exists "own data only" on public.decisions;
create policy "own data only"
  on public.decisions
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
