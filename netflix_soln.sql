create database netflix;
drop table  if exists netflix_show;
create table  netflix_show(
show_id VARCHAR(6),
type VARCHAR(10),
title VARCHAR(150),
director VARCHAR(208),
casts VARCHAR (2500),
country VARCHAR(150),
date_added VARCHAR(60),
release_year INT,
rating VARCHAR (10),
duration VARCHAR(20),
listed_in VARCHAR(100),
description VARCHAR(250)
);


select * from netflix_show;

--Q.1 Count the number of movies and Tvshows

Select * from netflix_show;

select type,count(*)
 as total_content
 from netflix_show
 group by type


--Q2. Find the most common rating for Movies and TV shows
select type ,rating from
( 
select
type,rating, 
count(*),
 RANK() OVER(partition By type order By COUNT(*) DESC) as ranking
 from netflix_show
group by type ,rating) as t1
where ranking =1


--Q3. List all movie relesed in a specific year(e.g 2021)

 
select * from netflix_show
where 
    type = 'Movie'
     and 
	 release_year = 2021

--Q4. Find the top 5 countries with the most content on Netflix

select unnest(string_to_array(country,',')) as new_country,
count(show_id) as total_content
from netflix_show
group by 1
order by total_content desc
limit 5

--Q5. Identify the longest movie?
select * from netflix_show
where type ='Movie'
       AND
	   duration = (select max(duration) from netflix_show)

--Q6. find content added in last 5 year

select * from netflix_show
where 
TO_DATE(date_added,'Month DD,YYYY') >= CURRENT_DATE - INTERVAL'5 years'

 

--Q7  Find the all movie/TV shows by director 'Kirsten johnson' 

select * from netflix_show;

select * from netflix_show
where director Ilike 'Rajiv Chilaka'


--Q8. find all the Tv shows with more than 5  season


SELECT * 
FROM netflix_show
WHERE 
    type = 'TV Show'
    AND CAST(SUBSTRING(duration FROM '^[0-9]+') AS numeric) > 5;




--Q9. Count the number of content items in each genre 
select 
    UNNEST(STRING_to_ARRAY(listed_in,',')) as genre,
    COUNT(show_id) as total_content
	from netflix_show
	group by 1



--Q10. find each year and the average number of content release in india  on netflix.
--return top 5 year with higest avg content relaese 





SELECT 
    extract(year from to_date(date_added, 'MONTH DD YYYY')) AS year,
    count(*) AS yearly_content,
    count(*)::numeric / (SELECT count(*) FROM netflix_show WHERE country = 'India') * 100 AS avg_content_per_year
FROM netflix_show 
WHERE country = 'India'
GROUP BY year
ORDER BY year;

--Q11. list all movies that are documentaries

select  * from netflix_show
where listed_in ilike '%documentaries%'



--Q12.  find all content without a director

select * from netflix_show
where director is null


--Q13. find how many movies actor 'salman khan ' appeared in last 10 year

select * from netflix_show
where
casts ilike '%salman khan%'
and 
release_year > extract(year from current_date) - 10


-- Q14. find the top 10 actor who appeared in the highest number of movies produced in india.



SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*) AS total_content
FROM netflix_show
WHERE country ILIKE '%india%'
GROUP BY actor
ORDER BY total_content DESC;

--Q15. categorize the content based on the presence of the keywords 'kill' and'violence' in
-- the description field. label content containing these keyword as bad and all 
--other content as 'good'. count how many items fall into each category


with new_table
as
(
select
*,
    case
	when
	    description ILIKE '%kill%' or
		description ILIKE '%violence%' THEN 'Bad_content'
		ELSE 'Good Content'
	End category
from netflix_show
)

select 
   category,
   count(*) as total_content
from new_table 
group by 1

