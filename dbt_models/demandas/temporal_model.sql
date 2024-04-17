{{ config(materialized='table') }}
--https://janzednicek.cz/en/etl-mage-ai-docker-installation-dbtsqlserver-dbt-debug-error-fix/
select     
    MES,
    COUNT(EXPEDIENTE) as CANTIDAD_EXPEDIENTES
from `csjpiura.external_demandas_alimentos`
where MES between '01' and '12'
group by MES