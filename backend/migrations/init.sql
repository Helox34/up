-- posts table
CREATE TABLE IF NOT EXISTS posts (
  id TEXT PRIMARY KEY,
  author TEXT,
  content TEXT,
  created_at INTEGER
);

-- products table
CREATE TABLE IF NOT EXISTS products (
  id TEXT PRIMARY KEY,
  name TEXT,
  description TEXT,
  price REAL
);

-- achievements table
CREATE TABLE IF NOT EXISTS achievements (
  id TEXT PRIMARY KEY,
  title TEXT,
  level TEXT, -- bronze,silver,gold,diamond
  user_id TEXT,
  awarded_at INTEGER
);

-- challenges table
CREATE TABLE IF NOT EXISTS challenges (
  id TEXT PRIMARY KEY,
  title TEXT,
  description TEXT,
  start_at INTEGER,
  end_at INTEGER
);
