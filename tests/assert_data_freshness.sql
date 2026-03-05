-- Verificar que los datos no tengan más de 24 horas

SELECT
    MAX(loaded_at) as last_load,
    CURRENT_TIMESTAMP as now,
    DATEDIFF('hour', MAX(loaded_at),
    CURRENT_TIMESTAMP) as hours_old
FROM {{ ref('stg_pokemon') }}
    HAVING DATEDIFF('hour', MAX(loaded_at), CURRENT_TIMESTAMP) > 24