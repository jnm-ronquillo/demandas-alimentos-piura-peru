{{ config(materialized='table') }}

select     
    TIPO_INGRESO,
    COUNT(TIPO_INGRESO) as TIPOS_INGRESOS
from `csjpiura.external_demandas_alimentos`
group by TIPO_INGRESO