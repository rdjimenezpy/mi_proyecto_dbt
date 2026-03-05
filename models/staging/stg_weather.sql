-- Este modelo aplana el JSON para que el resto del proyecto use columnas normales
WITH raw_data AS (
    SELECT * FROM {{ source('raw', 'weather') }}
),

renamed AS (
    SELECT
        -- Extraemos directamente del JSON usando la sintaxis de DuckDB
        (_airbyte_data->>'id')::INT AS city_id,
        _airbyte_data->>'name' AS city_name,
        (_airbyte_data->'main'->>'temp')::FLOAT AS temperature,
        (_airbyte_data->'main'->>'humidity')::INT AS humidity,
        (_airbyte_data->'wind'->>'speed')::FLOAT AS wind_speed,
        (_airbyte_data->'coord'->>'lon')::FLOAT AS longitude,
        (_airbyte_data->'coord'->>'lat')::FLOAT AS latitude,
        _airbyte_data->'weather'->0->>'description' AS weather_description,
        _airbyte_emitted_at AS ingested_at
    FROM raw_data
)

SELECT * FROM renamed