-- RAW.CONFORMED.DATEDIMENSIONRAW.CONFORMED.DATEDIMENSION
-- create databases
create database if not exists analytics;
create database if not exists raw;

--create schemas
create schema if not exists analytics.fudgecompanies;
create schema if not exists raw.conformed;
create schema if not exists raw.fudgemart_v3;
create schema if not exists raw.fudgeflix_v3;

-- define file formats
create or replace file format RAW.PUBLIC.PARQUET 
    TYPE = parquet
    REPLACE_INVALID_CHARACTERS = TRUE;

create or replace file format RAW.PUBLIC.JSONARRAY 
    TYPE = json
    STRIP_OUTER_ARRAY = TRUE;

create or replace file format RAW.PUBLIC.JSON
    TYPE = json
    STRIP_OUTER_ARRAY = FALSE;

create or replace file format RAW.PUBLIC.CSVHEADER
    TYPE = 'csv'
    FIELD_DELIMITER  = ','
    SKIP_HEADER=1;
    
create or replace file format RAW.PUBLIC.CSV
    TYPE = csv
    FIELD_DELIMITER  = ','
    PARSE_HEADER = FALSE
    SKIP_HEADER  = 0;  


-- create stages
-- varying file formats
CREATE or replace STAGE RAW.PUBLIC.externalworld_files
  URL = 'azure://externalworld.blob.core.windows.net/files/';

-- these are all parquet file formats
CREATE or replace STAGE RAW.PUBLIC.externalworld_database
  URL = 'azure://externalworld.blob.core.windows.net/database/'
  FILE_FORMAT = RAW.PUBLIC.PARQUET ;


-- stage the date dimension
CREATE or REPLACE TABLE raw.conformed.datedimension (
    datekey int
    ,date date
    ,datetime timestamp
    ,year int
    ,quarter int
    ,quartername varchar(2)
    ,month int
    ,monthname varchar(3)
    ,day int
    ,dayofweek int
    ,dayname varchar(3)
    ,weekday varchar(1)
    ,weekofyear int
    ,dayofyear int
) AS
    WITH CTE_MY_DATE AS (
    SELECT DATEADD(DAY, SEQ4(), '1990-01-01 00:00:00') AS MY_DATE
    FROM TABLE(GENERATOR(ROWCOUNT=>365*40))
    )
    SELECT
    REPLACE(TO_DATE(MY_DATE)::varchar,'-','')::int  as datekey,
    TO_DATE(MY_DATE) as date
    ,TO_TIMESTAMP(MY_DATE) as datetime
    ,YEAR(MY_DATE) as year
    ,QUARTER(MY_DATE) as quarter
    ,CONCAT('Q', QUARTER(MY_DATE)::varchar) as quartername
    ,MONTH(MY_DATE) as month
    ,MONTHNAME(MY_DATE) as monthname
    ,DAY(MY_DATE) as day
    ,DAYOFWEEK(MY_DATE) as dayofweek
    ,DAYNAME(MY_DATE) as dayname
    ,case when DAYOFWEEK(MY_DATE) between 1 and 5 then 'Y' else 'N' end as weekday
    ,WEEKOFYEAR(MY_DATE) as weekofyear
    ,DAYOFYEAR(MY_DATE) as dayofyear
    FROM CTE_MY_DATE
    ;

-------------------------------------------------------------------

-- Checking Table names in the Azure Stage Env
-- list '@RAW.PUBLIC.externalworld_database/' 

-------------------------------------------------------------------


-- stage fudgemart customers
create or replace table RAW.FUDGEMART_V3.customers
(
    customer_id varchar,
    customer_email varchar,
    customer_firstname varchar,
    customer_lastname varchar,
    customer_address varchar,
    customer_city varchar,
    customer_state varchar,
    customer_zip varchar,
    customer_phone varchar,
    customer_fax varchar
);
copy into RAW.fudgemart_v3.customers
    FROM '@RAW.PUBLIC.externalworld_database/fudgemart_v3.fm_customers.parquet' 
    MATCH_BY_COLUMN_NAME='CASE_INSENSITIVE';

----------------------------------------------------------------------

 -- Stage Fudgemart Orders
create or replace table RAW.FUDGEMART_V3.orders
(
    order_id int,
    customer_id int,
    order_date varchar,
    shipped_date varchar,
    ship_via varchar,
    creditcard_id int
);
copy into RAW.fudgemart_v3.orders
    FROM '@RAW.PUBLIC.externalworld_database/fudgemart_v3.fm_orders.parquet' 
    MATCH_BY_COLUMN_NAME='CASE_INSENSITIVE';

--------------------------------------------------------------------------------------------------------------

-- Stage Fudgemart Sales

create or replace table RAW.FUDGEMART_V3.products
(
    product_id int IDENTITY(1,1),
    product_department varchar(20),
    product_name varchar(50),
    product_retail_price double,
    product_wholesale_price double,
    product_is_active int,
    product_add_date varchar,
    product_vendor_id int,
    product_description varchar(1000)
);
copy into RAW.fudgemart_v3.products
    FROM '@RAW.PUBLIC.externalworld_database/fudgemart_v3.fm_products.parquet' 
    MATCH_BY_COLUMN_NAME='CASE_INSENSITIVE';

----------------------------------------------------------------------------------------

-- stage fudgemart order_detals

create or replace table RAW.FUDGEMART_V3.OrderDetails
(
    product_id int,
    order_id int,
    quantity int
);
copy into RAW.fudgemart_v3.OrderDetails
    FROM '@RAW.PUBLIC.externalworld_database/fudgemart_v3.fm_order_details.parquet' 
    MATCH_BY_COLUMN_NAME='CASE_INSENSITIVE';


-- azure://externalworld.blob.core.windows.net/database/fudgemart_v3.fm_orders.parquet
-- azure://externalworld.blob.core.windows.net/database/fudgemart_v3.fm_customers.parquet
