
-- ==============================================
-- IMDb Movies Analysis using SQL - Umesh Patil
-- ==============================================

-- 🔹 Segment 1: Database Info

CREATE DATABASE imdb_movies_db;
USE imdb_movies_db;

CREATE TABLE movie (
  id INT PRIMARY KEY,
  title VARCHAR(255),
  year INT,
  date_published DATE,
  duration INT,
  country VARCHAR(100),
  worldwide_gross_income BIGINT,
  languages VARCHAR(255),
  production_company VARCHAR(255)
);

CREATE TABLE genre (
  movie_id INT,
  genre VARCHAR(100),
  FOREIGN KEY (movie_id) REFERENCES movie(id)
);

CREATE TABLE ratings (
  movie_id INT PRIMARY KEY,
  avg_rating FLOAT,
  total_votes INT,
  median_rating FLOAT,
  FOREIGN KEY (movie_id) REFERENCES movie(id)
);

CREATE TABLE names (
  id INT PRIMARY KEY,
  name VARCHAR(255),
  height INT,
  date_of_birth DATE,
  known_for_movies TEXT
);

CREATE TABLE role_mapping (
  movie_id INT,
  name_id INT,
  category VARCHAR(100),
  FOREIGN KEY (movie_id) REFERENCES movie(id),
  FOREIGN KEY (name_id) REFERENCES names(id)
);

CREATE TABLE director_mapping (
  movie_id INT,
  name_id INT,
  FOREIGN KEY (movie_id) REFERENCES movie(id),
  FOREIGN KEY (name_id) REFERENCES names(id)
);



INSERT INTO movie (id, title, year, date_published, duration, country, worldwide_gross_income, languages, production_company) VALUES
(1, 'The Dark Knight', 2008, '2008-07-18', 152, 'USA', 1004558444, 'English', 'Warner Bros'),
(2, 'Dangal', 2016, '2016-12-23', 161, 'India', 3010000000, 'Hindi', 'Aamir Khan Productions'),
(3, 'Parasite', 2019, '2019-05-30', 132, 'South Korea', 258800000, 'Korean', 'Barunson E&A'),
(4, '3 Idiots', 2009, '2009-12-25', 170, 'India', 395000000, 'Hindi', 'Vinod Chopra Films'),
(5, 'Inception', 2010, '2010-07-16', 148, 'USA', 829895144, 'English', 'Legendary Pictures');

INSERT INTO genre (movie_id, genre) VALUES
(1, 'Action'),
(1, 'Drama'),
(2, 'Biography'),
(3, 'Thriller'),
(4, 'Comedy'),
(5, 'Sci-Fi'),
(5, 'Thriller');


INSERT INTO ratings (movie_id, avg_rating, total_votes, median_rating) VALUES
(1, 9.0, 2300000, 9.0),
(2, 8.4, 200000, 8.0),
(3, 8.6, 700000, 9.0),
(4, 8.4, 400000, 8.0),
(5, 8.8, 2200000, 9.0);

INSERT INTO names (id, name, height, date_of_birth, known_for_movies) VALUES
(101, 'Christopher Nolan', 181, '1970-07-30', 'Inception, Interstellar, Tenet'),
(102, 'Aamir Khan', 168, '1965-03-14', 'Dangal, 3 Idiots'),
(103, 'Bong Joon-ho', 170, '1969-09-14', 'Parasite, Snowpiercer'),
(104, 'Rajkumar Hirani', 175, '1962-11-20', '3 Idiots, PK'),
(105, 'Leonardo DiCaprio', 183, '1974-11-11', 'Inception, Titanic');

INSERT INTO role_mapping (movie_id, name_id, category) VALUES
(1, 105, 'actor'),
(2, 102, 'actor'),
(3, 103, 'director'),
(4, 102, 'actor'),
(5, 105, 'actor');


INSERT INTO director_mapping (movie_id, name_id) VALUES
(1, 101),
(2, 102),
(3, 103),
(4, 104),
(5, 101);


-- 🔹 Segment 2: Movie Release Trends

-- 1. Total movies released each year
SELECT year, COUNT(*) AS total_movies
FROM movie
GROUP BY year
ORDER BY year;

