-- business query 1
-- top destination states by month

select
    dd.year_num,
    dd.month_num,
    dl.ship_to_state,
    count(*) as order_count,
    dense_rank() over (
        partition by dd.year_num, dd.month_num
        order by count(*) desc
    ) as state_rank
from fact_order_snapshot f
join dim_date dd
    on f.date_key = dd.date_key
join dim_destination_location dl
    on f.destination_location_key = dl.destination_location_key
group by
    dd.year_num,
    dd.month_num,
    dl.ship_to_state
order by
    dd.year_num,
    dd.month_num,
    state_rank,
    dl.ship_to_state;



-- business query 2
-- monthly revenue trend by destination state


select
    dd.year_num,
    dd.month_num,
    dl.ship_to_state,
    sum(f.sales_amount) as total_sales,
    avg(f.sales_amount) as avg_order_value,
    count(*) as order_count
from fact_order_snapshot f
join dim_date dd
    on f.date_key = dd.date_key
join dim_destination_location dl
    on f.destination_location_key = dl.destination_location_key
group by
    dd.year_num,
    dd.month_num,
    dl.ship_to_state
order by
    dd.year_num,
    dd.month_num,
    total_sales desc;



-- business query 3
-- return rate by state


select
    dl.ship_to_state,
    count(distinct fos.order_id) as total_orders,
    count(distinct frs.order_id) as total_returns,
    round(
        count(distinct frs.order_id)::numeric
        / nullif(count(distinct fos.order_id), 0),
        4
    ) as return_rate
from fact_order_snapshot fos
join dim_destination_location dl
    on fos.destination_location_key = dl.destination_location_key
left join fact_return_snapshot frs
    on fos.order_id = frs.order_id
group by
    dl.ship_to_state
order by
    return_rate desc nulls last,
    total_returns desc;



-- business query 4
-- average delivery time by weather and traffic


select
    dc.weather,
    dc.traffic,
    round(avg(f.delivery_time)::numeric, 2) as avg_delivery_time,
    count(*) as delivery_count
from fact_delivery_cumulative f
join dim_condition dc
    on f.condition_key = dc.condition_key
group by
    dc.weather,
    dc.traffic
order by
    avg_delivery_time desc,
    delivery_count desc;



-- business query 5
-- top product pairs by sales



select
    dp.asin,
    dp.sku,
    sum(f.sales_amount) as total_sales,
    sum(f.quantity) as total_quantity,
    count(*) as order_lines
from fact_order_snapshot f
join dim_product dp
    on f.product_key = dp.product_key
group by
    dp.asin,
    dp.sku
order by
    total_sales desc,
    total_quantity desc;



	