-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2023-12-19 06:48:15.262

-- tables
-- Table: dim_account_billing
CREATE TABLE dim_account_billing (
    account_billing_key int  NOT NULL IDENTITY,
    account_billed_date_key int  NOT NULL,
    account_billed_alias_name varchar(100)  NOT NULL,
    account_plan_name varchar(100)  NOT NULL,
    account_billed_amount decimal(19,4)  NOT NULL,
    CONSTRAINT dim_account_billing_pk PRIMARY KEY  (account_billing_key)
);

-- Table: dim_customers
CREATE TABLE dim_customers (
    customer_key int  NOT NULL,
    customer_email varchar(100)  NOT NULL,
    customer_firstname varchar(100)  NOT NULL,
    customer_lastname varchar(100)  NOT NULL,
    customer_address varchar(100)  NOT NULL,
    customer_city varchar(100)  NOT NULL,
    customer_state varchar(100)  NOT NULL,
    customer_zip varchar(100)  NOT NULL,
    customer_phone varchar(100)  NOT NULL,
    CONSTRAINT dim_customers_pk PRIMARY KEY  (customer_key)
);

-- Table: dim_date
CREATE TABLE dim_date (
    datekey int  NOT NULL IDENTITY,
    datevalue date  NOT NULL,
    day int  NOT NULL,
    month int  NOT NULL,
    year int  NOT NULL,
    quarter int  NOT NULL,
    dayofweek varchar(50)  NOT NULL,
    dayofyear int  NOT NULL,
    CONSTRAINT dim_date_pk PRIMARY KEY  (datekey)
);

-- Table: dim_employee
CREATE TABLE dim_employee (
    employee_key int  NOT NULL,
    employee_first_name varchar(100)  NOT NULL,
    employee_last_name varchar(100)  NOT NULL,
    employee_job_title varchar(100)  NOT NULL,
    employee_department varchar(100)  NOT NULL,
    CONSTRAINT dim_employee_pk PRIMARY KEY  (employee_key)
);

-- Table: dim_product
CREATE TABLE dim_product (
    product_key int  NOT NULL IDENTITY,
    product_name varchar(100)  NOT NULL,
    product_price money  NOT NULL,
    product_whole_sale_price money  NOT NULL,
    product_is_active bit  NOT NULL,
    product_description varchar(1000)  NULL,
    CONSTRAINT dim_product_pk PRIMARY KEY  (product_key)
);

-- Table: dim_titles
CREATE TABLE dim_titles (
    title_key int  NOT NULL,
    title_name varchar(100)  NOT NULL,
    title_type varchar(100)  NOT NULL,
    title_synopsis varchar(100)  NOT NULL,
    title_average_rating decimal(2,1)  NOT NULL,
    title_release_year int  NOT NULL,
    title_run_time int  NOT NULL,
    title_has_bluray bit  NOT NULL,
    title_has_dvd bit  NOT NULL,
    title_has_streaming bit  NOT NULL,
    title_genre varchar(100)  NOT NULL,
    title_date_modified_key int  NOT NULL,
    CONSTRAINT dim_titles_pk PRIMARY KEY  (title_key)
);

-- Table: fact_customer_demand
CREATE TABLE fact_customer_demand (
    average_rating decimal(2,1)  NOT NULL,
    view_count int  NOT NULL,
    average_billed_amount decimal(19,4)  NOT NULL,
    total_movie_purchases int  NOT NULL,
    total_movie_purchases_by_genre int  NOT NULL,
    purchase_date_key int  NOT NULL,
    account_billing_key int  NOT NULL,
    title_key int  NOT NULL,
    CONSTRAINT fact_customer_demand_pk PRIMARY KEY  (account_billing_key,title_key,purchase_date_key)
);

-- Table: fact_orders
CREATE TABLE fact_orders (
    order_quantity int  NOT NULL,
    order_days_elapsed_order_shipped int  NOT NULL,
    order_shipped_date int  NOT NULL,
    order_date int  NOT NULL,
    customer_key int  NOT NULL,
    ship_via varchar(100)  NOT NULL,
    CONSTRAINT fact_orders_pk PRIMARY KEY  (customer_key,order_date,order_shipped_date)
);

