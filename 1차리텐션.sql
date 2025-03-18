# 유저별 최초 주문일 검색 테이블

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

first_order AS (
	SELECT DISTINCT user_id,
			CASE WHEN user_id IN (SELECT user_id
								FROM vip) THEN 'VIP'
			ELSE 'Regular' END AS 'User_Segment', min(created_at) AS first_ord
	FROM orders
	GROUP BY 1
),

# 첫 주문 이후 n개월 주문 여부
order_month AS (SELECT DISTINCT fo.user_id, User_segment,
		CASE WHEN created_at = date_format( date_format( first_ord, '%Y-%m-01'), '%Y-%m-01') THEN 0
		WHEN created_at > date_format( date_format( first_ord, '%Y-%m-01'), '%Y-%m-01') AND created_at <= date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 1 month) THEN 1
		WHEN created_at > date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 1 month) AND created_at <= date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 2 month) THEN 2
		WHEN created_at > date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 2 month) AND created_at <= date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 3 month) THEN 3
		WHEN created_at > date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 3 month) AND created_at <= date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 4 month) THEN 4
		WHEN created_at > date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 4 month) AND created_at <= date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 5 month) THEN 5
		WHEN created_at > date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 5 month) AND created_at <= date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 6 month) THEN 6
		WHEN created_at > date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 6 month) AND created_at <= date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 7 month) THEN 7
		WHEN created_at > date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 7 month) AND created_at <= date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 8 month) THEN 8
		WHEN created_at > date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 8 month) AND created_at <= date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 9 month) THEN 9
		WHEN created_at > date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 9 month) AND created_at <= date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 10 month) THEN 10
		WHEN created_at > date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 10 month) AND created_at <= date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 11 month) THEN 11
		WHEN created_at > date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 11 month) AND created_at <= date_add(date_format( first_ord, '%Y-%m-01'), INTERVAL 12 month) THEN 12
		END AS month_num

FROM first_order fo JOIN orders o ON fo.user_id = o.user_id
ORDER BY month_num desc
),

# 추가 주문 순서
seq_table AS (
	SELECT user_id, User_segment, month_num
			FROM order_month
)

SELECT User_segment,
		CASE WHEN month_num = 0 THEN 'm-0'
		WHEN month_num = 1  THEN 'm-1'
		WHEN month_num = 2  THEN 'm-2'
		WHEN month_num = 3  THEN 'm-3'
		WHEN month_num = 4  THEN 'm-4'
		WHEN month_num = 5  THEN 'm-5'
		WHEN month_num = 6  THEN 'm-6'
		WHEN month_num = 7  THEN 'm-7'
		WHEN month_num = 8  THEN 'm-8'
		WHEN month_num = 9  THEN 'm-9'
		WHEN month_num = 10 THEN 'm-10'
		WHEN month_num = 11 THEN 'm-11'
		WHEN month_num = 12 THEN 'm-12'
		ELSE 'unknown'
		END AS month_range,
		count(user_id) user_cnt
FROM seq_table
GROUP BY 1,2
ORDER BY 1,2;