-- create staging tables

drop table if exists amazon_orders_staging;
drop table if exists amazon_delivery_staging;

create table amazon_orders_staging (
    order_id text,
    order_date text,
    shipment_id text,
    shipment_date text,
    posted_date text,
    fulfillment text,
    asin text,
    sku text,
    transaction_type text,
    tax_collection_model text,
    quantity text,
    display_price text,
    taxexclusive_selling_price text,
    total_tax_collected_by_amazon text,
    financial_component text,
    ship_from_city text,
    ship_from_state text,
    ship_from_country text,
    ship_from_postal_code text,
    ship_from_tax_location_code text,
    ship_to_city text,
    ship_to_state text,
    ship_to_country text,
    ship_to_postal_code text,
    ship_to_location_code text,
    taxed_location_code text,
    tax_address_role text,
    jurisdiction_level text,
    jurisdiction_name text,
    tax_amount_collected_by_amazon text,
    taxed_jurisdiction_tax_rate text,
    tax_type text,
    taxable_amount text
);

create table amazon_delivery_staging (
    order_id text,
    agent_age text,
    agent_rating text,
    store_latitude text,
    store_longitude text,
    drop_latitude text,
    drop_longitude text,
    order_date text,
    order_time text,
    pickup_time text,
    weather text,
    traffic text,
    vehicle text,
    area text,
    delivery_time text,
    category text
);


select count(*) from amazon_orders_staging;
select count(*) from amazon_delivery_staging;

select * from amazon_orders_staging limit 5;
select * from amazon_delivery_staging limit 5;