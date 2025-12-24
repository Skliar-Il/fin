SET search_path TO finance, public;

INSERT INTO finance.categories (name, parent_id) VALUES
('Доходы', NULL),
('Расходы', NULL),
('Зарплата', (SELECT category_id FROM finance.categories WHERE name = 'Доходы' LIMIT 1)),
('Подарки', (SELECT category_id FROM finance.categories WHERE name = 'Доходы' LIMIT 1)),
('Инвестиции', (SELECT category_id FROM finance.categories WHERE name = 'Доходы' LIMIT 1)),
('Продукты', (SELECT category_id FROM finance.categories WHERE name = 'Расходы' LIMIT 1)),
('Транспорт', (SELECT category_id FROM finance.categories WHERE name = 'Расходы' LIMIT 1)),
('Развлечения', (SELECT category_id FROM finance.categories WHERE name = 'Расходы' LIMIT 1)),
('Здоровье', (SELECT category_id FROM finance.categories WHERE name = 'Расходы' LIMIT 1)),
('Образование', (SELECT category_id FROM finance.categories WHERE name = 'Расходы' LIMIT 1)),
('Одежда', (SELECT category_id FROM finance.categories WHERE name = 'Расходы' LIMIT 1)),
('Рестораны', (SELECT category_id FROM finance.categories WHERE name = 'Расходы' LIMIT 1)),
('Коммунальные услуги', (SELECT category_id FROM finance.categories WHERE name = 'Расходы' LIMIT 1)),
('Молочные продукты', (SELECT category_id FROM finance.categories WHERE name = 'Продукты' LIMIT 1)),
('Мясо', (SELECT category_id FROM finance.categories WHERE name = 'Продукты' LIMIT 1)),
('Овощи', (SELECT category_id FROM finance.categories WHERE name = 'Продукты' LIMIT 1)),
('Такси', (SELECT category_id FROM finance.categories WHERE name = 'Транспорт' LIMIT 1)),
('Общественный транспорт', (SELECT category_id FROM finance.categories WHERE name = 'Транспорт' LIMIT 1)),
('Бензин', (SELECT category_id FROM finance.categories WHERE name = 'Транспорт' LIMIT 1)),
('Кино', (SELECT category_id FROM finance.categories WHERE name = 'Развлечения' LIMIT 1)),
('Концерты', (SELECT category_id FROM finance.categories WHERE name = 'Развлечения' LIMIT 1));

INSERT INTO finance.users (email, password, currency_preference, role) VALUES
('user1@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqJqJqJqJq', 'RUB', 'user'),
('user2@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqJqJqJqJq', 'USD', 'user'),
('user3@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqJqJqJqJq', 'EUR', 'user'),
('user4@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqJqJqJqJq', 'RUB', 'user'),
('user5@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqJqJqJqJq', 'USD', 'user'),
('user6@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqJqJqJqJq', 'RUB', 'user'),
('user7@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqJqJqJqJq', 'EUR', 'user'),
('user8@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqJqJqJqJq', 'USD', 'user'),
('user9@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqJqJqJqJq', 'RUB', 'user'),
('user10@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqJqJqJqJq', 'USD', 'user'),
('admin@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqJqJqJqJq', 'RUB', 'admin'),
('operator@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqJqJqJqJq', 'RUB', 'user');

INSERT INTO finance.users_info (user_id, fname, lname, patronymic, date_birth) VALUES
((SELECT user_id FROM finance.users WHERE email = 'user1@example.com' LIMIT 1), 'Иван', 'Иванов', 'Петрович', '1990-01-15'),
((SELECT user_id FROM finance.users WHERE email = 'user2@example.com' LIMIT 1), 'Мария', 'Петрова', 'Сергеевна', '1992-03-20'),
((SELECT user_id FROM finance.users WHERE email = 'user3@example.com' LIMIT 1), 'Алексей', 'Сидоров', 'Александрович', '1988-07-10'),
((SELECT user_id FROM finance.users WHERE email = 'user4@example.com' LIMIT 1), 'Елена', 'Козлова', 'Дмитриевна', '1995-05-25'),
((SELECT user_id FROM finance.users WHERE email = 'user5@example.com' LIMIT 1), 'Дмитрий', 'Новиков', 'Владимирович', '1991-09-12'),
((SELECT user_id FROM finance.users WHERE email = 'user6@example.com' LIMIT 1), 'Анна', 'Морозова', 'Игоревна', '1993-11-30'),
((SELECT user_id FROM finance.users WHERE email = 'user7@example.com' LIMIT 1), 'Сергей', 'Волков', 'Николаевич', '1989-04-18'),
((SELECT user_id FROM finance.users WHERE email = 'user8@example.com' LIMIT 1), 'Ольга', 'Соколова', 'Андреевна', '1994-08-22'),
((SELECT user_id FROM finance.users WHERE email = 'user9@example.com' LIMIT 1), 'Павел', 'Лебедев', 'Олегович', '1996-02-14'),
((SELECT user_id FROM finance.users WHERE email = 'user10@example.com' LIMIT 1), 'Татьяна', 'Орлова', 'Викторовна', '1992-06-08'),
((SELECT user_id FROM finance.users WHERE email = 'admin@example.com' LIMIT 1), 'Админ', 'Админов', 'Админович', '1985-01-01'),
((SELECT user_id FROM finance.users WHERE email = 'operator@example.com' LIMIT 1), 'Оператор', 'Операторов', 'Операторович', '1990-01-01');

