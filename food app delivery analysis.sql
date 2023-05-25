-- For a high-level overview of the hotels, provide us the top 5 most voted hotels in the delivery category
SELECT name, 
	votes,
	rating
from zomato
where type = 'delivery'
order by votes DESC
limit 5;

-- The rating of a hotel is a key identifier in determining a restaurant’s performance. Hence for a particular location called Banashankari find out the top 5 highly rated hotels in the delivery category

SELECT name, rating 
from zomato
where location = 'Banashankari' and rest_type = 'delivery'
order by rating DESC
limit 5;

-- compare the ratings of the cheapest and most expensive hotels in Indiranagar.

SELECT t1.rating1, t2.rating2
FROM 
(select rating as rating1 from zomato where approx_cost = (select min(approx_cost) from zomato where location = 'Indiranagar')) t1 
 
 CROSS JOIN
 
(select rating as rating2 from zomato where approx_cost = (select max(approx_cost) from zomato where location = 'Indiranagar')) t2
 
limit 1; 

-- Online ordering of food has exponentially increased over time. Compare the total votes of restaurants that provide online ordering services and those who don’t provide online ordering service.

SELECT online_order, sum(votes) as total_votes
from zomato
group by online_order;

-- For each Restaurant type, find out the number of restaurants, total votes, and average rating. Display the data with the highest votes on the top( if the first row of output is NA display the remaining rows).

SELECT type, count(name) as number_of_restuarant, sum(votes) as total_votes, avg(rating) as average_rating
from zomato 
group by type
having type <> 'NA'
order by total_votes DESC; 

-- What is the most liked dish of the most-voted restaurant on Zomato(as the restaurant has a tie-up with Zomato, the restaurant compulsorily provides online ordering and delivery facilities.

SELECT name, dish_liked,  round(avg(rating), 1) as rating, max(votes) as votes
from zomato
group by name, online_order, dish_liked
having online_order = 'yes'
order by votes DESC
limit 1; 

-- To increase the maximum profit, Zomato is in need to expand its business. For doing so Zomato wants the list of the top 15 restaurants which have min 150 votes, have a rating greater than 3, and is currently not providing online ordering. Display the restaurants with highest votes on the top.

SELECT name, rating, votes, online_order
 from zomato 
 where votes > 150 and rating > 3  and online_order = 'No'
 order by votes DESC
 limit 15