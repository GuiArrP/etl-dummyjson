# ETL DummyJSON

Projeto de ELT desenvolvido em Python e PostgreSQL utilizando a API pública do DummyJSON como fonte de dados.

O projeto implementa uma arquitetura em camadas **Bronze, Silver e Gold**, incluindo extração paginada, armazenamento dos dados brutos, transformação relacional, validações de qualidade dos dados, geração de logs e uma camada analítica preparada para consumo pelo Power BI.

---

## 👤 Autor

**[Guilherme Arruda Pedroso](https://www.linkedin.com/in/guilherme-arruda-pedroso/)**

Data Analyst | Power BI | Python | Data Analytics

---

## Arquitetura

```text
DummyJSON API
      │
      ▼
   Extração
   (Python)
      │
      ▼
    Bronze
  Dados brutos
      │
      ▼
    Silver
Dados tratados
      │
      ▼
 Qualidade dos
     dados
      │
      ▼
     Gold
Modelo analítico
      │
      ▼
   Power BI
```

O pipeline completo é executado através do arquivo `src/main.py`.

---

## Objetivos do projeto

Os principais objetivos são:

- Extrair dados de uma API REST.
- Implementar uma rotina reutilizável de extração com paginação.
- Armazenar os dados brutos em uma camada Bronze no PostgreSQL.
- Transformar os dados brutos em tabelas relacionais na camada Silver.
- Executar validações de qualidade antes da criação da camada Gold.
- Construir um modelo dimensional para consumo analítico.
- Implementar logs para acompanhamento e diagnóstico das execuções.
- Disponibilizar um usuário PostgreSQL de leitura para ferramentas analíticas, como o Power BI.

---

## Fonte de dados

O projeto utiliza os seguintes endpoints da API DummyJSON:

- `/products`
- `/users`
- `/carts`

A extração possui paginação automática para percorrer todos os registros disponibilizados pela API.

---

# Camadas de dados

## Bronze

A camada Bronze armazena os dados recebidos da API de forma bruta, preservando o histórico das ingestões.

Cada registro possui informações como:

- `batch_id`
- `source_id`
- `raw_data`
- `ingestion_timestamp`

O campo `raw_data` armazena o conteúdo original recebido da API em formato JSONB.

A camada Bronze funciona como uma camada histórica e append-only, permitindo preservar diferentes ingestões dos dados.

---

## Silver

A camada Silver transforma os dados brutos em estruturas relacionais mais adequadas para consultas e validações.

As tabelas atuais são:

| Tabela | Descrição |
|---|---|
| `silver.products` | Informações estruturadas dos produtos |
| `silver.users` | Informações estruturadas dos usuários |
| `silver.carts` | Informações dos carrinhos |
| `silver.cart_items` | Produtos e quantidades presentes em cada carrinho |

A transformação considera o registro mais recente de cada entidade na camada Bronze.

Para `cart_items`, a combinação de `cart_id` e `item_sequence` é utilizada para identificar cada ocorrência de produto dentro de um carrinho.

---

# Qualidade dos dados

Após a transformação para Silver, o pipeline executa uma etapa específica de **Data Quality**.

As validações implementadas incluem:

- Produtos duplicados
- Usuários duplicados
- Carrinhos duplicados
- Itens de carrinho duplicados
- Carrinhos sem usuário correspondente
- Itens de carrinho sem produto correspondente
- Itens de carrinho sem carrinho correspondente
- Preços de produtos inválidos
- Quantidades inválidas nos itens dos carrinhos
- Preços inválidos nos itens dos carrinhos

O fluxo de execução é:

```text
Bronze
  │
  ▼
Silver
  │
  ▼
Data Quality
  │
  ├── FAIL ──► Pipeline interrompido
  │
  └── PASS
       │
       ▼
      Gold
```

Caso uma validação crítica falhe, a execução é interrompida antes da geração da camada Gold.

---

# Gold

A camada Gold disponibiliza um modelo analítico preparado para ferramentas de Business Intelligence.

As tabelas atuais são:

| Tabela | Tipo | Descrição |
|---|---|---|
| `gold.dim_users` | Dimensão | Informações dos usuários |
| `gold.dim_products` | Dimensão | Informações dos produtos |
| `gold.fact_carts` | Fato | Informações e métricas dos carrinhos |
| `gold.fact_cart_items` | Fato | Itens e métricas dos produtos nos carrinhos |

## Modelo de dados

O relacionamento entre as tabelas é:

![Modelo Dimensional - Camada Gold](docs/gold_model.png)

O usuário associado a um item pode ser obtido através do relacionamento:

```text
fact_cart_items
      │
      ▼
fact_carts
      │
      ▼
dim_users
```

Dessa forma, `user_id` não é duplicado em `fact_cart_items`.

A tabela `gold.fact_cart_items` possui métricas como:

- Quantidade
- Preço unitário
- Preço unitário com desconto
- Valor bruto
- Valor com desconto
- Valor do desconto

---

# Estrutura do projeto

```text
etl-dummyjson/
│
├── logs/
│   └── pipeline_*.log
│
├── sql/
│   ├── gold/
│   │   ├── dim_products.sql
│   │   ├── dim_users.sql
│   │   ├── fact_cart_items.sql
│   │   └── fact_carts.sql
│   │
│   └── silver/
│       ├── cart_items.sql
│       ├── carts.sql
│       ├── products.sql
│       └── users.sql
│
├── src/
│   ├── config/
│   │   └── sources.py
│   │
│   ├── extract/
│   │   └── api.py
│   │
│   ├── load/
│   │   └── postgres.py
│   │
│   ├── quality/
│   │   └── checks.py
│   │
│   ├── transform/
│   │   └── postgres.py
│   │
│   ├── utils/
│   │   └── logger.py
│   │
│   └── main.py
│
├── .env
├── .env_sample
├── .gitignore
├── README.md
└── requirements.txt
```

---

# Tecnologias utilizadas

- **Python**
- **PostgreSQL**
- **Supabase**
- **SQLAlchemy**
- **Requests**
- **python-dotenv**
- **Power BI**

---

# Pré-requisitos

Para executar o projeto, são necessários:

- Python 3.10 ou superior
- Uma instância PostgreSQL ou um projeto Supabase
- Power BI Desktop para a etapa de visualização

---

# Configuração do ambiente

Clone o repositório:

```bash
git clone git@github.com:GuiArrP/etl-dummyjson.git
cd etl-dummyjson
```

Crie o ambiente virtual:

```bash
python -m venv .venv
```

No Windows, ative o ambiente:

```powershell
.venv\Scripts\Activate.ps1
```

Instale as dependências:

```bash
pip install -r requirements.txt
```

---

# Variáveis de ambiente

Crie um arquivo `.env` baseado no `.env_sample`.

Exemplo:

```env
DATABASE_URL=postgresql://usuario:senha@host:5432/postgres
```

O arquivo `.env` contém informações sensíveis e não deve ser versionado.

O `.gitignore` do projeto já está configurado para ignorar o arquivo `.env`.

---

# Configuração do banco de dados

O banco utiliza três schemas principais:

```sql
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
```

Os scripts SQL presentes em `sql/silver` e `sql/gold` são responsáveis pela criação e transformação das respectivas camadas.

---

# Execução do pipeline

A partir da raiz do projeto, execute:

```bash
python -m src.main
```

O pipeline executará as seguintes etapas:

```text
1. Extração dos dados da API DummyJSON
2. Carga dos dados brutos na camada Bronze
3. Transformação da Bronze para Silver
4. Registro das quantidades de registros da Silver
5. Execução das validações de qualidade
6. Interrupção caso alguma validação falhe
7. Geração da camada Gold
8. Registro das quantidades de registros da Gold
9. Geração dos logs da execução
```

---

# Logging

Cada execução do pipeline gera um arquivo de log com timestamp dentro da pasta `logs/`.

Exemplo:

```text
logs/
└── pipeline_2026-09-20_15-37-25.log
```

Os logs registram informações como:

- Quantidade de registros extraídos
- Resultado da carga na Bronze
- Status das transformações Silver
- Resultado das validações de qualidade
- Status das transformações Gold
- Quantidade de registros nas camadas
- Erros e exceções
- Status final da execução

---

# Acesso somente leitura

O projeto utiliza um role PostgreSQL dedicado chamado `powerbi_reader` para acesso analítico.

Esse usuário possui permissão de leitura (`SELECT`) nos schemas:

```text
bronze
silver
gold
```

O objetivo é separar as credenciais administrativas utilizadas pelo pipeline das credenciais utilizadas por ferramentas de análise.

O usuário de leitura não possui permissão para:

- Criar tabelas
- Inserir registros
- Atualizar registros
- Excluir registros
- Alterar objetos do banco

Esse usuário é destinado ao acesso por ferramentas analíticas, como o Power BI.

> As credenciais do banco não são armazenadas no repositório.

---

# Power BI

A camada Gold foi desenvolvida para ser consumida pelo Power BI.

O modelo disponibiliza informações relacionadas a:

- Usuários
- Produtos
- Carrinhos
- Itens dos carrinhos
- Quantidades
- Valores brutos
- Valores com desconto
- Descontos
- Categorias de produtos

O objetivo da camada analítica é permitir a construção de indicadores e análises de vendas, produtos, categorias, clientes e descontos.

