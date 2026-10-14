create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '', birth_date date, height_cm numeric check (height_cm > 0),
  initial_weight_kg numeric check (initial_weight_kg > 0), target_weight_kg numeric check (target_weight_kg > 0),
  goal_type text not null default 'emagrecimento' check (goal_type in ('emagrecimento','manutencao','ganho')),
  daily_calorie_goal integer check (daily_calorie_goal > 0), created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.weight_entries (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  entry_date date not null, weight_kg numeric not null check (weight_kg > 0 and weight_kg < 500), notes text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique(user_id, entry_date)
);
create table if not exists public.meals (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  meal_date date not null, meal_time time, meal_type text not null, name text not null, notes text,
  calories integer check (calories >= 0), protein_g numeric check (protein_g >= 0), carbs_g numeric check (carbs_g >= 0), fat_g numeric check (fat_g >= 0),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.activity_entries (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  activity_date date not null, activity_time time, activity_type text not null, activity_name text not null,
  duration_minutes numeric not null check (duration_minutes > 0), intensity text not null check (intensity in ('leve','moderada','intensa')),
  met_value numeric, reference_weight_kg numeric, estimated_calories_gross integer, estimated_calories_net integer, calories_source text, notes text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index if not exists weight_entries_user_date_idx on public.weight_entries(user_id, entry_date desc);
create index if not exists meals_user_date_idx on public.meals(user_id, meal_date);
create index if not exists activities_user_date_idx on public.activity_entries(user_id, activity_date);

alter table public.profiles enable row level security;
alter table public.weight_entries enable row level security;
alter table public.meals enable row level security;
alter table public.activity_entries enable row level security;

drop policy if exists "Users manage own profiles" on public.profiles;
create policy "Users manage own profiles" on public.profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);

do $$ declare table_name text; begin
  for table_name in select unnest(array['weight_entries','meals','activity_entries']) loop
    execute format('drop policy if exists "Users manage own %s" on public.%I', table_name, table_name);
    execute format('create policy "Users manage own %s" on public.%I for all using (auth.uid() = user_id) with check (auth.uid() = user_id)', table_name, table_name);
  end loop;
end $$;

create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path = public as $$ begin insert into public.profiles (id, name) values (new.id, coalesce(new.raw_user_meta_data->>'name', '')); return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
