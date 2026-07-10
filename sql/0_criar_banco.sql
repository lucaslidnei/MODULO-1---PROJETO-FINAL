-- Criação do banco de dados

DROP DATABASE IF EXISTS transparencia;
CREATE DATABASE transparencia
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;
USE transparencia;

-- Criação das tabelas raw com nomes normalizados em snake_case e com os cabeçalhos originais do CSV

CREATE TABLE raw_viagem (
  identificador_do_processo_de_viagem 	VARCHAR(20),
  numero_da_proposta_pcdp 				VARCHAR(20),
  situacao 								VARCHAR(50),
  viagem_urgente 						VARCHAR(5),
  justificativa_urgencia_viagem 		VARCHAR(4000),
  codigo_do_orgao_superior 				VARCHAR(20),
  nome_do_orgao_superior 				VARCHAR(255),
  codigo_orgao_solicitante 				VARCHAR(255),
  nome_orgao_solicitante 				VARCHAR(255),
  cpf_viajante 							VARCHAR(20),
  nome 									VARCHAR(255),
  cargo 								VARCHAR(255),
  funcao 								VARCHAR(255),
  descricao_funcao 						VARCHAR(255),
  periodo_data_de_inicio 				VARCHAR(20),
  periodo_data_de_fim 					VARCHAR(20),
  destinos 								VARCHAR(255),
  motivo 								VARCHAR(4000),
  valor_diarias 						VARCHAR(50),
  valor_passagens 						VARCHAR(50),
  valor_devolucao 						VARCHAR(50),
  valor_outros_gastos 					VARCHAR(50)
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC;

CREATE TABLE raw_trecho (
  identificador_do_processo_de_viagem 	VARCHAR(20),
  numero_da_proposta_pcdp 				VARCHAR(20),
  sequencia_trecho 						VARCHAR(20),
  origem_data 							VARCHAR(20),
  origem_pais 							VARCHAR(60),
  origem_uf 							VARCHAR(40),
  origem_cidade 						VARCHAR(80),
  destino_data 							VARCHAR(20),
  destino_pais 							VARCHAR(60),
  destino_uf 							VARCHAR(40),
  destino_cidade 						VARCHAR(80),
  meio_de_transporte 					VARCHAR(50),
  numero_diarias 						VARCHAR(50),
  missao 								VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE raw_passagem (
  identificador_do_processo_de_viagem 	VARCHAR(20),
  numero_da_proposta_pcdp 				VARCHAR(20),
  meio_de_transporte 					VARCHAR(50),
  pais_origem_ida 						VARCHAR(60),
  uf_origem_ida 						VARCHAR(40),
  cidade_origem_ida 					VARCHAR(80),
  pais_destino_ida 						VARCHAR(60),
  uf_destino_ida 						VARCHAR(40),
  cidade_destino_ida 					VARCHAR(80),
  pais_origem_volta 					VARCHAR(60),
  uf_origem_volta 						VARCHAR(40),
  cidade_origem_volta 					VARCHAR(80),
  pais_destino_volta 					VARCHAR(60),
  uf_destino_volta 						VARCHAR(40),
  cidade_destino_volta 					VARCHAR(80),
  valor_da_passagem 					VARCHAR(50),
  taxa_de_servico 						VARCHAR(50),
  data_da_emissao_compra 				VARCHAR(20),
  hora_da_emissao_compra 				VARCHAR(20)
) ENGINE=InnoDB;

CREATE TABLE raw_pagamento (
  identificador_do_processo_de_viagem 	VARCHAR(20),
  numero_da_proposta_pcdp 				VARCHAR(20),
  codigo_do_orgao_superior 				VARCHAR(20),
  nome_do_orgao_superior 				VARCHAR(255),
  codigo_do_orgao_pagador 				VARCHAR(20),
  nome_do_orgao_pagador 				VARCHAR(255),
  codigo_da_unidade_gestora_pagadora 	VARCHAR(20),
  nome_da_unidade_gestora_pagadora 		VARCHAR(255),
  tipo_de_pagamento 					VARCHAR(50),
  valor 								VARCHAR(50)
) ENGINE=InnoDB;


-- Criação das tabelas silver, conforme item 5.4 do projeto

CREATE TABLE silver_viagem (
  id_viagem 							VARCHAR(20) NOT NULL,
  num_proposta 							VARCHAR(20),
  situacao 								VARCHAR(50),
  viagem_urgente 						VARCHAR(5),
  cod_orgao_superior 					VARCHAR(20),
  nome_orgao_superior 					VARCHAR(255) NOT NULL,
  nome_viajante 						VARCHAR(255),
  cargo 								VARCHAR(255),
  data_inicio 							DATE,
  data_fim 								DATE,
  destinos 								VARCHAR(4000),
  motivo 								VARCHAR(4000),
  valor_diarias 						DECIMAL(10,2),
  valor_passagens 						DECIMAL(10,2),
  valor_devolucao 						DECIMAL(10,2),
  valor_outros_gastos 					DECIMAL(10,2),
  valor_total 							DECIMAL(12,2),
  duracao_dias 							INT,
  CONSTRAINT pk_silver_viagem PRIMARY KEY (id_viagem),
  CONSTRAINT chk_silver_viagem_valor_diarias CHECK (valor_diarias >= 0) 
) ENGINE=InnoDB ROW_FORMAT=DYNAMIC;

CREATE TABLE silver_passagem (
  id_passagem 							INT 		NOT NULL AUTO_INCREMENT,
  id_viagem 							VARCHAR(20) NOT NULL,
  meio_transporte 						VARCHAR(50),
  pais_origem_ida 						VARCHAR(60),
  uf_origem_ida 						VARCHAR(40),
  cidade_origem_ida 					VARCHAR(80),
  pais_destino_ida 						VARCHAR(60),
  uf_destino_ida 						VARCHAR(40),
  cidade_destino_ida 					VARCHAR(80),
  valor_passagem 						DECIMAL(10,2),
  taxa_servico 							DECIMAL(10,2),
  data_emissao 							DATE,
  CONSTRAINT pk_silver_passagem PRIMARY KEY (id_passagem),
  CONSTRAINT fk_silver_passagem_viagem FOREIGN KEY (id_viagem) REFERENCES silver_viagem(id_viagem),
  CONSTRAINT chk_silver_passagem_valor_passagem CHECK (valor_passagem >= 0),
  CONSTRAINT chk_silver_passagem_taxa_servico CHECK (taxa_servico >= 0)
) ENGINE=InnoDB;

CREATE TABLE silver_pagamento (
  id_pagamento 							INT 		NOT NULL AUTO_INCREMENT,
  id_viagem 							VARCHAR(20) NOT NULL,
  num_proposta 							VARCHAR(20),
  nome_orgao_pagador 					VARCHAR(255),
  nome_ug_pagadora 						VARCHAR(255),
  tipo_pagamento 						VARCHAR(50) NOT NULL,
  valor 								DECIMAL(10,2),
  CONSTRAINT pk_silver_pagamento PRIMARY KEY (id_pagamento),
  CONSTRAINT fk_silver_pagamento_viagem FOREIGN KEY (id_viagem) REFERENCES silver_viagem(id_viagem),
  CONSTRAINT chk_silver_pagamento_valor CHECK (valor >= 0)
) ENGINE=InnoDB;

CREATE TABLE silver_trecho (
  id_trecho 							INT 		NOT NULL AUTO_INCREMENT,
  id_viagem 							VARCHAR(20) NOT NULL,
  sequencia_trecho 						INT,
  origem_data 							DATE,
  origem_uf 							VARCHAR(40),
  origem_cidade 						VARCHAR(80),
  destino_data 							DATE,
  destino_uf 							VARCHAR(40),
  destino_cidade 						VARCHAR(80),
  meio_transporte 						VARCHAR(50),
  numero_diarias 						DECIMAL(10,2),
  CONSTRAINT pk_silver_trecho PRIMARY KEY (id_trecho),
  CONSTRAINT fk_silver_trecho_viagem FOREIGN KEY (id_viagem) REFERENCES silver_viagem(id_viagem),
  CONSTRAINT chk_silver_trecho_numero_diarias CHECK (numero_diarias >= 0),
  CONSTRAINT uq_silver_trecho_viagem_seq UNIQUE (id_viagem, sequencia_trecho)
) ENGINE=InnoDB;
