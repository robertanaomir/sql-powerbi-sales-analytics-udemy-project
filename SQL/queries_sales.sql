--  Query 1 - Receita, leads, vendas, conversão e ticket medio (mês a mês)

With 

leads as	(
				select 
					date_trunc('month', visit_page_date)::date as visit_page_month,
					count (*) as visit_page_count
				from sales.funnel
				group by visit_page_month
				order by visit_page_month
				),

payments as 	(
				select
					date_trunc('month', paid_date)::date as paid_month,
					count (paid_date) as paid_count,
					sum (prod.price * (1+fun.discount)) as receita
				
				from sales.funnel as fun
				left join sales.products as prod
					on fun.product_id = prod.product_id
				where paid_date is not null
				group by paid_month
				order by paid_month
				)

select 
	leads.visit_page_month as "mês",
	leads.visit_page_count as "Leads",
	payments.paid_count as "Vendas",
	(payments.receita/1000)::float as "Receita (R$)",
	(payments.paid_count::float /leads.visit_page_count::float) as "Conversão(%)",
	(payments.receita:: float/payments.paid_count::float/1000) as "Ticket médio (R$)"

from leads
left join payments
on leads.visit_page_month = payments.paid_month


-- Query 2 - país, estado, vendas (5 estados que mais venderam)

select
		
		'Brasil' as "pais",
		cus.state as estado,
		count (fun.paid_date) as vendas,
		date_trunc ('month',fun.paid_date)::date as mes
			
from sales.customers as cus
left join sales.funnel as fun
		on cus.customer_id = fun.customer_id 
group by cus.state, mes
order by vendas desc


-- Query 3 - marcas, vendas (5 estados que mais venderam)

select
		
		prod.brand as marca,
		count (fun.paid_date) as vendas,
		date_trunc ('month',fun.paid_date)::date as mes
			
from sales.products as prod
left join sales.funnel as fun
		on prod.product_id = fun.product_id 
where fun.paid_date is not null
group by prod.brand, mes
order by vendas desc

-- Query 4 - dia_semana, dia da semana e visitas (dia da semana com maior visita no site)

select
		extract ('dow'from visit_page_date) as dia_semana,
		case 
		when extract ('dow'from visit_page_date) = 0 then 'domingo' 
		when extract ('dow'from visit_page_date) = 1 then 'segunda' 
		when extract ('dow'from visit_page_date) = 2 then 'terça'
		when extract ('dow'from visit_page_date) = 3 then 'quarta' 
		when extract ('dow'from visit_page_date) = 4 then 'quinta' 
		when extract ('dow'from visit_page_date) = 5 then 'sexta' 
		when extract ('dow'from visit_page_date) = 6 then 'sabado' 
		else null end as "dia da semana",
		count (fun.visit_page_date) as visitas,
		date_trunc ('month',fun.visit_page_date)::date as mes
			
from sales.funnel as fun
where fun.paid_date is not null
group by dia_semana, mes
order by visitas desc
