with customer_orders AS (
    SELECT
        o.user_id,
        SUM(o.price_usd) AS total_spent,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    GROUP BY o.user_id
),
avg_order_value AS (
    SELECT AVG(price_usd) * 1.5 AS vip_threshold FROM orders -- 평균 주문 금액의 1.5배를 VIP 기준으로 설정(전체 주문 고객의 10%를 VIP라고 정의)
),
customer_segments AS (
    SELECT
        co.user_id,
        CASE
            WHEN co.total_spent >= (SELECT vip_threshold FROM avg_order_value) THEN 'VIP'
            WHEN co.total_spent < (SELECT vip_threshold FROM avg_order_value) THEN 'Non_VIP'
			END AS segment
    FROM customer_orders co
),
ranked_pageviews as (
select
	wp.website_session_id,
	ws.user_id,
	ws.created_at,
	wp.pageview_url,
	row_number() over (partition by ws.user_id,
	wp.website_session_id
order by
	wp.created_at) as step_num
from
	website_sessions ws
join website_pageviews wp on
	wp.website_session_id = ws.website_session_id
),
funnel_flow as (
select
	rp.website_session_id,
	rp.user_id,
	rp.created_at,
	GROUP_CONCAT(rp.pageview_url order by rp.step_num separator ' → ') as user_funnel_flow
from
	ranked_pageviews rp
group by
	rp.user_id,
	rp.website_session_id,
	rp.created_at
order by
	rp.user_id,
	rp.website_session_id
)
select
	coalesce(cs.segment, 'Non-Buyer'),
	(count(case when ff.user_funnel_flow like '/home%' then 1 end) - count(case when ff.user_funnel_flow like '/home %' then 1 end)) / count(case when ff.user_funnel_flow like '/home%' then 1 end) * 100 as `/home`,
	(count(case when ff.user_funnel_flow like '/lander-1%' then 1 end) - count(case when ff.user_funnel_flow like '/lander-1 %' then 1 end)) / count(case when ff.user_funnel_flow like '/lander-1%' then 1 end) * 100 as `/lander-1`,
	(count(case when ff.user_funnel_flow like '/lander-2%' then 1 end) - count(case when ff.user_funnel_flow like '/lander-2 %' then 1 end)) / count(case when ff.user_funnel_flow like '/lander-2%' then 1 end) * 100 as `/lander-2`,
	(count(case when ff.user_funnel_flow like '/lander-3%' then 1 end) - count(case when ff.user_funnel_flow like '/lander-3 %' then 1 end)) / count(case when ff.user_funnel_flow like '/lander-3%' then 1 end) * 100 as `/lander-3`,
	(count(case when ff.user_funnel_flow like '/lander-4%' then 1 end) - count(case when ff.user_funnel_flow like '/lander-4 %' then 1 end)) / count(case when ff.user_funnel_flow like '/lander-4%' then 1 end) * 100 as `/lander-4`,
	(count(case when ff.user_funnel_flow like '/lander-5%' then 1 end) - count(case when ff.user_funnel_flow like '/lander-5 %' then 1 end)) / count(case when ff.user_funnel_flow like '/lander-5%' then 1 end) * 100 as `/lander-5`
from
	funnel_flow ff
left join customer_segments cs
on ff.user_id = cs.user_id 
group by
	cs.segment;