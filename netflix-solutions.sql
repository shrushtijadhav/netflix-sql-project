-- Netflix Project
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(208),
	casting VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
	)
SELECT * FROM netflix;

SELECT COUNT(*) AS total_content FROM netflix;

SELECT DISTINCT(type) FROM netflix;


-- 15 Business Problems

-- 1. Count the number of movies Vs TV Shows.
	SELECT type, COUNT(*) AS total_content
	FROM netflix 
	GROUP BY type;

--2. Find the most common rating for movies and TV Shows?
	SELECT
	type,
	rating ,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	from netflix
	GROUP BY 1,2;
	
--3. List all the movies released in specific year (eg. 2020)
	SELECT * FROM netflix
	WHERE release_year = '2020' AND type='Movie';

--4. Find the top 5 countries with the most content on Netflix
	SELECT UNNEST(STRING_TO_ARRAY(country,',')) as new_country, 
	COUNT(show_id) AS number_of_content 
	FROM netflix 
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 5;
	
--5. Identify the longest movie or TV Show duration
	SELECT title, MAX(CAST(SUBSTRING(duration, 1, POSITION(' ' in duration)-1) AS INT)) AS maximum_length
	FROM netflix
	WHERE type='Movie'
	AND 
	duration is not null
	GROUP BY 1
	ORDER BY 2 DESC;

--6. Find the content added in the last 5 years
	SELECT * FROM netflix
	WHERE TO_DATE(date_added,'Month DD, YYYY') >= CURRENT_DATE - INTERVAL'5 years';
	
--7. Find all the movies /TV shows by director 'Rajiv Chilaka'
	SELECT title from netflix
	WHERE director LIKE '%Rajiv Chilaka%';
	
--8. List all the TV shows with more than 5 seasons
	SELECT * FROM netflix
	WHERE type='TV Show'
	AND CAST(SUBSTRING(duration, 1, POSITION(' ' in duration)-1) AS INT) > 5;
	
--9. Count the number of content items in each genre
	SELECT UNNEST(STRING_TO_ARRAY(listed_in,',')), 
	COUNT(show_id) FROM netflix
	GROUP BY 1;

--10 Find each year and the average number of content released by India on netflix.
-- 		Return top 5 year with the highest average content release.
	SELECT EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD, YYYY')) as year,
	COUNT(*),
	ROUND((COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country='India')::numeric)*100,2)
	FROM netflix
	WHERE country = 'India'
	GROUP BY 1;

--11. List all the movies that are documentaries
	SELECT * FROM netflix
	WHERE listed_in ILIKE'%documentaries%';
	
--12. Find all the content without a director
	SELECT title FROM netflix 
	WHERE director IS NULL;

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years
	SELECT * FROM netflix
	WHERE casting LIKE'%Salman Khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE)-10;
	
--14. Find the top 10 actors who have appeared in the highest number of movies produced in
	SELECT 
	UNNEST(STRING_TO_ARRAY(casting,',')) AS actors,
	COUNT(*) AS total_content
	FROM netflix
	WHERE country ILIKE '%india'
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 10;
	
--15. Categorize the content based on the presence of the keywords 'kill' and 'violence' 
--	  in the description field. Label content containing these keywords as 'Bad' and all 
--	  other content as 'Good'. Count how many items fall into each category.
--SOLUTION-1
SELECT * 
	FROM netflix
	WHERE description ILIKE '%kill%' 
	OR
	description ILIKE '%violence%';

	
--SOLUTION-2	
	WITH new_table
	AS
	(
	SELECT * ,
	CASE
	WHEN description ILIKE '%kill%' 
	OR
	description ILIKE '%violence%' 
	THEN 'Bad Content'
	ELSE 'Good Content'
	END category
	FROM netflix
	)
	SELECT category,
	COUNT(*)
	FROM new_table
	GROUP BY 1;