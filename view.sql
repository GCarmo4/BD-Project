CREATE VIEW Vendas(ean, cat, ano, trimestre, mes, dia_mes, dia_semana, distrito, concelho, unidades) 
AS 
SELECT produto.ean, tem_categoria.nome, 
EXTRACT(YEAR FROM evento_reposicao.instante), 
EXTRACT(QUARTER FROM evento_reposicao.instante), 
EXTRACT(MONTH FROM evento_reposicao.instante), 
EXTRACT(DAY FROM evento_reposicao.instante), 
EXTRACT(DOW FROM evento_reposicao.instante), 
ponto_de_retalho.distrito, 
ponto_de_retalho.concelho, 
evento_reposicao.unidades
FROM produto 
INNER JOIN tem_categoria ON produto.ean = tem_categoria.ean
INNER JOIN evento_reposicao ON produto.ean = evento_reposicao.ean
INNER JOIN instalada_em ON evento_reposicao.num_serie = instalada_em.num_serie
INNER JOIN ponto_de_retalho ON instalada_em.local_ponto_de_retalho = ponto_de_retalho.nome