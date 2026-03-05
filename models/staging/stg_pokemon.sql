
-- Modelo de staging: limpieza básica de datos crudos
-- Staging: tipado correcto para que los tests numéricos y de frescura funcionen en DuckDB.

WITH source AS (
    SELECT * FROM {{ source('raw', 'pokemon') }}
),
renamed AS (
    SELECT
        TRY_CAST(JSON_EXTRACT(_airbyte_data, '$.id') AS bigint) AS pokemon_id,
        JSON_EXTRACT_STRING(_airbyte_data, '$.name') AS pokemon_name,
        TRY_CAST(JSON_EXTRACT_STRING(_airbyte_data, '$.height') as INTEGER) AS height,
        TRY_CAST(JSON_EXTRACT_STRING(_airbyte_data, '$.WEIGHT') AS INTEGER) AS WEIGHT,
        TRY_CAST(JSON_EXTRACT_STRING(_airbyte_data, '$.base_experience') as INTEGER) AS base_experience,
        JSON_EXTRACT(_airbyte_data, '$.types') AS types,
        _airbyte_emitted_at AS loaded_at
    FROM source
)
SELECT * FROM renamed
