CREATE TABLE IF NOT EXISTS dim_date (
    date_id DATE PRIMARY KEY,
    year INTEGER NOT NULL,
    quarter INTEGER NOT NULL,
    month INTEGER NOT NULL,
    day INTEGER NOT NULL,
    week INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id BIGSERIAL PRIMARY KEY,
    source_customer_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER,
    email TEXT NOT NULL UNIQUE,
    country TEXT,
    postal_code TEXT,
    pet_type TEXT,
    pet_name TEXT,
    pet_breed TEXT,
    pet_category TEXT
);

CREATE TABLE IF NOT EXISTS dim_seller (
    seller_id BIGSERIAL PRIMARY KEY,
    source_seller_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    email TEXT NOT NULL UNIQUE,
    country TEXT,
    postal_code TEXT
);

CREATE TABLE IF NOT EXISTS dim_store (
    store_id BIGSERIAL PRIMARY KEY,
    store_name TEXT,
    location TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    phone TEXT,
    email TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_supplier (
    supplier_id BIGSERIAL PRIMARY KEY,
    supplier_name TEXT,
    contact_name TEXT,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    address TEXT,
    city TEXT,
    country TEXT
);

CREATE TABLE IF NOT EXISTS dim_product (
    product_id BIGSERIAL PRIMARY KEY,
    source_row_id BIGINT NOT NULL UNIQUE REFERENCES mock_data(source_row_id),
    source_product_id INTEGER,
    product_name TEXT,
    category TEXT,
    price NUMERIC(12, 2),
    stock_quantity INTEGER,
    weight NUMERIC(12, 2),
    color TEXT,
    size TEXT,
    brand TEXT,
    material TEXT,
    description TEXT,
    rating NUMERIC(3, 1),
    reviews INTEGER,
    release_date DATE,
    expiry_date DATE
);

CREATE TABLE IF NOT EXISTS fact_sales (
    sale_id BIGSERIAL PRIMARY KEY,
    source_row_id BIGINT NOT NULL UNIQUE REFERENCES mock_data(source_row_id),
    source_file TEXT NOT NULL,
    source_id INTEGER NOT NULL,
    date_id DATE NOT NULL REFERENCES dim_date(date_id),
    customer_id BIGINT NOT NULL REFERENCES dim_customer(customer_id),
    seller_id BIGINT NOT NULL REFERENCES dim_seller(seller_id),
    product_id BIGINT NOT NULL REFERENCES dim_product(product_id),
    store_id BIGINT NOT NULL REFERENCES dim_store(store_id),
    supplier_id BIGINT NOT NULL REFERENCES dim_supplier(supplier_id),
    sale_quantity INTEGER NOT NULL,
    sale_total_price NUMERIC(12, 2) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_fact_sales_date_id ON fact_sales(date_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_customer_id ON fact_sales(customer_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_seller_id ON fact_sales(seller_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_product_id ON fact_sales(product_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_store_id ON fact_sales(store_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_supplier_id ON fact_sales(supplier_id);