UPDATE finance.accounts SET balance = 50000.00, currency = 'RUB' WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user1@example.com' LIMIT 1);
UPDATE finance.accounts SET balance = 1500.00, currency = 'USD' WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user2@example.com' LIMIT 1);
UPDATE finance.accounts SET balance = 2000.00, currency = 'EUR' WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user3@example.com' LIMIT 1);
UPDATE finance.accounts SET balance = 75000.00, currency = 'RUB' WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user4@example.com' LIMIT 1);
UPDATE finance.accounts SET balance = 3000.00, currency = 'USD' WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user5@example.com' LIMIT 1);
UPDATE finance.accounts SET balance = 60000.00, currency = 'RUB' WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user6@example.com' LIMIT 1);
UPDATE finance.accounts SET balance = 2500.00, currency = 'EUR' WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user7@example.com' LIMIT 1);
UPDATE finance.accounts SET balance = 4000.00, currency = 'USD' WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user8@example.com' LIMIT 1);
UPDATE finance.accounts SET balance = 80000.00, currency = 'RUB' WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user9@example.com' LIMIT 1);
UPDATE finance.accounts SET balance = 5000.00, currency = 'USD' WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user10@example.com' LIMIT 1);
UPDATE finance.accounts SET balance = 100000.00, currency = 'RUB' WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'admin@example.com' LIMIT 1);
UPDATE finance.accounts SET balance = 45000.00, currency = 'RUB' WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'operator@example.com' LIMIT 1);

DO $$
DECLARE
    v_user1_account INT;
    v_user2_account INT;
    v_user3_account INT;
    v_user4_account INT;
    v_user5_account INT;
    v_user6_account INT;
    v_user7_account INT;
    v_user8_account INT;
    v_user9_account INT;
    v_user10_account INT;
    v_salary_category INT;
    v_products_category INT;
    v_transport_category INT;
    v_entertainment_category INT;
    v_health_category INT;
    v_education_category INT;
    v_clothing_category INT;
    v_restaurant_category INT;
    v_utilities_category INT;
    v_gifts_category INT;
