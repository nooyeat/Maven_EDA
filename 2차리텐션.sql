#전체고객 rolling retention
WITH firstlast_order AS (
	SELECT DISTINCT user_id, min(created_at) AS first_ord_date, max(created_at) AS last_ord_date
	FROM orders
	GROUP BY user_id
	),
user_od AS(
	SELECT o.user_id
	, DATE_FORMAT(fo.first_ord_date,'%Y-%m-01')AS first_order_month
	, DATE_FORMAT(fo.last_ord_date,'%Y-%m-01')AS last_order_month
  FROM firstlast_order fo
  LEFT JOIN orders o ON o.user_id = fo.user_id
)
SELECT first_order_month
		, COUNT(DISTINCT user_id) AS month0
	    , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 1 MONTH) <= last_order_month THEN user_id END) AS month1
	    , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 2 MONTH) <= last_order_month THEN user_id END) AS month2
	    , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 3 MONTH) <= last_order_month THEN user_id END) AS month3
	     , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 4 MONTH) <= last_order_month THEN user_id END) AS month4
	     , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 5 MONTH) <= last_order_month  THEN user_id END) AS month5
	     , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 6 MONTH) <= last_order_month  THEN user_id END) AS month6
	     , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 7 MONTH) <= last_order_month  THEN user_id END) AS month7
	     , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 8 MONTH) <= last_order_month  THEN user_id END) AS month8
	     , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 9 MONTH) <= last_order_month  THEN user_id  END) AS month9
	     , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 10 MONTH) <= last_order_month  THEN user_id END) AS month10
	     , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 11 MONTH) <= last_order_month THEN user_id END) AS month11
FROM user_od
GROUP BY first_order_month ORDER BY first_order_month ;

#VIP rolling retention

WITH Avg_price AS (
    SELECT AVG(total_purchase) AS avg_price
    FROM (
        SELECT user_id, SUM(price_usd) AS total_purchase
        FROM orders
        GROUP BY user_id
    ) AS user_purchase
),
VIP AS (
    SELECT o.user_id, SUM(o.price_usd) AS total_purchase, a.avg_price
    FROM orders o
    CROSS JOIN Avg_price a
    GROUP BY o.user_id, a.avg_price
    HAVING SUM(o.price_usd) >= 1.5 * a.avg_price
),
firstlast_order AS (
	SELECT DISTINCT user_id, min(created_at) AS first_ord_date, max(created_at) AS last_ord_date
	FROM orders
	WHERE user_id IN(SELECT user_id FROM VIP)
	GROUP BY user_id
	),
user_od AS(
	SELECT o.user_id
	, DATE_FORMAT(fo.first_ord_date,'%Y-%m-01')AS first_order_month
	, DATE_FORMAT(fo.last_ord_date,'%Y-%m-01')AS last_order_month
  FROM firstlast_order fo
  LEFT JOIN orders o ON o.user_id = fo.user_id
)
SELECT first_order_month
		, COUNT(DISTINCT user_id) AS month0
	    , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 1 MONTH) <= last_order_month THEN user_id END) AS month1
	    , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 2 MONTH) <= last_order_month THEN user_id END) AS month2
	    , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 3 MONTH) <= last_order_month THEN user_id END) AS month3
	     , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 4 MONTH) <= last_order_month THEN user_id END) AS month4
	     , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 5 MONTH) <= last_order_month  THEN user_id END) AS month5
	     , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 6 MONTH) <= last_order_month  THEN user_id END) AS month6
	     , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 7 MONTH) <= last_order_month  THEN user_id END) AS month7
	     , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 8 MONTH) <= last_order_month  THEN user_id END) AS month8
	     , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 9 MONTH) <= last_order_month  THEN user_id  END) AS month9
	     , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 10 MONTH) <= last_order_month  THEN user_id END) AS month10
	     , COUNT(DISTINCT CASE WHEN DATE_ADD(first_order_month, INTERVAL 11 MONTH) <= last_order_month THEN user_id END) AS month11
FROM user_od
GROUP BY first_order_month ORDER BY first_order_month ;
