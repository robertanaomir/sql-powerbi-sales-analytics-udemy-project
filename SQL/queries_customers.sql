-- Query 1 - gênero , leads

select
	case
	when ibge.gender = 'male' then 'homens'
	when ibge.gender = 'female' then 'mulheres'
	end as "genero",
	count (*) as "leads"
from sales.customers as cus
left join temp_tables.ibge_genders as ibge
	on lower(cus.first_name) = lower (ibge.first_name)
group by ibge.gender

-- Query 2 status profissional, leads

select
	case
	when professional_status = 'freelancer' then 'freelancer'
	when professional_status = 'retired' then 'aposentado'
	when professional_status = 'clt' then 'clt'
	when professional_status = 'self_employed' then 'autônomo(a)'
	when professional_status = 'other' then 'outro'
	when professional_status = 'businessman' then 'empresário(a)'
	when professional_status = 'civil_servant' then 'funcionário(a) público(a)'
	when professional_status = 'student' then 'estudante'
	end as "status profissional",
	(count (*)::float)/(select count(*) from sales.customers) as "leads %"
	
from sales.customers
group by professional_status
order by "leads %"
	
-- Query 3 - faixa etária, leads (%)

SELECT
    CASE
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date)) < 20 THEN '0-20'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date)) < 40 THEN '20-40'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date)) < 60 THEN '40-60'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date)) < 80 THEN '60-80'
        ELSE '80+' 
    END AS "faixa etaria",
    (COUNT(*)::FLOAT) / (SELECT COUNT(*) FROM sales.customers) AS "leads %"
FROM sales.customers
GROUP BY 1
ORDER BY 1

-- Query 4 - faixa salarial, leads (%), ordem
select distinct income from sales.customers
order by income
SELECT
    CASE
        WHEN income < 5000 THEN '0-5000'
		WHEN income < 10000 THEN '5000-10000'
        WHEN income < 15000 THEN '10000-15000' 
		WHEN income < 20000 THEN '15000-20000' 
		else '20000+' end as "faixa salarial",
		
    (COUNT(*)::FLOAT) / (SELECT COUNT(*) FROM sales.customers) AS "leads %",
	
	CASE
		WHEN income < 5000 THEN 1
		WHEN income < 10000 THEN 2
        WHEN income < 15000 THEN 3
		WHEN income < 20000 THEN 4
		else 5 end as "ordem"
		
FROM sales.customers
GROUP BY 1,3
ORDER BY 3

-- Query 5 - classificação do veiculo, veiculos visitados
-- regra de negócio: veiculos novos tem até 2 anos e seminovos acima de 2 anos

with
	classificacao_veiculo as (

	select
		fun.visit_page_date,
		pro.model_year,
		extract('year' from visit_page_date) - pro.model_year::int as idade_veiculo,
		case
			when (extract('year' from visit_page_date) - pro.model_year::int)<=2 then 'novo'
			else 'seminovo'
			end as "classificação do veiculo"

	from sales.funnel as fun
	left join sales.products as pro
	on fun.product_id = pro.product_id
)

select
	"classificação do veiculo",
	count(*) as "veículos visitados"
from classificacao_veiculo
group by "classificação do veiculo"

-- Query 6 - idade do veiculo, visitados %, ordenação

with
	faixa_idade_veiculos as (

	select
		fun.visit_page_date,
		pro.model_year,
		extract('year' from visit_page_date) - pro.model_year::int as idade_veiculo,
		case
			when (extract('year' from visit_page_date) - pro.model_year::int)<=2 then 'até 2 anos'
			when (extract('year' from visit_page_date) - pro.model_year::int)<=4 then 'de 2 a 4 anos'
			when (extract('year' from visit_page_date) - pro.model_year::int)<=6 then 'de 4 a 6 anos'
			when (extract('year' from visit_page_date) - pro.model_year::int)<=8 then 'de 6 a 8 anos'
			when (extract('year' from visit_page_date) - pro.model_year::int)<=10 then 'de 8 a 10 anos'
			else 'acima de 10 anos'
			end as "idade do veiculo",

			case
			when (extract('year' from visit_page_date) - pro.model_year::int)<=2 then 1
			when (extract('year' from visit_page_date) - pro.model_year::int)<=4 then 2
			when (extract('year' from visit_page_date) - pro.model_year::int)<=6 then 3
			when (extract('year' from visit_page_date) - pro.model_year::int)<=8 then 4
			when (extract('year' from visit_page_date) - pro.model_year::int)<=10 then 5
			else 6
			end as "ordem"
			
	from sales.funnel as fun
	left join sales.products as pro
	on fun.product_id = pro.product_id
)

select
	"idade do veiculo",
	count(*)::float/(select count(*) from sales.funnel) as "veículos visitados %",
	ordem
from faixa_idade_veiculos
group by "idade do veiculo", ordem
order by ordem

-- Query 7 - brand, model, visitas

select
	pro.brand,
	pro.model,
	count (*) as "visitas"

from sales.funnel as fun
left join sales.products as pro
	on fun.product_id = pro.product_id
group by pro.brand, pro.model
order by pro.brand, pro.model, "visitas"
