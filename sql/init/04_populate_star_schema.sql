TRUNCATE TABLE
    fact_sales,
    dim_product,
    dim_supplier,
    dim_store,
    dim_seller,
    dim_customer,
    dim_date
RESTART IDENTITY CASCADE;

INSERT INTO dim_date (date_id, year, quarter, month, day, week, day_of_week)
SELECT DISTINCT sale_date AS date_id,
       EXTRACT(YEAR FROM sale_date)::INTEGER,
       EXTRACT(QUARTER FROM sale_date)::INTEGER,
       EXTRACT(MONTH FROM sale_date)::INTEGER,
       EXTRACT(DAY FROM sale_date)::INTEGER,
       EXTRACT(WEEK FROM sale_date)::INTEGER,
       EXTRACT(ISODOW FROM sale_date)::INTEGER
FROM mock_data
WHERE sale_date IS NOT NULL
ORDER BY sale_date;

INSERT INTO dim_customer (
    source_customer_id,
    first_name,
    last_name,
    age,
    email,
    country,
    postal_code,
    pet_type,
    pet_name,
    pet_breed,
    pet_category
)
SELECT DISTINCT ON (customer_email)
    sale_customer_id,
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_country,
    customer_postal_code,
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed,
    pet_category
FROM mock_data
WHERE customer_email IS NOT NULL AND btrim(customer_email) <> ''
ORDER BY customer_email, source_file, id;

INSERT INTO dim_seller (
    source_seller_id,
    first_name,
    last_name,
    email,
    country,
    postal_code
)
SELECT DISTINCT ON (seller_email)
    sale_seller_id,
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code
FROM mock_data
WHERE seller_email IS NOT NULL AND btrim(seller_email) <> ''
ORDER BY seller_email, source_file, id;

INSERT INTO dim_store (
    store_name,
    location,
    city,
    state,
    country,
    phone,
    email
)
SELECT DISTINCT ON (store_email)
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
FROM mock_data
WHERE store_email IS NOT NULL AND btrim(store_email) <> ''
ORDER BY store_email, source_file, id;

INSERT INTO dim_supplier (
    supplier_name,
    contact_name,
    email,
    phone,
    address,
    city,
    country
)
SELECT DISTINCT ON (supplier_email)
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM mock_data
WHERE supplier_email IS NOT NULL AND btrim(supplier_email) <> ''
ORDER BY supplier_email, source_file, id;

INSERT INTO dim_product (
    source_row_id,
    source_product_id,
    product_name,
    category,
    price,
    stock_quantity,
    weight,
    color,
    size,
    brand,
    material,
    description,
    rating,
    reviews,
    release_date,
    expiry_date
)
SELECT
    source_row_id,
    sale_product_id,
    product_name,
    product_category,
    product_price,
    product_quantity,
    product_weight,
    product_color,
    product_size,
    product_brand,
    product_material,
    product_description,
    product_rating,
    product_reviews,
    product_release_date,
    product_expiry_date
FROM mock_data;

INSERT INTO fact_sales (
    source_row_id,
    source_file,
    source_id,
    date_id,
    customer_id,
    seller_id,
    product_id,
    store_id,
    supplier_id,
    sale_quantity,
    sale_total_price
)
SELECT
    m.source_row_id,
    m.source_file,
    m.id,
    m.sale_date,
    c.customer_id,
    s.seller_id,
    p.product_id,
    st.store_id,
    sup.supplier_id,
    m.sale_quantity,
    m.sale_total_price
FROM mock_data m
JOIN dim_customer c ON c.email = m.customer_email
JOIN dim_seller s ON s.email = m.seller_email
JOIN dim_store st ON st.email = m.store_email
JOIN dim_supplier sup ON sup.email = m.supplier_email
JOIN dim_product p ON p.source_row_id = m.source_row_id;

DO $$
DECLARE
    sales_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO sales_count FROM fact_sales;
    IF sales_count <> (SELECT COUNT(*) FROM mock_data) THEN
        RAISE EXCEPTION 'Expected % fact rows, got %', (SELECT COUNT(*) FROM mock_data), sales_count;
    END IF;
END $$;
