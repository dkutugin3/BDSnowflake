SELECT COUNT(*) AS mock_data_rows FROM mock_data;

SELECT source_file, COUNT(*) AS rows_count
FROM mock_data
GROUP BY source_file
ORDER BY source_file;

SELECT 'dim_date' AS table_name, COUNT(*) AS rows_count FROM dim_date
UNION ALL SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL SELECT 'dim_seller', COUNT(*) FROM dim_seller
UNION ALL SELECT 'dim_store', COUNT(*) FROM dim_store
UNION ALL SELECT 'dim_supplier', COUNT(*) FROM dim_supplier
UNION ALL SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL SELECT 'fact_sales', COUNT(*) FROM fact_sales
ORDER BY table_name;

SELECT
    d.year,
    d.month,
    p.category AS product_category,
    SUM(f.sale_quantity) AS sold_quantity,
    SUM(f.sale_total_price) AS sales_amount
FROM fact_sales f
JOIN dim_date d ON d.date_id = f.date_id
JOIN dim_product p ON p.product_id = f.product_id
GROUP BY d.year, d.month, p.category
ORDER BY d.year, d.month, sales_amount DESC;

SELECT
    s.country AS store_country,
    SUM(f.sale_total_price) AS sales_amount
FROM fact_sales f
JOIN dim_store s ON s.store_id = f.store_id
GROUP BY s.country
ORDER BY sales_amount DESC
LIMIT 10;
