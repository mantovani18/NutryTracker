create table if not exists public.feed_posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  author_name text not null default 'Usuário NutriTrack',
  content text not null check (char_length(content) between 1 and 500),
  weight_kg numeric check (weight_kg > 0 and weight_kg < 500),
  created_at timestamptz not null default now()
);

create index if not exists feed_posts_created_at_idx on public.feed_posts(created_at desc);
alter table public.feed_posts enable row level security;

drop policy if exists "Anyone authenticated can read feed" on public.feed_posts;
create policy "Anyone authenticated can read feed" on public.feed_posts
  for select using (auth.uid() is not null);

drop policy if exists "Users create own feed posts" on public.feed_posts;
create policy "Users create own feed posts" on public.feed_posts
  for insert with check (auth.uid() = user_id);

drop policy if exists "Users update own feed posts" on public.feed_posts;
create policy "Users update own feed posts" on public.feed_posts
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "Users delete own feed posts" on public.feed_posts;
create policy "Users delete own feed posts" on public.feed_posts
  for delete using (auth.uid() = user_id);
