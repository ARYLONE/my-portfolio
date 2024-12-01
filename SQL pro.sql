-- Q.1) write a query to return email, first name, last name, and genre of all rock music listeners
-- return the list alphabetically by email starting with 'A'

select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in 
	(select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock')
order by email;

--Q.2)  return all the track names that have a song length longer than the aveage song length .
-- Return the name and milliseconds for each track, order by the song length with longest songs listed first.



select name, milliseconds
from track
where milliseconds >(select AVG (milliseconds) AS avg_track_length from track)
order by milliseconds desc;

--Q.3) Who is the senior most employeebased on job title?

select title, last_name, first_name
from employee
order by levels desc
limit 1

--Q.4) What are the top three values of the total invoice?

select total 
from invoice
order by total desc
limit 3

--Q.5) Write a query that determines the customer that has spent the most on music for each country.
--write a Query that returns the country along with the top customer and how much they spent.
--for countries where the top amount spent is shared, provide all customers who spent this amount .

with customer_with_country as (
	select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending, row_number() over (partition by billing_country order by sum(total) desc) as rowno
from invoice
	join customer on customer.customer_id = invoice.customer_id
	group by 1,2,3,4
	order by 4 asc,5 desc)
select * from customer_with_country where rowno<=1


--Q.6) Find how much is spent by customer on artists ? write a query to return customer name, artist name and total spent.

with best_selling_artist as (
	select artist.artist_id as artist_id, artist.name as artist_name,
	sum (invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id=invoice_line.track_id
	join album on album.album_id=track.album_id
	join artist on artist.artist_id=album.artist_id
	group by 1
	order by 3 desc
	limit 1
	)

select c .customer_id,c .first_name,c .last_name, bsa .artist_name,sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=il.track_id
join album alb on alb.album_id=t.album_id
join best_selling_artist bsa on bsa.artist_id=alb.artist_id
group by 1,2,3,4
order by 5 desc;

--Q.7) we need to find the most popular music genre for each country. determine the most popular genre as
--the genre with the highest amount of purchases. write a query that returns each country along with top genre.
--for countries where maximum number of  purchases are shared, return all genres for them.

with popular_genre as(
	select count(invoice_line.quantity) as purchases, customer.country , genre.name, genre.genre_id,
	row number() over (partition by customer.country order by count (i)nvoice_line.quantity) desc) as rowno
	from invoice_line
)



