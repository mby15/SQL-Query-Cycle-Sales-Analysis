# 🛍️ Sales Cycle: Análisis de Ventas con ETL + MySQL + Modelo Estrella EER + Tableau

**Autora:** María Ballesteros  

Este proyecto realiza un análisis del ciclo de ventas de una empresa de artículos de ciclismo, a partir de un repositorio público. El objetivo es construir un pipeline ETL que prepare los datos para análisis profundo, tanto en SQL como en herramientas de visualización como Tableau.

---

## 🌐 Fuente de Datos

Los archivos CSV utilizados en este proyecto provienen del repositorio público:  
🔗 [SQL-Query-Bee-Cycle-Sales-Analysis (GitHub)](https://github.com/aldimeolaalfarisy/SQL-Query-Bee-Cycle-Sales-Analysis)

Archivo customers_csv.csv contiene 1360 registros. <br>
Archivo dim_geography.csv contiene 654 registros.<br>
Archivo dim_product.csv contiene 397 registros.<br>
Archivo dim_territory.csv contiene 11 registros.<br>
Archivo fact_sales.csv contiene 5954 registros.<br>
<br>

---

## 🔄 Proceso seguido paso a paso

### 1. 🔍 Exploración inicial de los CSVs en NoteBook de VS Code Python
- Revisión del contenido, campos disponibles, tipos de datos y delimitadores.

### 2. 🧱 Creación de base de datos local
- Se construyó una base de datos **SQLite** llamada `cycle_sales.db`.

### 3. 📁 Carga de CSVs a SQLite
- Se detectó automáticamente el delimitador (`;` o `,`) en cada archivo.
- Se limpiaron nombres de columnas y se crearon las tablas correspondientes.

### 4. 💾 Generación de archivo SQL
- Se usó `sqlite3 .dump` para convertir la base SQLite a un archivo SQL plano (`cycle_sales_export.sql`).

### 5. 🧹 Limpieza para compatibilidad con MySQL
Se creó un script en Python (`clean_sql_for_mysql.py`) que:
- Detecta y decodifica correctamente el archivo en `UTF-16`
- Reemplaza comillas dobles (`"`) por comillas invertidas (`` ` ``)
- Cambia tipos de datos genéricos (`TEXT`, `INTEGER`) por tipos de MySQL (`VARCHAR`, `INT`, etc.)
- Añade instrucciones para crear y usar la base de datos `sales_cycle`

Resultado: un archivo limpio y listo para importar en MySQL → `cycle_sales_export_mysql.sql`.

### 6. 🧾 Segunda fase: transformación en MySQL

Se creó un segundo script SQL (`transform_analysis.sql`) que:

- Convierte fechas que estaban en formato `dd/mm/yyyy`
- Ajusta todos los tipos de datos (`DATE`, `DECIMAL`, etc.)
- Crea nuevas columnas para convertir precios de rupias indonesias a euros (1 EUR = 16,000 IDR)
- Genera vistas y tablas nuevas para análisis en euros
- Relaciona las tablas mediante **claves foráneas**
- Ejecuta consultas para análisis como:
--> Ventas mensuales (por año y mes) NO SE PUEDEN SACAR CONCLUSIONES CLARAS PORQUE SOLO HAY UN AÑO ENTERO<br>
--> Conocer el total de ventas en cada región<br>
--> Top 10 productos con mayores ventas totales<br>
--> Top categrias con mayores ventas totales<br>
<br>
## 🧩 Modelo de Datos (Esquema Estrella)

Se modelaron los datos como un **esquema en estrella**, con una tabla de hechos `fact_sales_euros_table` conectada a dimensiones:

- `dim_products_euros_table`
- `customers_csv` → `dim_geography`
- `dim_territory`

📌 Vista del modelo EER (generado en MySQL Workbench):

![Modelo Estrella - EER](modelo entidad-relación/star_schema_sales_cycle.png)

---

## 📊 Visualización en Tableau

Como fase final del proyecto, los datos fueron cargados en **Tableau** desde los CSV, y se replicaron las relaciones del modelo estrella para construir un **dashboard interactivo**, que incluye:

- Ventas por año y mes
- Distribución de ventas por género
- Comparativa entre países
- Participación por categoría de producto
- Rentabilidad neta por categoría

📸 Vista previa:

![Dashboard Tableau](dashboard_tableau.png)

---
