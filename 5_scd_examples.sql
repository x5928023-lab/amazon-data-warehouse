-- scd type 2 example for dim_destination_location

create table destination_location_delta (
    ship_to_country text,
    ship_to_state text,
    ship_to_city text,
    ship_to_postal_code text
);

insert into destination_location_delta
values
('US', 'CA', 'Los Angeles', '90001'),
('US', 'TX', 'Houston', '77001'),
('US', 'NY', 'Buffalo', '14201');

select *
from dim_destination_location
where (ship_to_state = 'CA' and ship_to_city = 'Los Angeles')
   or (ship_to_state = 'TX' and ship_to_city = 'Houston')
   or (ship_to_state = 'NY' and ship_to_city = 'Buffalo')
order by ship_to_state, ship_to_city, start_date;

-- expire old record if destination changed

update dim_destination_location d
set
    end_date = current_date,
    current_flag = 'N'
from destination_location_delta x
where d.ship_to_country = x.ship_to_country
  and d.ship_to_state = x.ship_to_state
  and d.ship_to_city = x.ship_to_city
  and d.current_flag = 'Y'
  and d.ship_to_postal_code <> x.ship_to_postal_code;



-- insert new current record

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
select
    x.ship_to_country,
    x.ship_to_state,
    x.ship_to_city,
    x.ship_to_postal_code,
    current_date,
    null,
    'Y'
from destination_location_delta x
left join dim_destination_location d
    on x.ship_to_country = d.ship_to_country
   and x.ship_to_state = d.ship_to_state
   and x.ship_to_city = d.ship_to_city
   and x.ship_to_postal_code = d.ship_to_postal_code
   and d.current_flag = 'Y'
where d.destination_location_key is null;



-- check scd2 result

select *
from dim_destination_location
order by ship_to_state, ship_to_city, start_date;



-- scd type 3 example for dim_fulfillment

create table fulfillment_delta (
    new_fulfillment_type text,
    old_fulfillment_type text
);

insert into fulfillment_delta
values
('AMAZON_FRESH', 'AMAZON'),
('MERCHANT_FULFILLED', 'SELLER');

select *
from dim_fulfillment
where current_fulfillment_type in ('AFN', 'MFN')
order by fulfillment_key;



update dim_fulfillment f
set
    previous_fulfillment_type = f.current_fulfillment_type,
    current_fulfillment_type = d.new_fulfillment_type
from fulfillment_delta d
where f.current_fulfillment_type = d.old_fulfillment_type;


-- check scd3 result

select *
from dim_fulfillment
order by fulfillment_key;