BEGIN
    SELECT account_id INTO v_user1_account FROM finance.accounts WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user1@example.com' LIMIT 1) LIMIT 1;
    SELECT account_id INTO v_user2_account FROM finance.accounts WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user2@example.com' LIMIT 1) LIMIT 1;
    SELECT account_id INTO v_user3_account FROM finance.accounts WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user3@example.com' LIMIT 1) LIMIT 1;
    SELECT account_id INTO v_user4_account FROM finance.accounts WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user4@example.com' LIMIT 1) LIMIT 1;
    SELECT account_id INTO v_user5_account FROM finance.accounts WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user5@example.com' LIMIT 1) LIMIT 1;
    SELECT account_id INTO v_user6_account FROM finance.accounts WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user6@example.com' LIMIT 1) LIMIT 1;
    SELECT account_id INTO v_user7_account FROM finance.accounts WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user7@example.com' LIMIT 1) LIMIT 1;
    SELECT account_id INTO v_user8_account FROM finance.accounts WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user8@example.com' LIMIT 1) LIMIT 1;
    SELECT account_id INTO v_user9_account FROM finance.accounts WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user9@example.com' LIMIT 1) LIMIT 1;
    SELECT account_id INTO v_user10_account FROM finance.accounts WHERE user_id = (SELECT user_id FROM finance.users WHERE email = 'user10@example.com' LIMIT 1) LIMIT 1;
    
    SELECT category_id INTO v_salary_category FROM finance.categories WHERE name = 'Зарплата' LIMIT 1;
    SELECT category_id INTO v_products_category FROM finance.categories WHERE name = 'Продукты' LIMIT 1;
    SELECT category_id INTO v_transport_category FROM finance.categories WHERE name = 'Транспорт' LIMIT 1;
    SELECT category_id INTO v_entertainment_category FROM finance.categories WHERE name = 'Развлечения' LIMIT 1;
    SELECT category_id INTO v_health_category FROM finance.categories WHERE name = 'Здоровье' LIMIT 1;
    SELECT category_id INTO v_education_category FROM finance.categories WHERE name = 'Образование' LIMIT 1;
    SELECT category_id INTO v_clothing_category FROM finance.categories WHERE name = 'Одежда' LIMIT 1;
    SELECT category_id INTO v_restaurant_category FROM finance.categories WHERE name = 'Рестораны' LIMIT 1;
    SELECT category_id INTO v_utilities_category FROM finance.categories WHERE name = 'Коммунальные услуги' LIMIT 1;
    SELECT category_id INTO v_gifts_category FROM finance.categories WHERE name = 'Подарки' LIMIT 1;
    
    PERFORM set_config('app.current_user_id', (SELECT user_id FROM finance.users WHERE email = 'user1@example.com' LIMIT 1)::text, false);
    INSERT INTO finance.transactions (account_id, category_id, amount, type, date, description, merchant) VALUES
    (v_user1_account, v_salary_category, 80000.00, 'income', CURRENT_TIMESTAMP - INTERVAL '30 days', 'Зарплата за декабрь', 'Работодатель'),
    (v_user1_account, v_products_category, 2500.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '29 days', 'Покупка продуктов', 'Магнит'),
    (v_user1_account, v_transport_category, 500.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '28 days', 'Проездной', 'Метро'),
    (v_user1_account, v_entertainment_category, 1500.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '27 days', 'Кино', 'Кинотеатр'),
    (v_user1_account, v_health_category, 3000.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '26 days', 'Визит к врачу', 'Поликлиника'),
    (v_user1_account, v_education_category, 5000.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '25 days', 'Курсы', 'Онлайн школа'),
    (v_user1_account, v_clothing_category, 4500.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '24 days', 'Одежда', 'Магазин'),
    (v_user1_account, v_restaurant_category, 2000.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '23 days', 'Ужин в ресторане', 'Ресторан'),
    (v_user1_account, v_utilities_category, 3500.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '22 days', 'Коммунальные услуги', 'УК'),
    (v_user1_account, v_gifts_category, 2000.00, 'income', CURRENT_TIMESTAMP - INTERVAL '21 days', 'Подарок на день рождения', 'Друг'),
    (v_user1_account, v_products_category, 1800.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '20 days', 'Продукты', 'Пятёрочка'),
    (v_user1_account, v_transport_category, 600.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '19 days', 'Такси', 'Яндекс.Такси');
    
    PERFORM set_config('app.current_user_id', (SELECT user_id FROM finance.users WHERE email = 'user2@example.com' LIMIT 1)::text, false);
    INSERT INTO finance.transactions (account_id, category_id, amount, type, date, description, merchant) VALUES
    (v_user2_account, v_salary_category, 2500.00, 'income', CURRENT_TIMESTAMP - INTERVAL '30 days', 'Salary', 'Company'),
    (v_user2_account, v_products_category, 150.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '29 days', 'Groceries', 'Supermarket'),
    (v_user2_account, v_transport_category, 50.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '28 days', 'Transport', 'Metro'),
    (v_user2_account, v_entertainment_category, 100.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '27 days', 'Cinema', 'Cinema'),
    (v_user2_account, v_health_category, 200.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '26 days', 'Doctor visit', 'Clinic'),
    (v_user2_account, v_education_category, 300.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '25 days', 'Courses', 'Online school'),
    (v_user2_account, v_clothing_category, 250.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '24 days', 'Clothing', 'Store'),
    (v_user2_account, v_restaurant_category, 120.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '23 days', 'Dinner', 'Restaurant'),
    (v_user2_account, v_utilities_category, 180.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '22 days', 'Utilities', 'Company'),
    (v_user2_account, v_gifts_category, 100.00, 'income', CURRENT_TIMESTAMP - INTERVAL '21 days', 'Birthday gift', 'Friend'),
    (v_user2_account, v_products_category, 130.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '20 days', 'Groceries', 'Store'),
    (v_user2_account, v_transport_category, 40.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '19 days', 'Taxi', 'Uber');
    
    PERFORM set_config('app.current_user_id', (SELECT user_id FROM finance.users WHERE email = 'user3@example.com' LIMIT 1)::text, false);
    INSERT INTO finance.transactions (account_id, category_id, amount, type, date, description, merchant) VALUES
    (v_user3_account, v_salary_category, 3000.00, 'income', CURRENT_TIMESTAMP - INTERVAL '30 days', 'Gehalt', 'Firma'),
    (v_user3_account, v_products_category, 180.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '29 days', 'Lebensmittel', 'Supermarkt'),
    (v_user3_account, v_transport_category, 60.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '28 days', 'Transport', 'U-Bahn'),
    (v_user3_account, v_entertainment_category, 120.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '27 days', 'Kino', 'Kino'),
    (v_user3_account, v_health_category, 250.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '26 days', 'Arztbesuch', 'Klinik'),
    (v_user3_account, v_education_category, 350.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '25 days', 'Kurse', 'Online-Schule'),
    (v_user3_account, v_clothing_category, 280.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '24 days', 'Kleidung', 'Geschäft'),
    (v_user3_account, v_restaurant_category, 140.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '23 days', 'Abendessen', 'Restaurant'),
    (v_user3_account, v_utilities_category, 200.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '22 days', 'Nebenkosten', 'Firma'),
    (v_user3_account, v_gifts_category, 120.00, 'income', CURRENT_TIMESTAMP - INTERVAL '21 days', 'Geburtstagsgeschenk', 'Freund'),
    (v_user3_account, v_products_category, 160.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '20 days', 'Lebensmittel', 'Laden'),
    (v_user3_account, v_transport_category, 50.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '19 days', 'Taxi', 'Taxi');
    
    PERFORM set_config('app.current_user_id', (SELECT user_id FROM finance.users WHERE email = 'user4@example.com' LIMIT 1)::text, false);
    INSERT INTO finance.transactions (account_id, category_id, amount, type, date, description, merchant) VALUES
    (v_user4_account, v_salary_category, 90000.00, 'income', CURRENT_TIMESTAMP - INTERVAL '30 days', 'Зарплата', 'Работодатель'),
    (v_user4_account, v_products_category, 3000.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '29 days', 'Продукты', 'Магнит'),
    (v_user4_account, v_transport_category, 700.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '28 days', 'Транспорт', 'Метро'),
    (v_user4_account, v_entertainment_category, 2000.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '27 days', 'Развлечения', 'Кинотеатр'),
    (v_user4_account, v_health_category, 4000.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '26 days', 'Здоровье', 'Поликлиника'),
    (v_user4_account, v_education_category, 6000.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '25 days', 'Образование', 'Школа'),
    (v_user4_account, v_clothing_category, 5500.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '24 days', 'Одежда', 'Магазин'),
    (v_user4_account, v_restaurant_category, 2500.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '23 days', 'Ресторан', 'Ресторан'),
    (v_user4_account, v_utilities_category, 4000.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '22 days', 'Коммунальные', 'УК'),
    (v_user4_account, v_gifts_category, 2500.00, 'income', CURRENT_TIMESTAMP - INTERVAL '21 days', 'Подарок', 'Друг'),
    (v_user4_account, v_products_category, 2200.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '20 days', 'Продукты', 'Пятёрочка'),
    (v_user4_account, v_transport_category, 800.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '19 days', 'Такси', 'Яндекс.Такси');
    
    PERFORM set_config('app.current_user_id', (SELECT user_id FROM finance.users WHERE email = 'user5@example.com' LIMIT 1)::text, false);
    INSERT INTO finance.transactions (account_id, category_id, amount, type, date, description, merchant) VALUES
    (v_user5_account, v_salary_category, 3500.00, 'income', CURRENT_TIMESTAMP - INTERVAL '30 days', 'Salary', 'Company'),
    (v_user5_account, v_products_category, 200.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '29 days', 'Groceries', 'Supermarket'),
    (v_user5_account, v_transport_category, 70.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '28 days', 'Transport', 'Metro'),
    (v_user5_account, v_entertainment_category, 150.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '27 days', 'Entertainment', 'Cinema'),
    (v_user5_account, v_health_category, 300.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '26 days', 'Health', 'Clinic'),
    (v_user5_account, v_education_category, 400.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '25 days', 'Education', 'School'),
    (v_user5_account, v_clothing_category, 350.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '24 days', 'Clothing', 'Store'),
    (v_user5_account, v_restaurant_category, 180.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '23 days', 'Restaurant', 'Restaurant'),
    (v_user5_account, v_utilities_category, 250.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '22 days', 'Utilities', 'Company'),
    (v_user5_account, v_gifts_category, 150.00, 'income', CURRENT_TIMESTAMP - INTERVAL '21 days', 'Gift', 'Friend'),
    (v_user5_account, v_products_category, 170.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '20 days', 'Groceries', 'Store'),
    (v_user5_account, v_transport_category, 60.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '19 days', 'Taxi', 'Uber');
    
    PERFORM set_config('app.current_user_id', (SELECT user_id FROM finance.users WHERE email = 'user6@example.com' LIMIT 1)::text, false);
    INSERT INTO finance.transactions (account_id, category_id, amount, type, date, description, merchant) VALUES
    (v_user6_account, v_salary_category, 70000.00, 'income', CURRENT_TIMESTAMP - INTERVAL '30 days', 'Зарплата', 'Работодатель'),
    (v_user6_account, v_products_category, 2200.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '29 days', 'Продукты', 'Магнит'),
    (v_user6_account, v_transport_category, 600.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '28 days', 'Транспорт', 'Метро'),
    (v_user6_account, v_entertainment_category, 1800.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '27 days', 'Развлечения', 'Кинотеатр'),
    (v_user6_account, v_health_category, 3500.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '26 days', 'Здоровье', 'Поликлиника'),
    (v_user6_account, v_education_category, 5500.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '25 days', 'Образование', 'Школа'),
    (v_user6_account, v_clothing_category, 5000.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '24 days', 'Одежда', 'Магазин'),
    (v_user6_account, v_restaurant_category, 2200.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '23 days', 'Ресторан', 'Ресторан'),
    (v_user6_account, v_utilities_category, 3800.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '22 days', 'Коммунальные', 'УК'),
    (v_user6_account, v_gifts_category, 2200.00, 'income', CURRENT_TIMESTAMP - INTERVAL '21 days', 'Подарок', 'Друг'),
    (v_user6_account, v_products_category, 2000.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '20 days', 'Продукты', 'Пятёрочка'),
    (v_user6_account, v_transport_category, 700.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '19 days', 'Такси', 'Яндекс.Такси');
    
    PERFORM set_config('app.current_user_id', (SELECT user_id FROM finance.users WHERE email = 'user7@example.com' LIMIT 1)::text, false);
    INSERT INTO finance.transactions (account_id, category_id, amount, type, date, description, merchant) VALUES
    (v_user7_account, v_salary_category, 2800.00, 'income', CURRENT_TIMESTAMP - INTERVAL '30 days', 'Gehalt', 'Firma'),
    (v_user7_account, v_products_category, 200.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '29 days', 'Lebensmittel', 'Supermarkt'),
    (v_user7_account, v_transport_category, 80.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '28 days', 'Transport', 'U-Bahn'),
    (v_user7_account, v_entertainment_category, 180.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '27 days', 'Unterhaltung', 'Kino'),
    (v_user7_account, v_health_category, 350.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '26 days', 'Gesundheit', 'Klinik'),
    (v_user7_account, v_education_category, 450.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '25 days', 'Bildung', 'Schule'),
    (v_user7_account, v_clothing_category, 400.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '24 days', 'Kleidung', 'Geschäft'),
    (v_user7_account, v_restaurant_category, 200.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '23 days', 'Restaurant', 'Restaurant'),
    (v_user7_account, v_utilities_category, 280.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '22 days', 'Nebenkosten', 'Firma'),
    (v_user7_account, v_gifts_category, 180.00, 'income', CURRENT_TIMESTAMP - INTERVAL '21 days', 'Geschenk', 'Freund'),
    (v_user7_account, v_products_category, 190.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '20 days', 'Lebensmittel', 'Laden'),
    (v_user7_account, v_transport_category, 70.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '19 days', 'Taxi', 'Taxi');
    
    PERFORM set_config('app.current_user_id', (SELECT user_id FROM finance.users WHERE email = 'user8@example.com' LIMIT 1)::text, false);
    INSERT INTO finance.transactions (account_id, category_id, amount, type, date, description, merchant) VALUES
    (v_user8_account, v_salary_category, 4000.00, 'income', CURRENT_TIMESTAMP - INTERVAL '30 days', 'Salary', 'Company'),
    (v_user8_account, v_products_category, 250.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '29 days', 'Groceries', 'Supermarket'),
    (v_user8_account, v_transport_category, 90.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '28 days', 'Transport', 'Metro'),
    (v_user8_account, v_entertainment_category, 200.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '27 days', 'Entertainment', 'Cinema'),
    (v_user8_account, v_health_category, 400.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '26 days', 'Health', 'Clinic'),
    (v_user8_account, v_education_category, 500.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '25 days', 'Education', 'School'),
    (v_user8_account, v_clothing_category, 450.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '24 days', 'Clothing', 'Store'),
    (v_user8_account, v_restaurant_category, 220.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '23 days', 'Restaurant', 'Restaurant'),
    (v_user8_account, v_utilities_category, 300.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '22 days', 'Utilities', 'Company'),
    (v_user8_account, v_gifts_category, 200.00, 'income', CURRENT_TIMESTAMP - INTERVAL '21 days', 'Gift', 'Friend'),
    (v_user8_account, v_products_category, 240.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '20 days', 'Groceries', 'Store'),
    (v_user8_account, v_transport_category, 80.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '19 days', 'Taxi', 'Uber');
    
    PERFORM set_config('app.current_user_id', (SELECT user_id FROM finance.users WHERE email = 'user9@example.com' LIMIT 1)::text, false);
    INSERT INTO finance.transactions (account_id, category_id, amount, type, date, description, merchant) VALUES
    (v_user9_account, v_salary_category, 95000.00, 'income', CURRENT_TIMESTAMP - INTERVAL '30 days', 'Зарплата', 'Работодатель'),
    (v_user9_account, v_products_category, 3500.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '29 days', 'Продукты', 'Магнит'),
    (v_user9_account, v_transport_category, 800.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '28 days', 'Транспорт', 'Метро'),
    (v_user9_account, v_entertainment_category, 2500.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '27 days', 'Развлечения', 'Кинотеатр'),
    (v_user9_account, v_health_category, 4500.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '26 days', 'Здоровье', 'Поликлиника'),
    (v_user9_account, v_education_category, 7000.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '25 days', 'Образование', 'Школа'),
    (v_user9_account, v_clothing_category, 6000.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '24 days', 'Одежда', 'Магазин'),
    (v_user9_account, v_restaurant_category, 3000.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '23 days', 'Ресторан', 'Ресторан'),
    (v_user9_account, v_utilities_category, 4500.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '22 days', 'Коммунальные', 'УК'),
    (v_user9_account, v_gifts_category, 3000.00, 'income', CURRENT_TIMESTAMP - INTERVAL '21 days', 'Подарок', 'Друг'),
    (v_user9_account, v_products_category, 2800.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '20 days', 'Продукты', 'Пятёрочка'),
    (v_user9_account, v_transport_category, 900.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '19 days', 'Такси', 'Яндекс.Такси');
    
    PERFORM set_config('app.current_user_id', (SELECT user_id FROM finance.users WHERE email = 'user10@example.com' LIMIT 1)::text, false);
    INSERT INTO finance.transactions (account_id, category_id, amount, type, date, description, merchant) VALUES
    (v_user10_account, v_salary_category, 5000.00, 'income', CURRENT_TIMESTAMP - INTERVAL '30 days', 'Salary', 'Company'),
    (v_user10_account, v_products_category, 300.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '29 days', 'Groceries', 'Supermarket'),
    (v_user10_account, v_transport_category, 100.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '28 days', 'Transport', 'Metro'),
    (v_user10_account, v_entertainment_category, 250.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '27 days', 'Entertainment', 'Cinema'),
    (v_user10_account, v_health_category, 500.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '26 days', 'Health', 'Clinic'),
    (v_user10_account, v_education_category, 600.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '25 days', 'Education', 'School'),
    (v_user10_account, v_clothing_category, 550.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '24 days', 'Clothing', 'Store'),
    (v_user10_account, v_restaurant_category, 280.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '23 days', 'Restaurant', 'Restaurant'),
    (v_user10_account, v_utilities_category, 350.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '22 days', 'Utilities', 'Company'),
    (v_user10_account, v_gifts_category, 250.00, 'income', CURRENT_TIMESTAMP - INTERVAL '21 days', 'Gift', 'Friend'),
    (v_user10_account, v_products_category, 290.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '20 days', 'Groceries', 'Store'),
    (v_user10_account, v_transport_category, 90.00, 'expense', CURRENT_TIMESTAMP - INTERVAL '19 days', 'Taxi', 'Uber');
