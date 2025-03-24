-- Crear base de datos en MySQL
CREATE DATABASE IF NOT EXISTS sales_cycle;
USE sales_cycle;

-- Versión: 1.0
-- Fecha: 2025-03-24
-- Autor: Maria Ballesteros
-- Descripción: Script de transformación + análisis para dataset Sales Cycle


SET SQL_SAFE_UPDATES = 0;

-- Para la tabla "customers"
-- Actualizar únicamente los registros en los que las fechas contengan '/', para corregir fechas que vienen asi 2016-07-01	
UPDATE customers_csv
SET birthdate = STR_TO_DATE(NULLIF(TRIM(birthdate), ''), '%d/%m/%Y')
WHERE birthdate LIKE '%/%';

UPDATE customers_csv
SET datefirstpurchase = STR_TO_DATE(NULLIF(TRIM(datefirstpurchase), ''), '%d/%m/%Y')
WHERE datefirstpurchase LIKE '%/%';

ALTER TABLE customers_csv
  MODIFY customer_id INT,
  MODIFY geography_id INT,
  MODIFY birthdate DATE,
  MODIFY maritalstatus VARCHAR(2),
  MODIFY gender CHAR(1),
  MODIFY datefirstpurchase DATE;

-- Para la tabla "dim_geography"
ALTER TABLE dim_geography
  MODIFY geography_id INT,
  MODIFY city VARCHAR(100),
  MODIFY state_province_code VARCHAR(10),
  MODIFY state_province_name VARCHAR(100),
  MODIFY country_region_code VARCHAR(10),
  MODIFY english_country_region_name VARCHAR(100),
  MODIFY postal_code VARCHAR(20);

-- Para la tabla "dim_product"
ALTER TABLE dim_product
  MODIFY product_id INT,
  MODIFY product_name VARCHAR(255),
  MODIFY model_name VARCHAR(255),
  MODIFY color VARCHAR(50),
  MODIFY size_range VARCHAR(50),
  MODIFY cost DECIMAL(10,2),
  MODIFY normal_price DECIMAL(10,2),
  MODIFY sub_category VARCHAR(100),
  MODIFY category VARCHAR(100);

-- Para la tabla "dim_territory"
ALTER TABLE dim_territory
  MODIFY territory_id INT,
  MODIFY region VARCHAR(50),
  MODIFY country VARCHAR(100);

-- Para la tabla "fact_sales"
UPDATE fact_sales
SET order_date = STR_TO_DATE(NULLIF(TRIM(order_date), ''), '%d/%m/%Y')
WHERE order_date LIKE '%/%';

ALTER TABLE fact_sales
  MODIFY order_detail_id VARCHAR(50),
  MODIFY order_date DATE,
  MODIFY product_id INT,
  MODIFY customer_id INT,
  MODIFY territory_id INT,
  MODIFY sales_order_number VARCHAR(50),
  MODIFY sales_order_line_number INT,
  MODIFY quantity INT,
  MODIFY unitprice_rupiah DECIMAL(15,2),
  MODIFY totalprice_rupiah DECIMAL(15,2),
  MODIFY totalcost_rupiah DECIMAL(15,2),
  MODIFY shippingprice_rupiah DECIMAL(15,2);




----------------------------------------------------------
#Tipo de datos
SELECT 
  TABLE_NAME, 
  COLUMN_NAME, 
  DATA_TYPE
FROM information_schema.columns
WHERE table_schema = 'sales_cycle'
ORDER BY TABLE_NAME, ORDINAL_POSITION;


-- Agregar columnas para precios en euros en tabla fact_sales
ALTER TABLE fact_sales
ADD COLUMN unitprice_euros DECIMAL(15,2),
ADD COLUMN totalprice_euros DECIMAL(15,2),
ADD COLUMN totalcost_euros DECIMAL(15,2),
ADD COLUMN shippingprice_euros DECIMAL(15,2);

-- Agregar columnas para precios en euros en tabla dim_product
ALTER TABLE dim_product
ADD COLUMN cost_euros DECIMAL(15,2),
ADD COLUMN normalprice_euros DECIMAL(15,2);


-- Actualizar las nuevas columnas usando la tasa de conversión (supongamos 1 EUR = 16,000 IDR) redondear a 2 decimales antes de asignar el valor
UPDATE fact_sales
SET unitprice_euros = ROUND(unitprice_rupiah / 16000, 2),
    totalprice_euros = ROUND(totalprice_rupiah / 16000, 2),
    totalcost_euros = ROUND(totalcost_rupiah / 16000, 2),
    shippingprice_euros = ROUND(shippingprice_rupiah / 16000, 2);
    
    -- Actualizar las nuevas columnas usando la tasa de conversión (supongamos 1 EUR = 16,000 IDR) redondear a 2 decimales antes de asignar el valor
