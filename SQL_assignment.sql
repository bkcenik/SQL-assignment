-- 1a. Display the first and last names of all actors from the table `actor`.
select first_name, last_name
from actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
Select UPPER(concat(first_name, " ", last_name)) AS 'Actor Name'
from actor;
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
select actor_id, first_name, last_name
from actor
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`:
select first_name, last_name
from actor
where last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select first_name, last_name
from actor
where last_name LIKE "%LI%"
order by last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country in ('Afghanistan','Bangladesh','China');

-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table `actor` named `description` and use 
-- the data type `BLOB` (Make sure to research the type `BLOB`, 
-- as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD COLUMN description BLOB(50);

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) as 'actor count'
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(last_name) as 'actor count'
from actor
group by last_name
having count(last_name) >= 2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
update actor
set first_name = "HARPO"
WHERE first_name = "GROUCHO" and last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
update actor
set first_name = "GROUCHO"
where first_name = "HARPO";

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
-- Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)
show create table address;
create table if not exists `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select first_name, last_name, address
FROM staff
JOIN address
using(address_id);

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
select staff_id, first_name, last_name, sum(amount) as "Total Amount Rung Up"
from staff
join payment
using (staff_id)
where payment_date LIKE '2005-08%'
group by staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select title, count(actor_id) as 'actor number'
from film
inner join film_actor
using(film_id)
group by title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select count(film_id) as 'copies of film'
from inventory
where film_id in
(
select film_id from film
where title = 'Hunchback Impossible'
);

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
select first_name, last_name, sum(amount) as 'Total Paid'
from customer
join payment
using (customer_id)
group by customer_id
order by last_name;

-- 7a. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select title
from film
where title like 'K%' or title like 'Q%' and language_id in
(
select language_id
from language
where name = 'English'
);

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select first_name, last_name
from actor
where actor_id in
(
select actor_id 
from film_actor
where film_id in
(
select film_id
from film
where title = 'Alone Trip'
)
);

-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of 
-- all Canadian customers. Use joins to retrieve this information.
select first_name, last_name
from customer
join address
using(address_id)
where city_id in
(
select city_id
from city
where country_id in
(
select country_id
from country
where country = 'Canada'
)
)
;

-- 7d. Identify all movies categorized as _family_ films.
select title
from film
where film_id in
(
select film_id
from film_category
where category_id in
(
select category_id
from category
where name = 'Family'
)
);

-- 7e. Display the most frequently rented movies in descending order.
select title, count(film_id) as 'numer of rentals'
from film
join inventory
using(film_id)
join rental
using(inventory_id)
group by title
order by count(film_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select store_id, sum(amount) as 'total business'
from payment
join rental
using (rental_id)
join inventory
using (inventory_id)
group by store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select store_id, city, country
from store
join address
using (address_id)
join city
using (city_id)
join country
using (country_id);


-- 7h. List the top five genres in gross revenue in descending order. 
select name, sum(amount) as 'gross revenue'
from payment
join rental
using (rental_id)
join inventory
using (inventory_id)
join film_category
using (film_id)
join category
using (category_id)
group by name
order by sum(amount) desc limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
create view top_five_genres as
select name, sum(amount) as 'gross revenue'
from payment
join rental
using (rental_id)
join inventory
using (inventory_id)
join film_category
using (film_id)
join category
using (category_id)
group by name
order by sum(amount) desc limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view top_five_genres;


