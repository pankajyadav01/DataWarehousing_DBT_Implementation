WITH
f_sales AS (
    SELECT * FROM {{ ref('fact_sales') }}
),
d_customer AS (
    SELECT * FROM {{ ref('dim_customer') }}
),
d_employee AS (
    SELECT * FROM {{ ref('dim_employee') }}
),
d_date AS (
    SELECT * FROM {{ ref('dim_date') }}
),
d_product AS (
    SELECT * FROM {{ ref('dim_product') }}
)
 
SELECT
    d_customer.*,
    d_employee.*,
    d_date.*,
    d_product.*,
    f.orderid,
    f.quantityonorder,
    f.extendedpriceamount,
    f.discountamount,
    f.soldamount
FROM f_sales AS f
LEFT JOIN d_customer ON f.customerkey = d_customer.customerkey
LEFT JOIN d_employee ON f.employeekey = d_employee.employeekey
LEFT JOIN d_date ON f.orderdatekey = d_date.datekey
LEFT JOIN d_product ON f.productkey = d_product.productkey