create table if not exists public.user_foods (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  name_normalized text not null,
  calories_per_100g numeric not null check (calories_per_100g >= 0),
  created_at timestamptz not null default now(),
  unique(user_id, name_normalized)
);

create index if not exists user_foods_user_name_idx on public.user_foods(user_id, name_normalized);
alter table public.user_foods enable row level security;
drop policy if exists "Users manage own foods" on public.user_foods;
create policy "Users manage own foods" on public.user_foods
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