END $$;

DO $$
DECLARE
    v_user1_id INT;
    v_user2_id INT;
    v_user3_id INT;
    v_user4_id INT;
    v_user5_id INT;
    v_user6_id INT;
    v_user7_id INT;
    v_user8_id INT;
    v_user9_id INT;
    v_user10_id INT;
    v_products_category INT;
    v_transport_category INT;
    v_entertainment_category INT;
    v_health_category INT;
    v_education_category INT;
    v_clothing_category INT;
    v_restaurant_category INT;
    v_utilities_category INT;
BEGIN
    SELECT user_id INTO v_user1_id FROM finance.users WHERE email = 'user1@example.com' LIMIT 1;
    SELECT user_id INTO v_user2_id FROM finance.users WHERE email = 'user2@example.com' LIMIT 1;
    SELECT user_id INTO v_user3_id FROM finance.users WHERE email = 'user3@example.com' LIMIT 1;
    SELECT user_id INTO v_user4_id FROM finance.users WHERE email = 'user4@example.com' LIMIT 1;
    SELECT user_id INTO v_user5_id FROM finance.users WHERE email = 'user5@example.com' LIMIT 1;
    SELECT user_id INTO v_user6_id FROM finance.users WHERE email = 'user6@example.com' LIMIT 1;
    SELECT user_id INTO v_user7_id FROM finance.users WHERE email = 'user7@example.com' LIMIT 1;
    SELECT user_id INTO v_user8_id FROM finance.users WHERE email = 'user8@example.com' LIMIT 1;
    SELECT user_id INTO v_user9_id FROM finance.users WHERE email = 'user9@example.com' LIMIT 1;
    SELECT user_id INTO v_user10_id FROM finance.users WHERE email = 'user10@example.com' LIMIT 1;
    
    SELECT category_id INTO v_products_category FROM finance.categories WHERE name = 'Продукты' LIMIT 1;
    SELECT category_id INTO v_transport_category FROM finance.categories WHERE name = 'Транспорт' LIMIT 1;
    SELECT category_id INTO v_entertainment_category FROM finance.categories WHERE name = 'Развлечения' LIMIT 1;
    SELECT category_id INTO v_health_category FROM finance.categories WHERE name = 'Здоровье' LIMIT 1;
    SELECT category_id INTO v_education_category FROM finance.categories WHERE name = 'Образование' LIMIT 1;
    SELECT category_id INTO v_clothing_category FROM finance.categories WHERE name = 'Одежда' LIMIT 1;
    SELECT category_id INTO v_restaurant_category FROM finance.categories WHERE name = 'Рестораны' LIMIT 1;
    SELECT category_id INTO v_utilities_category FROM finance.categories WHERE name = 'Коммунальные услуги' LIMIT 1;
    
    PERFORM set_config('app.current_user_id', v_user1_id::text, false);
    INSERT INTO finance.budgets (user_id, category_id, period, limit_amount) VALUES
    (v_user1_id, v_products_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 5000.00),
    (v_user1_id, v_transport_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 2000.00),
    (v_user1_id, v_entertainment_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 3000.00),
    (v_user1_id, v_health_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 5000.00),
    (v_user1_id, v_education_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 10000.00),
    (v_user1_id, v_clothing_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 8000.00),
    (v_user1_id, v_restaurant_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 4000.00),
    (v_user1_id, v_utilities_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 6000.00),
    (v_user1_id, v_products_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 5500.00),
    (v_user1_id, v_transport_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 2200.00),
    (v_user1_id, v_entertainment_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 3500.00),
    (v_user1_id, v_health_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 5500.00);
    
    PERFORM set_config('app.current_user_id', v_user2_id::text, false);
    INSERT INTO finance.budgets (user_id, category_id, period, limit_amount) VALUES
    (v_user2_id, v_products_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 300.00),
    (v_user2_id, v_transport_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 150.00),
    (v_user2_id, v_entertainment_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 250.00),
    (v_user2_id, v_health_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 400.00),
    (v_user2_id, v_education_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 600.00),
    (v_user2_id, v_clothing_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 500.00),
    (v_user2_id, v_restaurant_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 300.00),
    (v_user2_id, v_utilities_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 400.00),
    (v_user2_id, v_products_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 350.00),
    (v_user2_id, v_transport_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 180.00),
    (v_user2_id, v_entertainment_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 300.00),
    (v_user2_id, v_health_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 450.00);
    
    PERFORM set_config('app.current_user_id', v_user3_id::text, false);
    INSERT INTO finance.budgets (user_id, category_id, period, limit_amount) VALUES
    (v_user3_id, v_products_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 400.00),
    (v_user3_id, v_transport_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 200.00),
    (v_user3_id, v_entertainment_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 300.00),
    (v_user3_id, v_health_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 500.00),
    (v_user3_id, v_education_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 700.00),
    (v_user3_id, v_clothing_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 600.00),
    (v_user3_id, v_restaurant_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 350.00),
    (v_user3_id, v_utilities_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 450.00),
    (v_user3_id, v_products_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 450.00),
    (v_user3_id, v_transport_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 220.00),
    (v_user3_id, v_entertainment_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 350.00),
    (v_user3_id, v_health_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 550.00);
    
    PERFORM set_config('app.current_user_id', v_user4_id::text, false);
    INSERT INTO finance.budgets (user_id, category_id, period, limit_amount) VALUES
    (v_user4_id, v_products_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 6000.00),
    (v_user4_id, v_transport_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 1500.00),
    (v_user4_id, v_entertainment_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 4000.00),
    (v_user4_id, v_health_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 8000.00),
    (v_user4_id, v_education_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 12000.00),
    (v_user4_id, v_clothing_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 10000.00),
    (v_user4_id, v_restaurant_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 5000.00),
    (v_user4_id, v_utilities_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 8000.00),
    (v_user4_id, v_products_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 6500.00),
    (v_user4_id, v_transport_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 1700.00),
    (v_user4_id, v_entertainment_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 4500.00),
    (v_user4_id, v_health_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 8500.00);
    
    PERFORM set_config('app.current_user_id', v_user5_id::text, false);
    INSERT INTO finance.budgets (user_id, category_id, period, limit_amount) VALUES
    (v_user5_id, v_products_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 400.00),
    (v_user5_id, v_transport_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 200.00),
    (v_user5_id, v_entertainment_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 350.00),
    (v_user5_id, v_health_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 600.00),
    (v_user5_id, v_education_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 800.00),
    (v_user5_id, v_clothing_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 700.00),
    (v_user5_id, v_restaurant_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 400.00),
    (v_user5_id, v_utilities_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 500.00),
    (v_user5_id, v_products_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 450.00),
    (v_user5_id, v_transport_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 220.00),
    (v_user5_id, v_entertainment_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 400.00),
    (v_user5_id, v_health_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 650.00);
    
    PERFORM set_config('app.current_user_id', v_user6_id::text, false);
    INSERT INTO finance.budgets (user_id, category_id, period, limit_amount) VALUES
    (v_user6_id, v_products_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 5000.00),
    (v_user6_id, v_transport_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 1200.00),
    (v_user6_id, v_entertainment_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 3500.00),
    (v_user6_id, v_health_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 7000.00),
    (v_user6_id, v_education_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 11000.00),
    (v_user6_id, v_clothing_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 9000.00),
    (v_user6_id, v_restaurant_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 4500.00),
    (v_user6_id, v_utilities_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 7500.00),
    (v_user6_id, v_products_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 5500.00),
    (v_user6_id, v_transport_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 1400.00),
    (v_user6_id, v_entertainment_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 4000.00),
    (v_user6_id, v_health_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 7500.00);
    
    PERFORM set_config('app.current_user_id', v_user7_id::text, false);
    INSERT INTO finance.budgets (user_id, category_id, period, limit_amount) VALUES
    (v_user7_id, v_products_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 500.00),
    (v_user7_id, v_transport_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 250.00),
    (v_user7_id, v_entertainment_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 400.00),
    (v_user7_id, v_health_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 700.00),
    (v_user7_id, v_education_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 900.00),
    (v_user7_id, v_clothing_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 800.00),
    (v_user7_id, v_restaurant_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 450.00),
    (v_user7_id, v_utilities_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 550.00),
    (v_user7_id, v_products_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 550.00),
    (v_user7_id, v_transport_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 280.00),
    (v_user7_id, v_entertainment_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 450.00),
    (v_user7_id, v_health_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 750.00);
    
    PERFORM set_config('app.current_user_id', v_user8_id::text, false);
    INSERT INTO finance.budgets (user_id, category_id, period, limit_amount) VALUES
    (v_user8_id, v_products_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 600.00),
    (v_user8_id, v_transport_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 300.00),
    (v_user8_id, v_entertainment_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 450.00),
    (v_user8_id, v_health_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 800.00),
    (v_user8_id, v_education_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 1000.00),
    (v_user8_id, v_clothing_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 900.00),
    (v_user8_id, v_restaurant_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 500.00),
    (v_user8_id, v_utilities_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 600.00),
    (v_user8_id, v_products_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 650.00),
    (v_user8_id, v_transport_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 320.00),
    (v_user8_id, v_entertainment_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 500.00),
    (v_user8_id, v_health_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 850.00);
    
    PERFORM set_config('app.current_user_id', v_user9_id::text, false);
    INSERT INTO finance.budgets (user_id, category_id, period, limit_amount) VALUES
    (v_user9_id, v_products_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 7000.00),
    (v_user9_id, v_transport_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 1800.00),
    (v_user9_id, v_entertainment_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 5000.00),
    (v_user9_id, v_health_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 9000.00),
    (v_user9_id, v_education_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 14000.00),
    (v_user9_id, v_clothing_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 12000.00),
    (v_user9_id, v_restaurant_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 6000.00),
    (v_user9_id, v_utilities_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 9000.00),
    (v_user9_id, v_products_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 7500.00),
    (v_user9_id, v_transport_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 2000.00),
    (v_user9_id, v_entertainment_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 5500.00),
    (v_user9_id, v_health_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 9500.00);
    
    PERFORM set_config('app.current_user_id', v_user10_id::text, false);
    INSERT INTO finance.budgets (user_id, category_id, period, limit_amount) VALUES
    (v_user10_id, v_products_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 700.00),
    (v_user10_id, v_transport_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 350.00),
    (v_user10_id, v_entertainment_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 500.00),
    (v_user10_id, v_health_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 900.00),
    (v_user10_id, v_education_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 1100.00),
    (v_user10_id, v_clothing_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 1000.00),
    (v_user10_id, v_restaurant_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 550.00),
    (v_user10_id, v_utilities_category, TO_CHAR(CURRENT_DATE, 'YYYY-MM'), 650.00),
    (v_user10_id, v_products_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 750.00),
    (v_user10_id, v_transport_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 380.00),
    (v_user10_id, v_entertainment_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 550.00),
    (v_user10_id, v_health_category, TO_CHAR(CURRENT_DATE + INTERVAL '1 month', 'YYYY-MM'), 950.00);
END $$;
