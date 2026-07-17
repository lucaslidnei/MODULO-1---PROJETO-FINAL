# 📋Projeto Final Módulo 1: Análise de Viagens a Serviço do Portal da Transparência

**Curso:** Análise de Dados com Python [T2] | Módulo 1 - Projeto Final

**Aluno:** Lucas Lidnei Rodrigues

Objetivo do projeto é construir do zero um pipeline de dados ETL (Extract, Transform, Load) construído com aquitetura medallion (**Raw → Silver → Gold**) em **Python** e **MySQL**, par analisar os dados públicos de Viagens a Serviço do Governo Federal brasileiro, disponibilizados no Portal da Transparência.

---

## 📌 Desafio

O Portal da Transparência disponibiliza os dados de viagens a serviço do governo federal em formato de dados brutos e desorganzizados.

Desta forma foi necessário construir do zero um pipeline que:

- Baixar os dados diretamente da fonte oficial, sem intervenção manual;
- Preservar os dados originais (camada **raw**), garantindo rastreabilidade e auditoria dos dados;
- Limpar, estruturar e transformar os dados brutos (camada **Silver**), com tipagem correta e integridade referencial entre as tabelas;
- Agregar os dados em métricas de negócio (camada **Gold**), respondendo perguntas reais, com utilização de gráficos que tornam a informação acessível para tomada de decisões.

#### Perguntas de negócios a serem respondidas:

* Os 5 órgãos com maior custo total?
* Os 3 destinos com maior custo médio por viagem?
* A viagem de maior duração e seu custo total?
* Qual o tipo de pagamento com maior valor médio?
* Qual o meio de transporte mais usado nos trechos?
* Qual UF de destino aparece em mais trechos?
* Qual órgão pagou mais no total?

---

## 🛠️ Tecnologias utilizadas

| Tecnologia             | Ferramenta                                                                   |
| ---------------------- | ---------------------------------------------------------------------------- |
| Linguagem              | Python                                                                       |
| Banco de dados         | MySQL                                                                        |
| Extração             | gdwon (download automatizado do Google Drive)                               |
| Manipulação de dados | pandas                                                                       |
| Conexão com banco     | mysql-connector-python                                                       |
| Visualização         | matplotlib (gráficos de barra);<br />plotly e kaleido (mapa coroplético) |
| Análise               | Jupyter Notebook                                                             |
| Versionamento          | GitHu                                                                        |

#### Fluxo da arquitetura

```

Portal da Transparência (.zip)
             ￬
       ┌────────────┐
       │     RAW    │
       │ Texto puro │
       │ (VARCHAR), │
       │ sem regras │
       └────────────┘
             ￬
1_extrair.py (download + carga em blocos)
             ￬
       ┌────────────┐
       │   SILVER   │
       │ Tratamento │
       │   PK/FK,   │
       │   CHECK    │
       └────────────┘
             ￬
2_transformar.py (JOIN + GROUP BY e 1_camada_gold.sql)
             ￬
       ┌────────────┐
       │    GOLD    │
       │  Agregação │
       │   TABLE,   │
       │    VIEW    │
       └────────────┘
             ￬
3_analise.ipynb (análises para responder as perguntas de negócios, tabelas e gráficos)
```

---

## 📂 Estrutura do projeto

```text
├── MODULO 1 - PROJETO FINAL
├── dados/                  		# zip baixado (ignorado pelo Git)
├── reports/                  	# prints do schema e gráficos exportados
├── scripts/
│   ├── 1_extrair.py          	 # download + carga da camada Raw
│   ├── 2_transformar.py      	 # limpeza e tipagem (Raw → Silver)
│   └── 3_analise.ipynb       	 # perguntas de negócio, tabelas e gráficos
│   ├── config.py          		 # leitura do .env + credenciais + processamento dados
│   ├── banco.py              	 # conexão e funções utilitárias do MySQL
├── sql/
│   ├── 0_criar_banco.sql    	 # cria o database e as 8 tabelas (Raw + Silver)
│   ├── 1_camada_gold.sql     # cria a camada Gold (tabela + view)
├── .env              		   	 # credenciais
├── .gitignore                	 # ignora .env, .zip, .csv, dados/
├── requirements.txt          	 # dependências do projeto
└── README.md                 	 # descritivo do projeto
```

