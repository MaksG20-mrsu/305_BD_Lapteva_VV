-- ==========================================
-- Добавление новых данных без привязки к конкретным ID
-- ==========================================

-- 1. Добавление 5 новых пользователей (дата регистрации проставится автоматически по системному времени)
-- Использованы реальные данные из списка группы (Лаптева В.В. и соседи №6, 8, 9, 10)

INSERT INTO users (name, email, gender, occupation_id) 
SELECT 'Лаптева Виктория Викторовна', 'vikalapteva20066@gmail.com', 'female', id FROM occupations WHERE name = 'student' LIMIT 1;

INSERT INTO users (name, email, gender, occupation_id) 
SELECT 'Курков Никита Геннадьевич', 'kurkov404@gmail.com', 'male', id FROM occupations WHERE name = 'student' LIMIT 1;

INSERT INTO users (name, email, gender, occupation_id) 
SELECT 'Лушаев Александр Алексеевич', 'alexandrlushaevsaransk@gmail.com', 'male', id FROM occupations WHERE name = 'student' LIMIT 1;

INSERT INTO users (name, email, gender, occupation_id) 
SELECT 'Михайлов Александр Владимирович', 'Alexmihaylov2006@mail.ru', 'male', id FROM occupations WHERE name = 'student' LIMIT 1;

INSERT INTO users (name, email, gender, occupation_id) 
SELECT 'Моисеева Дарья Владимировна', 'dari_yunkim@mail.ru', 'female', id FROM occupations WHERE name = 'student' LIMIT 1;

-- 2. Добавление 3 новых фильмов разных жанров
INSERT INTO movies (title, year) VALUES ('Начало', 2010);
INSERT INTO movies (title, year) VALUES ('Интерстеллар', 2014);
INSERT INTO movies (title, year) VALUES ('Дюна', 2021);

-- 3. Связывание добавленных фильмов с жанрами через подзапросы (не зависит от ID)
INSERT INTO movie_genres (movie_id, genre_id) 
SELECT m.id, g.id FROM movies m, genres g WHERE m.title = 'Начало' AND g.name = 'Sci-Fi';

INSERT INTO movie_genres (movie_id, genre_id) 
SELECT m.id, g.id FROM movies m, genres g WHERE m.title = 'Начало' AND g.name = 'Action';

INSERT INTO movie_genres (movie_id, genre_id) 
SELECT m.id, g.id FROM movies m, genres g WHERE m.title = 'Интерстеллар' AND g.name = 'Sci-Fi';

INSERT INTO movie_genres (movie_id, genre_id) 
SELECT m.id, g.id FROM movies m, genres g WHERE m.title = 'Интерстеллар' AND g.name = 'Drama';

INSERT INTO movie_genres (movie_id, genre_id) 
SELECT m.id, g.id FROM movies m, genres g WHERE m.title = 'Дюна' AND g.name = 'Sci-Fi';

INSERT INTO movie_genres (movie_id, genre_id) 
SELECT m.id, g.id FROM movies m, genres g WHERE m.title = 'Дюна' AND g.name = 'Adventure';

-- 4. Добавление 3 новых отзывов от себя о добавленных фильмах
-- Оценка от 0 до 5, время проставляется автоматически. 
-- ВАЖНО: email должен точно совпадать с тем, что указан при добавлении пользователя выше!

INSERT INTO ratings (user_id, movie_id, rating)
SELECT u.id, m.id, 5.0 FROM users u, movies m WHERE u.email = 'vikalapteva20066@gmail.com' AND m.title = 'Начало';

INSERT INTO ratings (user_id, movie_id, rating)
SELECT u.id, m.id, 4.5 FROM users u, movies m WHERE u.email = 'vikalapteva20066@gmail.com' AND m.title = 'Интерстеллар';

INSERT INTO ratings (user_id, movie_id, rating)
SELECT u.id, m.id, 4.0 FROM users u, movies m WHERE u.email = 'vikalapteva20066@gmail.com' AND m.title = 'Дюна';