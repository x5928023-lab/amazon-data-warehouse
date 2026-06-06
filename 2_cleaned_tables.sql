-- create cleaned tables

drop table if exists orders_clean;
drop table if exists delivery_clean;

-- clean orders table

create table orders_clean as
select
    trim(order_id) as order_id,

    case
        when trim(order_date) = '' then null
        else cast(split_part(trim(order_date), '+', 1) as date)
    end as order_date,

    case
        when trim(shipment_date) = '' then null
        else cast(split_part(trim(shipment_date), '+', 1) as date)
    end as shipment_date,

    case
        when trim(posted_date) = '' then null
        else cast(split_part(trim(posted_date), '+', 1) as date)
    end as posted_date,

    trim(shipment_id) as shipment_id,

    upper(trim(fulfillment)) as fulfillment_type,
    upper(trim(asin)) as asin,
    upper(trim(sku)) as sku,
    upper(trim(transaction_type)) as transaction_type,

    trim(tax_collection_model) as tax_collection_model,

    cast(nullif(trim(quantity), '') as integer) as quantity,

    cast(nullif(trim(display_price), '') as numeric(12,2)) as display_price,

    cast(nullif(trim(taxexclusive_selling_price), '') as numeric(12,2)) as taxexclusive_selling_price,

    cast(nullif(trim(total_tax_collected_by_amazon), '') as numeric(12,2)) as total_tax_collected_by_amazon,

    cast(nullif(trim(taxable_amount), '') as numeric(12,2)) as taxable_amount,

    initcap(trim(ship_from_city)) as ship_from_city,
    upper(trim(ship_from_state)) as ship_from_state,
    upper(trim(ship_from_country)) as ship_from_country,
    trim(ship_from_postal_code) as ship_from_postal_code,

    initcap(trim(ship_to_city)) as ship_to_city,
    upper(trim(ship_to_state)) as ship_to_state,
    upper(trim(ship_to_country)) as ship_to_country,
    trim(ship_to_postal_code) as ship_to_postal_code,

    cast(nullif(trim(quantity), '') as integer)
    *
    cast(nullif(trim(display_price), '') as numeric(12,2)) as sales_amount,

    1 as order_count

from amazon_orders_staging
where trim(order_id) <> '';



-- clean delivery table

create table delivery_clean as
select
    trim(order_id) as order_id,

    cast(nullif(trim(agent_age), '') as integer) as agent_age,

    cast(nullif(trim(agent_rating), '') as numeric(3,1)) as agent_rating,

    cast(nullif(trim(store_latitude), '') as numeric(10,6)) as store_latitude,
    cast(nullif(trim(store_longitude), '') as numeric(10,6)) as store_longitude,
    cast(nullif(trim(drop_latitude), '') as numeric(10,6)) as drop_latitude,
    cast(nullif(trim(drop_longitude), '') as numeric(10,6)) as drop_longitude,

    case
        when trim(order_date) = '' then null
        else to_date(trim(order_date), 'MM/DD/YY')
    end as delivery_order_date,

    case
        when trim(order_time) in ('', 'NaN') then null
        else cast(trim(order_time) as time)
    end as order_time,

    case
        when trim(pickup_time) in ('', 'NaN') then null
        else cast(trim(pickup_time) as time)
    end as pickup_time,

    initcap(trim(weather)) as weather,
    initcap(trim(traffic)) as traffic,
    initcap(trim(vehicle)) as vehicle,
    initcap(trim(area)) as area,
    initcap(trim(category)) as category,

    cast(nullif(trim(delivery_time), '') as integer) as delivery_time,

    case
        when cast(nullif(trim(agent_age), '') as integer) < 25 then '18-24'
        when cast(nullif(trim(agent_age), '') as integer) between 25 and 34 then '25-34'
        when cast(nullif(trim(agent_age), '') as integer) between 35 and 44 then '35-44'
        when cast(nullif(trim(agent_age), '') as integer) >= 45 then '45+'
        else 'Unknown'
    end as agent_age_group,

    case
        when cast(nullif(trim(agent_rating), '') as numeric(3,1)) between 4.0 and 4.5 then '4.0-4.5'
        when cast(nullif(trim(agent_rating), '') as numeric(3,1)) > 4.5 then '4.6-5.0'
        else 'Unknown'
    end as agent_rating_band

from amazon_delivery_staging
where trim(order_id) <> '';



-- checks

select count(*) from orders_clean;
select count(*) from delivery_clean;

select * from orders_clean limit 5;
select * from delivery_clean limit 5;