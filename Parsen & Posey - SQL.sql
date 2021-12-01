/* Q1 - Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales. */

SELECT t2.max_tot_sales, t2.region_name, t3.sr_name
FROM
  (SELECT MAX(total_amt) max_tot_sales, region_name
  FROM
    (SELECT sum(o.total_amt_usd) as total_amt, sr.name sr_name, r.name region_name
      from region r
      join sales_reps sr
      on r.id = sr.region_id
      join accounts a
      on a.sales_rep_id = sr.id
      join orders o
      on o.account_id = a.id
      group by sr_name, region_name) t1
  GROUP BY region_name) t2
JOIN
  (SELECT sum(o.total_amt_usd) as total_amt, sr.name sr_name, r.name region_name
  from region r
  join sales_reps sr
  on r.id = sr.region_id
  join accounts a
  on a.sales_rep_id = sr.id
  join orders o
  on o.account_id = a.id
  group by sr_name, region_name) t3
on t2.max_tot_sales = t3.total_amt AND t2.region_name = t3.region_name



/* Q2 - For the region with the largest (sum) of sales total_amt_usd,
how many total (count) orders were placed? */


SELECT *
FROM
  (SELECT MAX(t2.count), t2.region_name
  FROM
    (SELECT sum(o.total_amt_usd) as total_amt_usd, r.name region_name, count(*) as count
    from region r
      join sales_reps sr
      on r.id = sr.region_id
      join accounts a
      on a.sales_rep_id = sr.id
      join orders o
      on o.account_id = a.id
    group by region_name) t2
    GROUP BY  t2.region_name ) t4
JOIN
  (SELECT sum(o.total_amt_usd) as total_amt_usd, r.name region_name, count(*) as count
  from region r
    join sales_reps sr
    on r.id = sr.region_id
    join accounts a
    on a.sales_rep_id = sr.id
    join orders o
    on o.account_id = a.id
  group by region_name) t1
  HAVING



/* Q4 - For the customer that spent the most (in total over their lifetime as
a customer) total_amt_usd, how many web_events did they have for each channel? */

SELECT we.channel, a.id account_idd, COUNT(*)
FROM web_events we
  JOIN accounts a
  ON we.account_id = a.id
  GROUP BY 1,2
  HAVING a.id =
    (SELECT t1.account_id
    FROM
      ((SELECT a.id account_id, sum(o.total_amt_usd) as total_sum_of_orders
      FROM accounts a
        JOIN orders o
        ON a.id = o.account_id
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 1))t1)
  ORDER BY count DESC



  /* Q5 - What is the lifetime average amount spent in terms of total_amt_usd
  for the top 10 total spending accounts? */

  SELECT AVG(t1.tot_spent) as avg_lifetime_spent
  FROM
    (SELECT a.name acc_name, sum(o.total_amt_usd) tot_spent
    FROM accounts a
    JOIN orders o
    ON a.id = o.account_id
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 10) t1



  /* Q6 - What is the lifetime average amount spent in terms of total_amt_usd,
  including only the companies that spent more per order, on average,
  than the average of all orders. */

  SELECT AVG(avg_spent_per_order_per_acc) avg_required
  FROM
    (SELECT a.name acc_name, AVG(o.total_amt_usd) as avg_spent_per_order_per_acc
    FROM accounts a
      JOIN orders o
      ON a.id = o.account_id
      GROUP BY 1
    HAVING AVG(o.total_amt_usd) >
      ( SELECT AVG(o.total_amt_usd) tot_ordered
        FROM accounts a
        JOIN orders o
        ON a.id = o.account_id))t2
