with f_order_fulfillment as (
    select * from {{ ref('fact_order_fulfillment') }}
),
d_customers as (
    select * from {{ ref('dim_customers') }}
),
d_date as (
    select * from {{ ref('dim_date') }}
)
select 
    d_customers.*,  
    d_date.*,
    f.order_id, f.orderdatekey, f.shippeddatekey, f.order_days_elapsed_order_shipped, f.ship_via
    from f_order_fulfillment as f
    left join d_customers on f.customerkey = d_customers.customerkey
    left join d_date on f.orderdatekey = d_date.datekey
