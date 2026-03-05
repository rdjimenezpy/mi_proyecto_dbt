-- models/marts/obt_weather.sql
SELECT
    city_name,
    temperature,
    weather_description
FROM {{ ref('stg_weather') }} -- Aquí ya usas los nombres directos
WHERE temperature > 20