---

## 📊 Perguntas de negócio e conclusões

#### Respostas às perguntas de negócios

1. **Os 5 órgãos com maior custo total?**
   Os principais órgão com maior custo total são:
   R$ 487 milhões - Ministério da Justiça e Segurança Pública;
   R$ 156 milhões - Ministério da Defesa;
   R$ 111 milhões - Ministério da Educação;
   R$ 49 milhões  - Ministério do Meio Ambiente e Mudança do Clima;
   R$ 40 milhões  - Ministério da Previdência Social.

2) **Os 3 destinos com maior custo médio por viagem?**
   Os 3 destinos com maior custo total são para Brasília/DF.
   Houve limitação na obtenção dos dados, pois a coluna de destinos da tabela silver_viagem possui os destinos agregados.
   Para trabalhos futuros, seria recomendado utilizar técnicas para segregação dos destinos.
3) **A viagem de maior duração e seu custo total?**
   A viagem de maior duração foi de 378 dias ao custo total de R$ 120.650,00 realizada pelo Ministério da Justiça e Segurança Pública.
4) **Qual o tipo de pagamento com maior valor médio?**
   As diárias de passagem tiveram o maior valor médio, com 401.463 pagamento ao custo médio de R$ 2.078,28.
5) **Qual o meio de transporte mais usado nos trechos?**
   Foi Veículo Oficial o meio de transporte mais utilizado, tendo 386.424 utilizações.
6) **Qual UF de destino aparece em mais trechos?**
   O estado como destino mais frequente foi São Paulo com 82.722 trechos, seguido por Distrito Federal com 79.962 trechos.
7) **Qual órgão pagou mais no total?**
   O Fundo Nacional da Segurança Público foi o órgão que mais pagou, desembolsando o total de R$ 278.481.047,89.

#### Informações adicionais importante

- **valor_total** é calculado como **diárias + passagens - devolução + outros gastos**, deduzindo o valor de devolução realizada pelo viajante.
- **Campos vazios** no **RAW** são convertidos para **NULL** (via NULLIF(TRIM(...), '')) na transformação Raw → Silver, em vez de manter string vazia e tratados como **0** no
  cálculo de **valor_total** (via **COALESCE**), para não quebrar a soma.
- **Colunas de texto longo** ( destinos, motivo, justificativa_urgencia_viagem) usam **CHARACTER SET latin1** em vez de **utf8mb4** na camada Raw, para respeitar o limite de tamanho de linha do InnoDB.
- **Viagens sem valor_total registrado** foram excluídas da análise de duração (Pergunta 3), por não permitirem comparação de custo junto com a duração.

#### Conclusões

O projeto atingiu o objetivo de construir um pipeline ETL completo para os dados de viagens a serviço de 2025, organizando-os nas camadas **Raw, Silver e Gold**. A preservação dos dados originais, a conversão de tipos, a aplicação de regras de integridade e a criação de métricas agregadas tornaram a base mais confiável, rastreável e adequada para análise.

Os resultados mostram uma concentração relevante dos custos no **Ministério da Justiça e Segurança Pública**, enquanto o **Fundo Nacional de Segurança Pública** aparece como o principal órgão pagador. Essas duas respostas representam perspectivas complementares: a primeira considera o órgão superior associado à viagem, e a segunda, o órgão responsável pelo pagamento. Também se destacam as **diárias** como o tipo de pagamento de maior valor médio, o **veículo oficial** como o meio de transporte mais utilizado e **São Paulo** e o **Distrito Federal** como os destinos mais frequentes nos trechos.

A análise também evidenciou limitações de qualidade e granularidade dos dados, principalmente no campo **destinos**, que reúne diferentes localidades em um único texto, e nos registros vazios ou classificados como inválidos. Como melhorias futuras, recomenda-se normalizar os destinos, ampliar as validações de qualidade e comparar diferentes períodos. Essas melhorias permitiriam identificar tendências ao longo do tempo e produzir indicadores ainda mais precisos para apoiar a transparência e o acompanhamento dos gastos públicos.
