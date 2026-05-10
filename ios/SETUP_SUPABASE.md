# Supabase Setup — Couple Mode (5 minutes)

## Step 1 — Create free project
1. Go to **supabase.com** → Sign up (free)
2. New Project → choose any name → Set a password → Create

## Step 2 — Run this SQL
In your Supabase project → SQL Editor → paste and run:

```sql
-- Couple rooms table
CREATE TABLE couple_rooms (
  id         UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  code       TEXT UNIQUE NOT NULL,
  owner_id   TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sync events table
CREATE TABLE sync_events (
  id          UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  room_code   TEXT NOT NULL REFERENCES couple_rooms(code),
  event_type  TEXT NOT NULL,
  payload     JSONB NOT NULL DEFAULT '{}',
  sender_id   TEXT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Realtime for sync_events
ALTER TABLE sync_events REPLICA IDENTITY FULL;
ALTER PUBLICATION supabase_realtime ADD TABLE sync_events;

-- Row Level Security (allow all for now)
ALTER TABLE couple_rooms  ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_events   ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all" ON couple_rooms  FOR ALL USING (true);
CREATE POLICY "Allow all" ON sync_events   FOR ALL USING (true);
```

## Step 3 — Get your keys
Settings → API → copy:
- Project URL
- anon (public) key

## Step 4 — Add to app
Open `lib/core/constants/app_constants.dart` and add:

```dart
static const String supabaseUrl    = 'YOUR_PROJECT_URL';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

## Step 5 — Initialize in main.dart
Already done! The app calls `Supabase.initialize()` in bootstrap.

## Done ✅
The Couple Mode will now work — both devices sync in real time.
