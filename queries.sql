-- 1.
SELECT nome
FROM retalhista
INNER JOIN responsavel_por ON retalhista.tin = responsavel_por.tin
GROUP BY nome
HAVING COUNT(*) >= ALL (
    SELECT COUNT(*)
    FROM retalhista
    INNER JOIN responsavel_por ON retalhista.tin = responsavel_por.tin
    GROUP BY nome);

-- 2.
SELECT DISTINCT nome
FROM retalhista
INNER JOIN responsavel_por ON retalhista.tin = responsavel_por.tin
WHERE nome_cat IN (SELECT nome FROM categoria_simples);

-- 3.
SELECT ean
FROM produto
WHERE ean NOT IN (SELECT ean FROM evento_reposicao);

-- 4.
SELECT ean
FROM evento_reposicao
GROUP BY ean
HAVING COUNT(ean) = 1