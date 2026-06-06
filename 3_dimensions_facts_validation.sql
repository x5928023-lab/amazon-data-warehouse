-- create dimensions and facts

-- dim_date

create table dim_date (
    date_key bigserial primary key,
    full_date date,
    day_num int,
    month_num int,
    month_name text,
    quarter_num int,
    year_num int,
    weekday_name text
);

insert into dim_date
(
    full_date,
    day_num,
    month_num,
    month_name,
    quarter_num,
    year_num,
    weekday_name
)
select distinct
    full_date,
    extract(day from full_date)::int,
    extract(month from full_date)::int,
    trim(to_char(full_date, 'Month')),
    extract(quarter from full_date)::int,
    extract(year from full_date)::int,
    trim(to_char(full_date, 'Day'))
from
(
    select order_date as full_date
    from orders_clean
    where order_date is not null

    union

    select delivery_order_date as full_date
    from delivery_clean
    where delivery_order_date is not null
) t;

create unique index idx_dim_date_full_date
on dim_date(full_date);



-- dim_product

create table dim_product (
    product_key bigserial primary key,
    asin text,
    sku text
);

insert into dim_product
(
    asin,
    sku
)
select distinct
    upper(trim(asin)) as asin,
    upper(trim(sku)) as sku
from orders_clean
where asin is not null
  and sku is not null
  and trim(asin) <> ''
  and trim(sku) <> '';

create unique index idx_dim_product_nk
on dim_product(asin, sku);



-- dim_fulfillment

create table dim_fulfillment (
    fulfillment_key bigserial primary key,
    current_fulfillment_type text,
    previous_fulfillment_type text
);

insert into dim_fulfillment
(
    current_fulfillment_type,
    previous_fulfillment_type
)
select distinct
    fulfillment_type,
    null::text
from orders_clean
where fulfillment_type is not null
  and trim(fulfillment_type) <> '';

create unique index idx_dim_fulfillment_nk
on dim_fulfillment(current_fulfillment_type);



-- dim_agent

create table dim_agent (
    agent_key bigserial primary key,
    agent_age_group text,
    agent_rating_band text
);

insert into dim_agent
(
    agent_age_group,
    agent_rating_band
)
select distinct
    agent_age_group,
    agent_rating_band
from delivery_clean;

create unique index idx_dim_agent_nk
on dim_agent(agent_age_group, agent_rating_band);



-- dim_condition

create table dim_condition (
    condition_key bigserial primary key,
    weather text,
    traffic text,
    vehicle text,
    area text,
    category text
);

insert into dim_condition
(
    weather,
    traffic,
    vehicle,
    area,
    category
)
select distinct
    weather,
    traffic,
    vehicle,
    area,
    category
from delivery_clean;

create unique index idx_dim_condition_nk
on dim_condition(weather, traffic, vehicle, area, category);



-- dim_origin_location

create table dim_origin_location (
    origin_location_key bigserial primary key,
    ship_from_country text,
    ship_from_state text,
    ship_from_city text,
    ship_from_postal_code text
);

insert into dim_origin_location
(
    ship_from_country,
    ship_from_state,
    ship_from_city,
    ship_from_postal_code
)
select distinct
    coalesce(ship_from_country, 'Unknown'),
    coalesce(ship_from_state, 'Unknown'),
    coalesce(ship_from_city, 'Unknown'),
    coalesce(ship_from_postal_code, 'Unknown')
from orders_clean;

create unique index idx_dim_origin_location_nk
on dim_origin_location
(
    ship_from_country,
    ship_from_state,
    ship_from_city,
    ship_from_postal_code
);



-- dim_destination_location

create table dim_destination_location (
    destination_location_key bigserial primary key,
    ship_to_country text,
    ship_to_state text,
    ship_to_city text,
    ship_to_postal_code text,
    start_date date,
    end_date date,
    current_flag char(1)
);

insert into dim_destination_location
(
    ship_to_country,
    ship_to_state,
    ship_to_city,
    ship_to_postal_code,
    start_date,
    end_date,
    current_flag
)
select distinct
    coalesce(ship_to_country, 'Unknown'),
    coalesce(ship_to_state, 'Unknown'),
    coalesce(ship_to_city, 'Unknown'),
    coalesce(ship_to_postal_code, 'Unknown'),
    current_date,
    null::date,
    'Y'
from orders_clean;

create unique index idx_dim_destination_location_nk
on dim_destination_location
(
    ship_to_country,
    ship_to_state,
    ship_to_city,
    ship_to_postal_code,
    current_flag
);



-- indexes on clean tables

create index idx_orders_clean_order_date
on orders_clean(order_date);

create index idx_orders_clean_product
on orders_clean(asin, sku);

create index idx_orders_clean_fulfillment
on orders_clean(fulfillment_type);

create index idx_orders_clean_origin
on orders_clean(ship_from_country, ship_from_state, ship_from_city, ship_from_postal_code);

create index idx_orders_clean_destination
on orders_clean(ship_to_country, ship_to_state, ship_to_city, ship_to_postal_code);

create index idx_orders_clean_transaction_type
on orders_clean(transaction_type);

create index idx_delivery_clean_date
on delivery_clean(delivery_order_date);

create index idx_delivery_clean_agent
on delivery_clean(agent_age_group, agent_rating_band);

