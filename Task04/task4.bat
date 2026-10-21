#!/bin/bash
chcp 65001
sqlite3 movies_rating.db < db_init.sql
echo "1. Найти все пары пользователей, оценивших один и тот же фильм. Устранить дубликаты, проверить отсутствие пар с самим собой. Для каждой пары должны быть указаны имена пользователей и название фильма. В списке оставить первые 100 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT DISTINCT u1.name AS user1, u2.name AS user2, m.title AS movie FROM ratings r1 JOIN ratings r2 ON r1.movie_id = r2.movie_id AND r1.user_id < r2.user_id JOIN users u1 ON r1.user_id = u1.id JOIN users u2 ON r2.user_id = u2.id JOIN movies m ON r1.movie_id = m.id LIMIT 100;"
echo " "
echo "2. Найти 10 самых свежих оценок от разных пользователей, вывести названия фильмов, имена пользователей, оценку, дату отзыва в формате ГГГГ-ММ-ДД."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH LatestRatings AS (SELECT u.name AS user_name, m.title AS movie_title, r.rating, r.timestamp, ROW_NUMBER() OVER(PARTITION BY r.user_id ORDER BY r.timestamp DESC) as rn FROM ratings r JOIN users u ON r.user_id = u.id JOIN movies m ON r.movie_id = m.id) SELECT user_name, movie_title, rating, strftime('%Y-%m-%d', timestamp, 'unixepoch') AS review_date FROM LatestRatings WHERE rn = 1 ORDER BY timestamp DESC LIMIT 10;"
echo " "
echo "3. Вывести в одном списке все фильмы с максимальным средним рейтингом и все фильмы с минимальным средним рейтингом. Общий список отсортировать по году выпуска и названию фильма. В колонке 'Рекомендуем' должно быть написано 'Да' или 'Нет'."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH MovieRatings AS (SELECT m.id, m.title, m.year, AVG(r.rating) as avg_rating FROM movies m JOIN ratings r ON m.id = r.movie_id GROUP BY m.id), MinMax AS (SELECT MAX(avg_rating) as max_r, MIN(avg_rating) as min_r FROM MovieRatings) SELECT mr.title, mr.year, CASE WHEN mr.avg_rating = (SELECT max_r FROM MinMax) THEN 'Да' WHEN mr.avg_rating = (SELECT min_r FROM MinMax) THEN 'Нет' END AS 'Рекомендуем' FROM MovieRatings mr JOIN MinMax mm ON mr.avg_rating = mm.max_r OR mr.avg_rating = mm.min_r ORDER BY mr.year, mr.title;"
echo " "
echo "4. Вычислить количество оценок и среднюю оценку, которую дали фильмам пользователи-женщины в период с 2010 по 2012 год."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT COUNT(r.id) AS rating_count, ROUND(AVG(r.rating), 2) AS avg_rating FROM ratings r JOIN users u ON r.user_id = u.id WHERE u.gender = 'female' AND strftime('%Y', datetime(r.timestamp, 'unixepoch')) BETWEEN '2010' AND '2012';"
echo " "
echo "5. Составить список фильмов с указанием их средней оценки и места в рейтинге по средней оценке. Полученный список отсортировать по году выпуска и названиям фильмов. В списке оставить первые 20 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH MovieRatings AS (SELECT m.id, m.title, m.year, AVG(r.rating) as avg_rating FROM movies m JOIN ratings r ON m.id = r.movie_id GROUP BY m.id), Ranked AS (SELECT title, year, avg_rating, RANK() OVER (ORDER BY avg_rating DESC) as rnk FROM MovieRatings) SELECT title, year, ROUND(avg_rating, 2) as avg_rating, rnk FROM Ranked ORDER BY year, title LIMIT 20;"
echo " "
echo "6. Вывести список из 10 последних зарегистрированных пользователей в формате 'Фамилия Имя|Дата регистрации' (сначала фамилия, потом имя)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT CASE WHEN instr(name, ' ') > 0 THEN substr(name, instr(name, ' ') + 1) || ' ' || substr(name, 1, instr(name, ' ') - 1) ELSE name END || '|' || register_date AS user_info FROM users ORDER BY register_date DESC LIMIT 10;"
echo " "
echo "7. С помощью рекурсивного CTE составить таблицу умножения для чисел от 1 до 10."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE Mult(a, b) AS (SELECT 1, 1 UNION ALL SELECT CASE WHEN b = 10 THEN a + 1 ELSE a END, CASE WHEN b = 10 THEN 1 ELSE b + 1 END FROM Mult WHERE a < 10 OR (a = 10 AND b < 10)) SELECT a || 'x' || b || '=' || (a * b) AS result FROM Mult ORDER BY a, b;"
echo " "
echo "8. С помощью рекурсивного CTE выделить все жанры фильмов, имеющиеся в таблице movies (каждый жанр в отдельной строке)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE GenreSplit(id, genre, rest) AS (SELECT id, CASE WHEN instr(genres, '|') > 0 THEN substr(genres, 1, instr(genres, '|') - 1) ELSE genres END, CASE WHEN instr(genres, '|') > 0 THEN substr(genres, instr(genres, '|') + 1) ELSE '' END FROM movies UNION ALL SELECT id, CASE WHEN instr(rest, '|') > 0 THEN substr(rest, 1, instr(rest, '|') - 1) ELSE rest END, CASE WHEN instr(rest, '|') > 0 THEN substr(rest, instr(rest, '|') + 1) ELSE '' END FROM GenreSplit WHERE rest != '') SELECT DISTINCT genre FROM GenreSplit WHERE genre != '' ORDER BY genre;"
echo " "