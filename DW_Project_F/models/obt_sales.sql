WITH
f_sales AS (
    SELECT * FROM {{ ref('fact_sales') }}
),
d_date AS (
    SELECT * FROM {{ ref('dim_date') }}
),
d_product AS (
    SELECT * FROM {{ ref('dim_products') }}
)
 
SELECT
    d_date.*,
    d_product.*,
    f.quantity,
    f.total_amount,
    f.unit_price
FROM f_sales AS f
LEFT JOIN d_date ON f.orderdatekey = d_date.datekey
LEFT JOIN d_product ON f.productkey = d_product.productkey