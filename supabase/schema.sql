-- Habilita funciones de generacion de UUID si aun no estan disponibles
create extension if not exists "pgcrypto";

-- Tabla de perfiles enlazada con usuarios de autenticacion
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Usuarios pueden ver su propio perfil"
  on public.profiles
  for select
  using (auth.uid() = id);

create policy "Usuarios pueden crear su propio perfil"
  on public.profiles
  for insert
  with check (auth.uid() = id);

create policy "Usuarios pueden actualizar su propio perfil"
  on public.profiles
  for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Trigger para crear un perfil automaticamente al registrar un usuario
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id)
  values (new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Tabla para almacenar favoritos del usuario
create table if not exists public.favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  movie_id integer not null,
  movie_title text not null,
  poster_url text,
  created_at timestamptz not null default now()
);

alter table public.favorites enable row level security;

create policy "Usuarios pueden ver sus favoritos"
  on public.favorites
  for select
  using (auth.uid() = user_id);

create policy "Usuarios pueden agregar favoritos"
  on public.favorites
  for insert
  with check (auth.uid() = user_id);

create policy "Usuarios pueden eliminar sus favoritos"
  on public.favorites
  for delete
  using (auth.uid() = user_id);