UPDATE dim_product
SET cost_euros = ROUND(cost / 16000, 2),
    normalprice_euros = ROUND(normal_price / 16000, 2);

SET SQL_SAFE_UPDATES = 1;

CREATE OR REPLACE VIEW fact_sales_euros AS
SELECT 
  order_detail_id,
  order_date,
  product_id,
  customer_id,
  territory_id,
  sales_order_number,
  sales_order_line_number,
  quantity,
  unitprice_euros,
  totalprice_euros,
  totalcost_euros,
  shippingprice_euros
FROM fact_sales;

CREATE TABLE fact_sales_euros_table AS
SELECT *
FROM fact_sales_euros;


CREATE OR REPLACE VIEW dim_product_euros AS
SELECT 
  product_id,
  product_name,
  model_name,
  color,
  size_range,
  cost_euros,
  normalprice_euros,
  sub_category,
  category
FROM dim_product;

CREATE TABLE dim_products_euros_table AS
SELECT *
FROM dim_product_euros;



#Numero de registros por tabla
SELECT TABLE_NAME, TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'sales_cycle'
ORDER BY TABLE_NAME;


#CREACION DE CLAVES FORANEAS SE TIENE QUE HACER DE ESTA MANERA PORQUE POR EJEMPLO ESTE DATASET TENDRIA MAL QUE HAY CLAVES FORANEAS EN CUSTOMERS QUE NO HAN 
#SIDO DADAS DE ALTA EN LA TABLA ORIGINAL, DIM_GEOGRAPHY
SELECT c.geography_id
FROM customers_csv c
LEFT JOIN dim_geography g 
  ON c.geography_id = g.geography_id
WHERE g.geography_id IS NULL
  AND c.geography_id IS NOT NULL;

SET FOREIGN_KEY_CHECKS = 0;
ALTER TABLE customers_csv
ADD CONSTRAINT fk_customers_geography
  FOREIGN KEY (geography_id)
  REFERENCES dim_geography(geography_id);
  
  SET FOREIGN_KEY_CHECKS = 1;


SET FOREIGN_KEY_CHECKS = 0;
ALTER TABLE fact_sales_euros_table
  ADD CONSTRAINT fk_fse_product
    FOREIGN KEY (product_id) 
    REFERENCES dim_products_euros_table(product_id),
  ADD CONSTRAINT fk_fse_customer
    FOREIGN KEY (customer_id) 
    REFERENCES customers_csv(customer_id),
  ADD CONSTRAINT fk_fse_territory
    FOREIGN KEY (territory_id)
    REFERENCES dim_territory(territory_id);
SET FOREIGN_KEY_CHECKS = 1;


#HACEMOS EER

--------------------------------------------------------



#ANALISIS

#Ventas mensuales (por año y mes)
SELECT 
    YEAR(fse.order_date) AS year,
    MONTH(fse.order_date) AS mes,
    FORMAT(SUM(fse.totalprice_euros), 2) AS total_ventas
FROM fact_sales_euros_table fse
GROUP BY year, mes
ORDER BY year, mes;

#Ventas anuales (por año) NO SE PUEDEN SACAR CONCLUSIONES CLARAS PORQUE SOLO HAY UN AÑO ENTERO
SELECT 
    YEAR(fse.order_date) AS year,
    FORMAT(SUM(fse.totalprice_euros), 2) AS total_ventas
FROM fact_sales_euros_table fse
GROUP BY year
ORDER BY year;



#conocer el total de ventas en cada región
SELECT 
    dt.region, 
    SUM(fse.totalprice_euros) AS total_ventas
FROM fact_sales_euros_table fse
JOIN dim_territory dt 
    ON fse.territory_id = dt.territory_id
GROUP BY dt.region
ORDER BY total_ventas DESC;



# Top 10 productos con mayores ventas totales
SELECT 
    dp.product_name,
    dp.category,
    FORMAT(SUM(fse.totalprice_euros), 2) AS total_ventas
FROM fact_sales_euros_table fse
JOIN dim_products_euros_table dp 
    ON fse.product_id = dp.product_id
GROUP BY dp.product_id, dp.product_name, dp.category
ORDER BY SUM(fse.totalprice_euros) DESC
LIMIT 10;


# Top categrias con mayores ventas totales

SELECT 
    dp.category, 
    FORMAT(SUM(fse.totalprice_euros), 2) AS total_ventas
FROM fact_sales_euros_table fse
JOIN dim_products_euros_table dp 
    ON fse.product_id = dp.product_id
GROUP BY dp.category
ORDER BY SUM(fse.totalprice_euros) DESC;
