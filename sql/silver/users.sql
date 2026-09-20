INSERT INTO silver.users (
    user_id,
    first_name,
    last_name,
    maiden_name,
    age,
    gender,
    email,
    phone,
    username,
    password,
    birth_date,
    image,
    blood_group,
    height,
    weight,
    eye_color,
    hair_color,
    hair_type,
    address_address,
    address_city,
    address_state,
    address_state_code,
    address_postal_code,
    address_country,
    bank_card_expire,
    bank_card_number,
    bank_card_type,
    bank_currency,
    bank_iban,
    company_name,
    company_department,
    company_title,
    ein,
    ssn,
    university,
    role,
    ingestion_timestamp
)

SELECT
    source_id AS user_id,

    raw_data ->> 'firstName',
    raw_data ->> 'lastName',
    raw_data ->> 'maidenName',

    (raw_data ->> 'age')::INTEGER,

    raw_data ->> 'gender',
    raw_data ->> 'email',
    raw_data ->> 'phone',
    raw_data ->> 'username',
    raw_data ->> 'password',

    (raw_data ->> 'birthDate')::DATE,

    raw_data ->> 'image',

    raw_data ->> 'bloodGroup',

    (raw_data ->> 'height')::NUMERIC(10,2),
    (raw_data ->> 'weight')::NUMERIC(10,2),

    raw_data ->> 'eyeColor',

    raw_data -> 'hair' ->> 'color',
    raw_data -> 'hair' ->> 'type',

    raw_data -> 'address' ->> 'address',
    raw_data -> 'address' ->> 'city',
    raw_data -> 'address' ->> 'state',
    raw_data -> 'address' ->> 'stateCode',
    raw_data -> 'address' ->> 'postalCode',
    raw_data -> 'address' ->> 'country',

    raw_data -> 'bank' ->> 'cardExpire',
    raw_data -> 'bank' ->> 'cardNumber',
    raw_data -> 'bank' ->> 'cardType',
    raw_data -> 'bank' ->> 'currency',
    raw_data -> 'bank' ->> 'iban',

    raw_data -> 'company' ->> 'name',
    raw_data -> 'company' ->> 'department',
    raw_data -> 'company' ->> 'title',

    raw_data ->> 'ein',
    raw_data ->> 'ssn',
    raw_data ->> 'university',

    raw_data ->> 'role',

    ingestion_timestamp

FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY source_id
            ORDER BY ingestion_timestamp DESC, ingestion_id DESC
        ) AS rn
    FROM bronze.users_raw
) latest

WHERE rn = 1

ON CONFLICT (user_id)

DO UPDATE SET
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    maiden_name = EXCLUDED.maiden_name,
    age = EXCLUDED.age,
    gender = EXCLUDED.gender,
    email = EXCLUDED.email,
    phone = EXCLUDED.phone,
    username = EXCLUDED.username,
    password = EXCLUDED.password,
    birth_date = EXCLUDED.birth_date,
    image = EXCLUDED.image,
    blood_group = EXCLUDED.blood_group,
    height = EXCLUDED.height,
    weight = EXCLUDED.weight,
    eye_color = EXCLUDED.eye_color,
    hair_color = EXCLUDED.hair_color,
    hair_type = EXCLUDED.hair_type,
    address_address = EXCLUDED.address_address,
    address_city = EXCLUDED.address_city,
    address_state = EXCLUDED.address_state,
    address_state_code = EXCLUDED.address_state_code,
    address_postal_code = EXCLUDED.address_postal_code,
    address_country = EXCLUDED.address_country,
    bank_card_expire = EXCLUDED.bank_card_expire,
    bank_card_number = EXCLUDED.bank_card_number,
    bank_card_type = EXCLUDED.bank_card_type,
    bank_currency = EXCLUDED.bank_currency,
    bank_iban = EXCLUDED.bank_iban,
    company_name = EXCLUDED.company_name,
    company_department = EXCLUDED.company_department,
    company_title = EXCLUDED.company_title,
    ein = EXCLUDED.ein,
    ssn = EXCLUDED.ssn,
    university = EXCLUDED.university,
    role = EXCLUDED.role,
    ingestion_timestamp = EXCLUDED.ingestion_timestamp,
    processed_timestamp = NOW();