-- Table: fact_payroll
CREATE TABLE fact_payroll (
    hours decimal(4,2)  NOT NULL,
    hourly_rate decimal(5,2)  NOT NULL,
    compensation decimal(19,4)  NOT NULL,
    employee_key int  NOT NULL,
    payroll_date_key int  NOT NULL,
    CONSTRAINT fact_payroll_pk PRIMARY KEY  (payroll_date_key,employee_key)
);

-- Table: fact_sales
CREATE TABLE fact_sales (
    quantity int  NOT NULL,
    total_amount decimal(19,4)  NOT NULL,
    unit_price decimal(19,4)  NOT NULL,
    product_key int  NOT NULL,
    order_date_key int  NOT NULL,
    CONSTRAINT fact_sales_pk PRIMARY KEY  (product_key,order_date_key)
);

-- foreign keys
-- Reference: dim_account_billing_dim_date (table: dim_account_billing)
ALTER TABLE dim_account_billing ADD CONSTRAINT dim_account_billing_dim_date
    FOREIGN KEY (account_billed_date_key)
    REFERENCES dim_date (datekey);

-- Reference: dim_titles_dim_date (table: dim_titles)
ALTER TABLE dim_titles ADD CONSTRAINT dim_titles_dim_date
    FOREIGN KEY (title_date_modified_key)
    REFERENCES dim_date (datekey);

-- Reference: fact_customer_demand_dim_account_billing (table: fact_customer_demand)
ALTER TABLE fact_customer_demand ADD CONSTRAINT fact_customer_demand_dim_account_billing
    FOREIGN KEY (account_billing_key)
    REFERENCES dim_account_billing (account_billing_key);

-- Reference: fact_customer_demand_dim_date (table: fact_customer_demand)
ALTER TABLE fact_customer_demand ADD CONSTRAINT fact_customer_demand_dim_date
    FOREIGN KEY (purchase_date_key)
    REFERENCES dim_date (datekey);

-- Reference: fact_customer_demand_dim_titles (table: fact_customer_demand)
ALTER TABLE fact_customer_demand ADD CONSTRAINT fact_customer_demand_dim_titles
    FOREIGN KEY (title_key)
    REFERENCES dim_titles (title_key);

-- Reference: fact_orders_dim_customers (table: fact_orders)
ALTER TABLE fact_orders ADD CONSTRAINT fact_orders_dim_customers
    FOREIGN KEY (customer_key)
    REFERENCES dim_customers (customer_key);

-- Reference: fact_payroll_dim_date (table: fact_payroll)
ALTER TABLE fact_payroll ADD CONSTRAINT fact_payroll_dim_date
    FOREIGN KEY (payroll_date_key)
    REFERENCES dim_date (datekey);

-- Reference: fact_payroll_dim_employee (table: fact_payroll)
ALTER TABLE fact_payroll ADD CONSTRAINT fact_payroll_dim_employee
    FOREIGN KEY (employee_key)
    REFERENCES dim_employee (employee_key);

-- Reference: fact_sales_dim_date (table: fact_sales)
ALTER TABLE fact_sales ADD CONSTRAINT fact_sales_dim_date
    FOREIGN KEY (order_date_key)
    REFERENCES dim_date (datekey);

-- Reference: fact_sales_dim_product (table: fact_sales)
ALTER TABLE fact_sales ADD CONSTRAINT fact_sales_dim_product
    FOREIGN KEY (product_key)
    REFERENCES dim_product (product_key);

-- Reference: order_date (table: fact_orders)
ALTER TABLE fact_orders ADD CONSTRAINT order_date
    FOREIGN KEY (order_date)
    REFERENCES dim_date (datekey);

-- Reference: order_shipped_date (table: fact_orders)
ALTER TABLE fact_orders ADD CONSTRAINT order_shipped_date
    FOREIGN KEY (order_shipped_date)
    REFERENCES dim_date (datekey);

-- End of file.