-- 2. Month-wise release trend
SELECT MONTH(date_published) AS release_month, COUNT(*) AS total_movies
FROM movie
GROUP BY release_month
ORDER BY release_month;

-- 3. Movies produced in USA or India in 2019
SELECT COUNT(*) AS total_movies
FROM movie
WHERE country IN ('USA', 'India') AND year = 2019;

-- 🔹 Segment 3: Production Statistics & Genre Analysis

-- 4. Unique genres
SELECT DISTINCT genre
FROM genre;

-- 5. Genre with most movies
SELECT genre, COUNT(*) AS total
FROM genre
GROUP BY genre
ORDER BY total DESC
LIMIT 1;

-- 6. Movies with only one genre
SELECT movie_id
FROM genre
GROUP BY movie_id
HAVING COUNT(genre) = 1;

-- 7. Average duration per genre
SELECT g.genre, ROUND(AVG(m.duration), 2) AS avg_duration
FROM genre g
JOIN movie m ON g.movie_id = m.id
GROUP BY g.genre;

-- 8. Rank of 'Thriller' genre by movie count
SELECT genre, COUNT(*) AS total_movies,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS genre_rank
FROM genre
GROUP BY genre;

-- 🔹 Segment 4: Ratings Analysis

-- 9. Min and max values from ratings table
SELECT 
  MIN(avg_rating) AS min_avg_rating,
  MAX(avg_rating) AS max_avg_rating,
  MIN(total_votes) AS min_votes,
  MAX(total_votes) AS max_votes,
  MIN(median_rating) AS min_median_rating,
  MAX(median_rating) AS max_median_rating
FROM ratings;

-- 10. Top 10 movies by avg_rating
SELECT m.title, r.avg_rating
FROM movie m
JOIN ratings r ON m.id = r.movie_id
ORDER BY r.avg_rating DESC
LIMIT 10;

-- 11. Median rating group count
SELECT median_rating, COUNT(*) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY median_rating DESC;

-- 12. Production house with most hits (avg_rating > 8)
SELECT m.production_company, COUNT(*) AS hit_movies
FROM movie m
JOIN ratings r ON m.id = r.movie_id
WHERE r.avg_rating > 8
GROUP BY m.production_company
ORDER BY hit_movies DESC
LIMIT 1;

-- 13. Movies in USA during March 2017 with >1000 votes
SELECT g.genre, COUNT(*) AS total
FROM movie m
JOIN ratings r ON m.id = r.movie_id
JOIN genre g ON m.id = g.movie_id
WHERE MONTH(m.date_published) = 3
  AND YEAR(m.date_published) = 2017
  AND m.country = 'USA'
  AND r.total_votes > 1000
GROUP BY g.genre;

-- 14. Movies starting with 'The' and rating > 8
SELECT m.title, g.genre, r.avg_rating
FROM movie m
JOIN genre g ON m.id = g.movie_id
JOIN ratings r ON m.id = r.movie_id
WHERE m.title LIKE 'The %' AND r.avg_rating > 8;

-- 🔹 Segment 5: Crew Analysis

-- 15. NULL columns in names table
SELECT 'name' AS column_name, COUNT(*) FROM names WHERE name IS NULL
UNION
SELECT 'height', COUNT(*) FROM names WHERE height IS NULL
UNION
SELECT 'date_of_birth', COUNT(*) FROM names WHERE date_of_birth IS NULL
UNION
SELECT 'known_for_movies', COUNT(*) FROM names WHERE known_for_movies IS NULL;

-- 16. Top 3 directors in top genres with rating > 8
SELECT n.name AS director_name, g.genre, COUNT(*) AS movie_count
FROM director_mapping d
JOIN names n ON d.name_id = n.id
JOIN movie m ON d.movie_id = m.id
JOIN ratings r ON m.id = r.movie_id
JOIN genre g ON m.id = g.movie_id
WHERE r.avg_rating > 8
GROUP BY n.name, g.genre
ORDER BY movie_count DESC
LIMIT 3;

-- 17. Top 2 actors with median rating >= 8
SELECT n.name, COUNT(*) AS movie_count
FROM role_mapping rm
JOIN names n ON rm.name_id = n.id
JOIN ratings r ON rm.movie_id = r.movie_id
WHERE rm.category = 'actor' AND r.median_rating >= 8
GROUP BY n.name
ORDER BY movie_count DESC
LIMIT 2;

