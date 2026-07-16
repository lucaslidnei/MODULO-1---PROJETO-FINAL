-- Camada GOLD: total pago por orgao pagador (JOIN silver_pagamento + silver_viagem) com objetivo de responder a pergunta 7 do projeto

USE transparencia;

DROP TABLE IF EXISTS gold_pagamentos_por_orgao;
CREATE TABLE gold_pagamentos_por_orgao AS
SELECT
    p.nome_orgao_pagador        AS orgao_pagador,
    COUNT(DISTINCT v.id_viagem) AS qtd_viagens,
    COUNT(*)                    AS qtd_pagamentos,
    SUM(p.valor)                AS valor_total_pago,
    AVG(p.valor)                AS valor_medio_pagamento
FROM silver_pagamento AS p
JOIN silver_viagem AS v ON v.id_viagem = p.id_viagem
GROUP BY p.nome_orgao_pagador;

DROP VIEW IF EXISTS vw_gold_pagamentos_por_orgao;
CREATE VIEW vw_gold_pagamentos_por_orgao AS
SELECT
    p.nome_orgao_pagador        AS orgao_pagador,
    COUNT(DISTINCT v.id_viagem) AS qtd_viagens,
    COUNT(*)                    AS qtd_pagamentos,
    SUM(p.valor)                AS valor_total_pago,
    AVG(p.valor)                AS valor_medio_pagamento
FROM silver_pagamento AS p
JOIN silver_viagem AS v ON v.id_viagem = p.id_viagem
GROUP BY p.nome_orgao_pagador;