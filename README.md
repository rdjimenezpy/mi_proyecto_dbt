# Proyecto de Transformación de Datos con dbt y MotherDuck

Este repositorio contiene el desarrollo de la **Tarea Práctica de la Clase 5** del módulo de Ingeniería de Datos. El objetivo principal es la implementación de un pipeline de transformación utilizando el paradigma **ELT**, procesando datos extraídos mediante **Airbyte** y almacenados en **MotherDuck**.

## 🏛️ Información Institucional
*   **Institución:** Universidad Nacional de Asunción - Facultad Politécnica (FP-UNA).
*   **Programa:** Maestría en Inteligencia Artificial y Análisis de Datos.
*   **Materia:** Introducción a la Ingeniería de Datos (MIA 03).
*   **Estudiante:** Richard D. Jiménez-R.
*   **E-mail: rjimenez@pol.una.py
*   **Entorno de Trabajo:** Ubuntu 22.04.5 LTS sobre WSL2.

## 🚀 Arquitectura del Pipeline
El proyecto sigue el flujo de datos **RAW → OLAP** integrando las siguientes herramientas:
1.  **Extracción y Carga (EL):** Airbyte.
2.  **Almacenamiento (Storage):** MotherDuck (DuckDB en la nube).
3.  **Transformación (T):** dbt (data build tool).
4.  **Visualización (BI):** Metabase (proyectado).

## 🛠️ Configuración del Entorno

### 1. Mantenimiento del Sistema
Antes de iniciar, se asegura que el entorno de **Ubuntu** esté actualizado y limpio:

```bash
# Actualizar y limpiar el sistema
sudo apt update && sudo apt upgrade -y
sudo apt autoremove && sudo apt clean
```

### 2. Gestión de Permisos
Para trabajar de forma segura en el directorio `/opt/dbt`:

```bash
# Asignar propiedad al usuario actual
sudo chown -R richard:richard /opt/dbt
sudo chmod -R 755 /opt/dbt
```

### 3. Instalación de dbt
Se utiliza un entorno virtual de Python para aislar las dependencias del proyecto:

```bash
# Crear y activar entorno virtual
python3 -m venv dbt-env
source dbt-env/bin/activate

# Instalar dbt con el adaptador para DuckDB
pip install dbt-duckdb

# Verificar la versión instalada
dbt --version
```

### 4. Inicialización y Conexión
Para conectar dbt con **MotherDuck**, es necesario configurar el token de acceso como variable de entorno:

```bash
# Inicializar el proyecto
dbt init mi_proyecto_dbt

# Configurar el token de MotherDuck (Agregar a ~/.bashrc para persistencia)
export MOTHERDUCK_TOKEN="tu_token_aqui"
```

### 5. Directorios y Archivos del Proyecto
 Se aplican las mejores prácticas de ingeniería de software (como el control de versiones y la modularidad) aplicadas
 a la analítica de datos. Aquí te detallo por qué es correcto incluir cada uno:
