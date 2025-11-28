-- ⚠️ SCHEMA INI SUDAH ADA DI SUPABASE (notes & profiles)
-- File ini hanya untuk dokumentasi
-- Tabel yang digunakan: notes (bukan tasks)

-- Sudah dibuat di Supabase:
-- 1) Enum untuk priority dan status
-- create type priority_enum as enum ('low', 'medium', 'high');
-- create type note_status_enum as enum ('ongoing', 'missed', 'completed');

-- 2) Tabel notes
-- create table public.notes (
--   id uuid primary key default gen_random_uuid(),
--   user_id uuid not null references auth.users(id) on delete cascade,
--   title text not null,
--   description text,
--   priority priority_enum not null default 'medium',
--   status note_status_enum not null default 'ongoing',
--   duration_minutes integer not null,
--   steps text[] default '{}',
--   start_date date,
--   due_date date,
--   created_at timestamptz default now(),
--   updated_at timestamptz default now()
-- );

-- 3) Tabel profiles
-- create table public.profiles (
--   id uuid primary key references auth.users(id) on delete cascade,
--   username text unique,
--   age integer,
--   photo_url text,
--   created_at timestamptz default now()
-- );

-- ✅ NOTES:
-- - App sudah terintegrasi dengan tabel 'notes' (bukan 'tasks')
-- - Status: 'ongoing', 'completed', 'missed' (enum string)
-- - Priority: 'low', 'medium', 'high' (enum string)
-- - ID: auto-generated UUID oleh Supabase
