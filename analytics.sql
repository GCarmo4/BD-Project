-- 1.

SELECT dia_semana, concelho, SUM (unidades) AS u_total
FROM Vendas WHERE CAST(CAST(Vendas.ano*10000 + Vendas.mes*100 + Vendas.dia_mes AS VARCHAR(255)) AS DATE) BETWEEN '06-01-2022' AND '10-01-2022'
GROUP BY
    GROUPING SETS ((dia_semana), (concelho), ())

-- 2.

SELECT concelho, cat, dia_semana, SUM (unidades) AS u_total
FROM Vendas WHERE Vendas.distrito = 'Lisboa'
GROUP BY
    GROUPING SETS ((concelho), (cat), (dia_semana), ())