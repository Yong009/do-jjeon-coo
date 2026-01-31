DROP TABLE IF EXISTS store;

CREATE TABLE store (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    latitude REAL,
    longitude REAL,
    link TEXT,
    UNIQUE(name, address)
);