create index idx_delivery_clean_condition
on delivery_clean(weather, traffic, vehicle, area, category);



-- fact_order_snapshot

create table fact_order_snapshot (
    fact_key bigserial primary key,
    date_key bigint,
    product_key bigint,
    origin_location_key bigint,
    destination_location_key bigint,
    fulfillment_key bigint,
    order_id text,
    quantity int,
    display_price numeric(12,2),
    sales_amount numeric(12,2),
    total_tax_collected_by_amazon numeric(12,2),
    order_count int
);

insert into fact_order_snapshot
(
    date_key,
    product_key,
    origin_location_key,
    destination_location_key,
    fulfillment_key,
    order_id,
    quantity,
    display_price,
    sales_amount,
    total_tax_collected_by_amazon,
    order_count
)
select
    d.date_key,
    p.product_key,
    o_loc.origin_location_key,
    d_loc.destination_location_key,
    f.fulfillment_key,
    o.order_id,
    o.quantity,
    o.display_price,
    o.sales_amount,
    o.total_tax_collected_by_amazon,
    o.order_count
from orders_clean o
join dim_date d
    on o.order_date = d.full_date
join dim_product p
    on upper(trim(o.asin)) = p.asin
   and upper(trim(o.sku)) = p.sku
join dim_origin_location o_loc
    on coalesce(o.ship_from_country, 'Unknown') = o_loc.ship_from_country
   and coalesce(o.ship_from_state, 'Unknown') = o_loc.ship_from_state
   and coalesce(o.ship_from_city, 'Unknown') = o_loc.ship_from_city
   and coalesce(o.ship_from_postal_code, 'Unknown') = o_loc.ship_from_postal_code
join dim_destination_location d_loc
    on coalesce(o.ship_to_country, 'Unknown') = d_loc.ship_to_country
   and coalesce(o.ship_to_state, 'Unknown') = d_loc.ship_to_state
   and coalesce(o.ship_to_city, 'Unknown') = d_loc.ship_to_city
   and coalesce(o.ship_to_postal_code, 'Unknown') = d_loc.ship_to_postal_code
   and d_loc.current_flag = 'Y'
join dim_fulfillment f
    on o.fulfillment_type = f.current_fulfillment_type;



-- fact_return_snapshot

create table fact_return_snapshot (
    fact_key bigserial primary key,
    date_key bigint,
    product_key bigint,
    origin_location_key bigint,
    destination_location_key bigint,
    order_id text,
    sales_amount numeric(12,2),
    return_count int
);

insert into fact_return_snapshot
(
    date_key,
    product_key,
    origin_location_key,
    destination_location_key,
    order_id,
    sales_amount,
    return_count
)
select
    d.date_key,
    p.product_key,
    o_loc.origin_location_key,
    d_loc.destination_location_key,
    o.order_id,
    o.sales_amount,
    1
from orders_clean o
join dim_date d
    on o.order_date = d.full_date
join dim_product p
    on upper(trim(o.asin)) = p.asin
   and upper(trim(o.sku)) = p.sku
join dim_origin_location o_loc
    on coalesce(o.ship_from_country, 'Unknown') = o_loc.ship_from_country
   and coalesce(o.ship_from_state, 'Unknown') = o_loc.ship_from_state
   and coalesce(o.ship_from_city, 'Unknown') = o_loc.ship_from_city
   and coalesce(o.ship_from_postal_code, 'Unknown') = o_loc.ship_from_postal_code
join dim_destination_location d_loc
    on coalesce(o.ship_to_country, 'Unknown') = d_loc.ship_to_country
   and coalesce(o.ship_to_state, 'Unknown') = d_loc.ship_to_state
   and coalesce(o.ship_to_city, 'Unknown') = d_loc.ship_to_city
   and coalesce(o.ship_to_postal_code, 'Unknown') = d_loc.ship_to_postal_code
   and d_loc.current_flag = 'Y'
where o.transaction_type like '%RETURN%';



-- fact_delivery_cumulative

create table fact_delivery_cumulative (
    fact_key bigserial primary key,
    date_key bigint,
    agent_key bigint,
    condition_key bigint,
    order_id text,
    delivery_time int,
    agent_rating numeric(3,1)
);

insert into fact_delivery_cumulative
(
    date_key,
    agent_key,
    condition_key,
    order_id,
    delivery_time,
    agent_rating
)
select
    d.date_key,
    a.agent_key,
    c.condition_key,
    dc.order_id,
    dc.delivery_time,
    dc.agent_rating
from delivery_clean dc
join dim_date d
    on dc.delivery_order_date = d.full_date
join dim_agent a
    on dc.agent_age_group = a.agent_age_group
   and dc.agent_rating_band = a.agent_rating_band
join dim_condition c
    on dc.weather = c.weather
   and dc.traffic = c.traffic
   and dc.vehicle = c.vehicle
   and dc.area = c.area
   and dc.category = c.category;



-- checks

select count(*) from dim_date;
select count(*) from dim_product;
select count(*) from dim_fulfillment;
select count(*) from dim_agent;
select count(*) from dim_condition;
select count(*) from dim_origin_location;
select count(*) from dim_destination_location;

select count(*) from fact_order_snapshot;
select count(*) from fact_return_snapshot;
select count(*) from fact_delivery_cumulative;