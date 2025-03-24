# 🛍️ Sales Cycle: Análisis de Ventas con ETL + MySQL + Modelo Estrella

**Autora:** María Ballesteros  
**Versión:** 1.0  
**Fecha:** 2025-03-24

Este proyecto tiene como objetivo realizar un proceso de ETL completo y desarrollar un modelo de datos optimizado para análisis de ventas utilizando Python, SQLite, MySQL y Tableau.

---

## 🚀 Descripción del Proyecto

- Carga de múltiples archivos CSV con datos de clientes, productos, territorios y ventas.
- Conversión de los datos a una base de datos SQLite.
- Exportación a un archivo SQL compatible con MySQL.
- Limpieza y transformación de datos directamente en MySQL.
- Implementación de un modelo de datos en **esquema estrella**.
- Creación de vistas, claves foráneas, y ejecución de consultas de análisis.
- Construcción de un dashboard visual en **Tableau**.

---

## 🧱 Modelo de Datos: Esquema Estrella

Este modelo incluye una tabla de hechos (`fact_sales_euros_table`) conectada directamente a sus dimensiones:

- `customers_csv`
- `dim_geography`
- `dim_territory`
- `dim_products_euros_table`

📊 Relación visual:

![Modelo Estrella](star_schema_sales_cycle.png)

---

## 🧰 Herramientas Utilizadas

| Herramienta | Uso |
|-------------|-----|
| **Python + Pandas** | Procesamiento de CSV y carga a SQLite |
| **SQLite** | Almacenamiento temporal |
| **MySQL** | Base de datos de análisis |
| **SQL** | Transformación y consultas |
| **Graphviz** | Diagrama EER |
| **Tableau** | Visualización de datos |

---

## 🔄 Proceso ETL

1. **Carga de CSVs a SQLite**
   - Detección automática de separador
   - Limpieza de columnas
   - Inserción de datos con estructura clara

2. **Exportación a SQL**
   - Dump de SQLite
   - Limpieza para compatibilidad con MySQL

3. **Importación y Transformación en MySQL**
   - Tipos de datos ajustados
   - Fechas corregidas
   - Conversión de moneda (IDR → EUR)
   - Creación de vistas y claves foráneas

---

## 📁 Estructura del Proyecto

```bash
├── data/
│   ├── customers_csv.csv
│   ├── dim_geography.csv
│   └── ...
├── cycle_sales.db
├── cycle_sales_export.sql
├── cycle_sales_export_mysql.sql
├── clean_sql_for_mysql.py
├── create_db_from_csv.py
├── transform_analysis.sql
├── star_schema_sales_cycle.png
├── dashboard_tableau.png           # Imagen del dashboard
└── README.md