* `models/`: Es el corazón del proyecto, donde reside toda la lógica de transformación SQL (staging, intermediate y marts.
* `tests/`: Contiene los tests singulares (queries SQL personalizados) para asegurar la calidad de tus datos.
* `macros/`: Almacena funciones reutilizables en **Jinja** que extienden las capacidades de las consultas SQL.
* `seeds/`: Se usa para cargar archivos CSV pequeños y estáticos (como tablas de mapeo) que forman parte de la lógica de negocio.
* `snapshots/`: Esencial si implementas el historial de cambios mediante **Slowly Changing Dimensions (SCD)**.
* `analyses/`: Espacio para queries **SQL analíticos ad-hoc** que no deseas materializar como tablas permanentes.
* `dbt_project.yml`: Es el archivo de configuración principal que define cómo se comporta el proyecto.
* `packages.yml`: Define las dependencias externas (como **dbt-expectations**) necesarias para que el proyecto funcione en otros entornos.
* `.gitignore` y `README.md`: El primero es crítico para la seguridad y el segundo para la documentación institucional y técnica de tu repositorio.

## 📂 Estructura de Modelado
El proyecto organiza las transformaciones en **tres capas lógicas** para garantizar modularidad y calidad:

*   **Staging (`stg_`):** Limpieza inicial y renombrado de los datos crudos de la API (ej. PokeAPI u OpenWeather).
*   **Intermediate (`int_`)**: Lógica de negocio intermedia y aplanamiento de estructuras JSON.
*   **Marts (`obt_` / `fct_` / `dim_`)**: Modelos finales optimizados para análisis y consumo en herramientas de BI.

## ⌨️ Comandos de Ejecución

Para compilar y ejecutar las transformaciones en el warehouse:

```bash
# Ejecutar un modelo específico (ej. staging de pokemon)
dbt run --select stg_pokemon

# Ejecutar todos los modelos de la capa de staging
dbt run --select staging.*

# Ejecutar el proyecto completo
dbt run

# Construir el proyecto (Run + Test)
dbt build
```

## 📖 Documentación, Linaje y Gobernanza
dbt permite generar de forma automática un portal de documentación que incluye el **DAG (Grafo de Dependencias)** del proyecto:

```bash
# Generar la documentación estática del proyecto
dbt docs generate

# Servir la documentación localmente
dbt docs serve

# Liberar puerto y servir documentación en puerto personalizado
sudo fuser -k 8080/tcp
dbt docs serve --port 8001
El portal incluye el DAG Interactivo que permite visualizar las dependencias desde las fuentes (Sources) hasta los modelos finales (Marts) y sus respectivos tests
```
> El portal incluye el **DAG Interactivo** que permite visualizar las dependencias desde las fuentes (_Sources_) hasta los modelos finales (_Marts_) y sus respectivos tests


## 🛠️ Calidad de Datos y Testing

Siguiendo los lineamientos de la Clase 6, se implementó una estrategia robusta de validación para asegurar la integridad de los datos en todas las capas del proyecto.

**Descripción:**
- Se agregó `packages.yml` con dbt-expectations.
- Se implementaron tests genéricos y validaciones de reglas de negocio (singular tests).
- Configuración de documentación técnica en puerto 8001.
- Ajuste de formato y linting de archivos YAML en entorno WSL2.

### 1. Gestión de Dependencias
Se incorporó el paquete `dbt-expectations` para ampliar las capacidades de testing. Para garantizar la integridad de los archivos de configuración en el entorno WSL2, se utilizaron herramientas de limpieza y validación:

```bash
# Validar y corregir formato del archivo de paquetes (opcional)
file packages.yml
sudo apt install dos2unix && dos2unix packages.yml
yamllint packages.yml

# Instalar dependencias
dbt deps
```

### 2. Implementación de Tests
Se configuraron tres tipos de validaciones:
* **Tests Genéricos:** Aplicación de `unique`, `not_null`, `accepted_values` y `relationships` en las capas de Staging y Marts.
* **dbt-expectations:** Implementación de validaciones avanzadas como rangos numéricos (`expect_column_values_to_be_between`) y conteo de filas.
* **Singular Tests:** Creación de queries SQL personalizados en la carpeta `tests/` para validar reglas de negocio específicas 
(ej. validación de estadísticas positivas o integridad de fechas)

### 3. Comandos de Ejecución y Testing
Para el ciclo de desarrollo y verificación se utilizan los siguientes comandos:

```bash
# Ejecución con revisión de deprecaciones y parseo completo
dbt run --show-all-deprecations
dbt run --no-partial-parse

# Ejecución selectiva de tests
dbt test --select stg_pokemon          # Tests de un modelo específico
dbt test --select test_type:generic    # Solo tests pre-construidos
dbt test --select test_type:singular   # Solo reglas de negocio personalizadas

# Construcción completa (Run + Test en orden de dependencias)
dbt build
```
---
**Nota:** Asegúrate de que el archivo `profiles.yml` en `~/.dbt/` esté correctamente configurado con el `path: "md:airbyte_curso"` para la persistencia en la nube.
