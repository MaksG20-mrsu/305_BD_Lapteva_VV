import csv
import re

def extract_year(title):
    match = re.search(r'\((\d{4})\)\s*$', title)
    return match.group(1) if match else None

def escape_sql(value):
    if value is None:
        return 'NULL'
    return "'" + str(value).replace("'", "''") + "'"

sql_lines = []

sql_lines.append("DROP TABLE IF EXISTS users;")
sql_lines.append("DROP TABLE IF EXISTS movies;")
sql_lines.append("DROP TABLE IF EXISTS ratings;")
sql_lines.append("DROP TABLE IF EXISTS tags;")

sql_lines.append("""CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name TEXT,
    email TEXT,
    gender TEXT,
    register_date TEXT,
    occupation TEXT
);""")

sql_lines.append("""CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    title TEXT,
    year INTEGER,
    genres TEXT
);""")

sql_lines.append("""CREATE TABLE ratings (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    movie_id INTEGER,
    rating REAL,
    timestamp INTEGER
);""")

sql_lines.append("""CREATE TABLE tags (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    movie_id INTEGER,
    tag TEXT,
    timestamp INTEGER
);""")

with open('users.txt', 'r', encoding='utf-8') as f:
    for line in f:
        parts = line.strip().split('|')
        if len(parts) >= 6:
            id, name, email, gender, register_date, occupation = parts[:6]
            sql_lines.append(f"INSERT INTO users (id, name, email, gender, register_date, occupation) VALUES ({id}, {escape_sql(name)}, {escape_sql(email)}, {escape_sql(gender)}, {escape_sql(register_date)}, {escape_sql(occupation)});")

with open('movies.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        movie_id = row['movieId']
        title = row['title']
        genres = row['genres']
        year = extract_year(title)
        year_val = year if year else 'NULL'
        sql_lines.append(f"INSERT INTO movies (id, title, year, genres) VALUES ({movie_id}, {escape_sql(title)}, {year_val}, {escape_sql(genres)});")

with open('ratings.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    rating_id = 1
    for row in reader:
        user_id = row['userId']
        movie_id = row['movieId']
        rating = row['rating']
        timestamp = row['timestamp']
        sql_lines.append(f"INSERT INTO ratings (id, user_id, movie_id, rating, timestamp) VALUES ({rating_id}, {user_id}, {movie_id}, {rating}, {timestamp});")
        rating_id += 1

with open('tags.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    tag_id = 1
    for row in reader:
        user_id = row['userId']
        movie_id = row['movieId']
        tag = row['tag']
        timestamp = row['timestamp']
        sql_lines.append(f"INSERT INTO tags (id, user_id, movie_id, tag, timestamp) VALUES ({tag_id}, {user_id}, {movie_id}, {escape_sql(tag)}, {timestamp});")
        tag_id += 1

with open('db_init.sql', 'w', encoding='utf-8') as f:
    f.write('\n'.join(sql_lines) + '\n')

print("File db_init.sql successfully created!")