CREATE TABLE IF NOT EXISTS gold.dim_users (
    user_id INTEGER PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    age INTEGER,
    gender VARCHAR(50),
    country VARCHAR(100),
    state VARCHAR(100),
    city VARCHAR(100),
    company_name VARCHAR(255),
    company_department VARCHAR(100),
    company_title VARCHAR(100),
    role VARCHAR(50),
    processed_timestamp TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO gold.dim_users (
    user_id,
    first_name,
    last_name,
    age,
    gender,
    country,
    state,
    city,
    company_name,
    company_department,
    company_title,
    role
)
SELECT
    user_id,
    first_name,
    last_name,
    age,
    gender,
    address_country,
    address_state,
    address_city,
    company_name,
    company_department,
    company_title,
    role
FROM silver.users
ON CONFLICT (user_id)
DO UPDATE SET
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    age = EXCLUDED.age,
    gender = EXCLUDED.gender,
    country = EXCLUDED.country,
    state = EXCLUDED.state,
    city = EXCLUDED.city,
    company_name = EXCLUDED.company_name,
    company_department = EXCLUDED.company_department,
    company_title = EXCLUDED.company_title,
    role = EXCLUDED.role,
    processed_timestamp = NOW();