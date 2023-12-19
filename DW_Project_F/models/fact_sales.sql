with
    stg_products as (
        select
            product_id,
            {{ dbt_utils.generate_surrogate_key(["product_id"]) }} as productkey,
            product_name,
            product_wholesale_price
        from {{ source("fudgemart_v3", "Products") }}
    ),
    stg_orders as 
    (
        select
            order_id,  
            replace(to_date(order_date)::varchar,'-','')::int as orderdatekey
        from {{source('fudgemart_v3','Orders')}}
    ),
    stg_order_details as (
        select
            order_id,
            product_id,
            sum(quantity) as quantity
        from {{ source("fudgemart_v3", "OrderDetails") }}
        group by order_id, product_id
    )
 
select
    p.productkey,
    od.quantity,
    p.product_wholesale_price as unit_price,
    p.product_wholesale_price * od.quantity as total_amount,
    o.orderdatekey
from stg_products p
join stg_order_details od on p.product_id = od.product_id
join stg_orders o on o.order_id = od.order_id