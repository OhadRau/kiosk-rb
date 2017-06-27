CREATE TABLE codes (
  code TEXT UNIQUE PRIMARY KEY
);

CREATE TABLE users (
  firstname     TEXT,
  lastname      TEXT,
  email         TEXT UNIQUE PRIMARY KEY NOT NULL,
  passwordHash  TEXT NOT NULL
);

CREATE TABLE tickets (
  id INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE NOT NULL,

  name TEXT NOT NULL,
  asset_tag TEXT,
  assigned TEXT NOT NULL,
  body TEXT NOT NULL,
  time DATETIME NOT NULL,

  closed BOOLEAN,
  title TEXT,
  resolution TEXT,

  FOREIGN KEY(assigned) REFERENCES users(email)
);
