with stg_orders as 
(
    select
        order_id,  
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customerkey, 
        replace(to_date(order_date)::varchar,'-','')::int as orderdatekey,
        replace(to_date(shipped_date)::varchar,'-','')::int as shippeddatekey,
        ship_via
    from {{source('fudgemart_v3','Orders')}}
)
select  
    o.*,
    1 as quantity,
    o.shippeddatekey - o.orderdatekey as order_days_elapsed_order_shipped
from stg_orders o