-- 18. Top 3 production houses by votes
SELECT m.production_company, SUM(r.total_votes) AS total_votes
FROM movie m
JOIN ratings r ON m.id = r.movie_id
GROUP BY m.production_company
ORDER BY total_votes DESC
LIMIT 3;

-- 19. Rank actors in Indian movies by avg_rating
SELECT n.name, AVG(r.avg_rating) AS avg_actor_rating
FROM role_mapping rm
JOIN names n ON rm.name_id = n.id
JOIN movie m ON rm.movie_id = m.id
JOIN ratings r ON m.id = r.movie_id
WHERE rm.category = 'actor' AND m.country = 'India'
GROUP BY n.name
ORDER BY avg_actor_rating DESC;

-- 20. Top 5 actresses in Hindi movies in India
SELECT n.name, AVG(r.avg_rating) AS avg_rating
FROM role_mapping rm
JOIN names n ON rm.name_id = n.id
JOIN movie m ON rm.movie_id = m.id
JOIN ratings r ON m.id = r.movie_id
WHERE rm.category = 'actress'
  AND m.country = 'India'
  AND m.languages LIKE '%Hindi%'
GROUP BY n.name
ORDER BY avg_rating DESC
LIMIT 5;

-- 🔹 Segment 6: Broader Analysis

-- 21. Classify thriller movies by rating
SELECT m.title, r.avg_rating,
  CASE
    WHEN r.avg_rating >= 9 THEN 'Masterpiece'
    WHEN r.avg_rating >= 8 THEN 'Super Hit'
    WHEN r.avg_rating >= 7 THEN 'Hit'
    ELSE 'Average'
  END AS rating_category
FROM movie m
JOIN ratings r ON m.id = r.movie_id
JOIN genre g ON m.id = g.movie_id
WHERE g.genre = 'Thriller';

-- 22. Genre-wise running total and moving average of duration
SELECT genre, duration,
       SUM(duration) OVER (PARTITION BY genre ORDER BY duration) AS running_total,
       AVG(duration) OVER (PARTITION BY genre ORDER BY duration ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM (
  SELECT g.genre, m.duration
  FROM genre g
  JOIN movie m ON g.movie_id = m.id
) AS sub;

-- 23. Top 5 highest-grossing movies per year in top genres
SELECT *
FROM (
  SELECT m.year, m.title, g.genre, m.worldwide_gross_income,
         RANK() OVER (PARTITION BY m.year ORDER BY m.worldwide_gross_income DESC) AS rnk
  FROM movie m
  JOIN genre g ON m.id = g.movie_id
  WHERE g.genre IN ('Thriller', 'Sci-Fi', 'Drama') -- Replace with actual top 3 genres
    AND m.worldwide_gross_income IS NOT NULL
    AND m.worldwide_gross_income > 0
) AS ranked_movies
WHERE rnk <= 5;

-- 24. Top 2 production houses with most hits among multilingual movies
SELECT m.production_company, COUNT(*) AS hit_count
FROM movie m
JOIN ratings r ON m.id = r.movie_id
WHERE r.avg_rating > 8 AND m.languages LIKE '%,%'
GROUP BY m.production_company
ORDER BY hit_count DESC
LIMIT 2;

-- 25. Top 3 actresses in drama super hits (rating > 8)
SELECT n.name, COUNT(*) AS super_hits
FROM role_mapping rm
JOIN names n ON rm.name_id = n.id
JOIN movie m ON rm.movie_id = m.id
JOIN ratings r ON m.id = r.movie_id
JOIN genre g ON m.id = g.movie_id
WHERE rm.category = 'actress'
  AND g.genre = 'Drama'
  AND r.avg_rating > 8
GROUP BY n.name
ORDER BY super_hits DESC
LIMIT 3;

-- 26. Top 9 directors with stats
SELECT n.name, COUNT(*) AS total_movies, AVG(r.avg_rating) AS avg_rating
FROM director_mapping dm
JOIN names n ON dm.name_id = n.id
JOIN movie m ON dm.movie_id = m.id
JOIN ratings r ON m.id = r.movie_id
GROUP BY n.name
ORDER BY total_movies DESC
LIMIT 9;

