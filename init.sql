-- Создание схемы finance
CREATE SCHEMA IF NOT EXISTS finance;

-- ===== 1. СОЗДАНИЕ ТАБЛИЦ =====

CREATE TABLE IF NOT EXISTS finance.users (
    user_id SERIAL PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    currency_preference TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'user'))
);

-- Создаём уникальный индекс на email для дополнительной гарантии
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email_unique ON finance.users(email);

CREATE TABLE IF NOT EXISTS finance.users_info (
    user_id INT PRIMARY KEY NOT NULL,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL,
    patronymic TEXT,
    date_birth DATE,
    FOREIGN KEY (user_id) REFERENCES finance.users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS finance.accounts (
    account_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    balance DOUBLE PRECISION NOT NULL,
    currency TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES finance.users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS finance.categories (
    category_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    parent_id INT NULL,
    FOREIGN KEY (parent_id) REFERENCES finance.categories(category_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS finance.transactions (
    transaction_id SERIAL PRIMARY KEY,
    account_id INT NOT NULL,
    category_id INT NOT NULL,
    amount NUMERIC NOT NULL,
    type TEXT NOT NULL,
    date TIMESTAMP NOT NULL,
    description TEXT,
    merchant TEXT NULL,
    FOREIGN KEY (account_id) REFERENCES finance.accounts(account_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES finance.categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS finance.budgets (
    budget_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    category_id INT NOT NULL,
    period TEXT NOT NULL,
    limit_amount NUMERIC NOT NULL,
    FOREIGN KEY (user_id) REFERENCES finance.users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES finance.categories(category_id) ON DELETE CASCADE
);

-- Функция для обновления баланса
CREATE OR REPLACE FUNCTION finance.update_account_balance()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- При создании транзакции обновляем баланс
        IF NEW.type = 'income' THEN
            UPDATE finance.accounts 
            SET balance = balance + NEW.amount 
            WHERE account_id = NEW.account_id;
        ELSIF NEW.type = 'expense' THEN
            UPDATE finance.accounts 
            SET balance = balance - NEW.amount 
            WHERE account_id = NEW.account_id;
        END IF;
        RETURN NEW;
    
    ELSIF TG_OP = 'UPDATE' THEN
        -- При обновлении транзакции пересчитываем баланс
        IF OLD.type = 'income' THEN
            UPDATE finance.accounts 
            SET balance = balance - OLD.amount 
            WHERE account_id = OLD.account_id;
        ELSIF OLD.type = 'expense' THEN
            UPDATE finance.accounts 
            SET balance = balance + OLD.amount 
            WHERE account_id = OLD.account_id;
        END IF;
        
        IF NEW.type = 'income' THEN
            UPDATE finance.accounts 
            SET balance = balance + NEW.amount 
            WHERE account_id = NEW.account_id;
        ELSIF NEW.type = 'expense' THEN
            UPDATE finance.accounts 
            SET balance = balance - NEW.amount 
            WHERE account_id = NEW.account_id;
        END IF;
        RETURN NEW;
    
    ELSIF TG_OP = 'DELETE' THEN
        -- При удалении транзакции возвращаем баланс
        IF OLD.type = 'income' THEN
            UPDATE finance.accounts 
            SET balance = balance - OLD.amount 
            WHERE account_id = OLD.account_id;
        ELSIF OLD.type = 'expense' THEN
            UPDATE finance.accounts 
            SET balance = balance + OLD.amount 
            WHERE account_id = OLD.account_id;
        END IF;
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Триггер на транзакциях
CREATE TRIGGER trigger_update_balance
AFTER INSERT OR UPDATE OR DELETE ON finance.transactions
FOR EACH ROW EXECUTE FUNCTION finance.update_account_balance();


CREATE OR REPLACE FUNCTION finance.create_default_account()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = finance, public
AS $$
BEGIN
    PERFORM set_config('app.current_user_id', NEW.user_id::text, false);
    PERFORM set_config('row_security', 'off', false);
    INSERT INTO finance.accounts (user_id, name, type, balance, currency)
    VALUES (NEW.user_id, 'Основной счет', 'checking', 0, NEW.currency_preference);
    PERFORM set_config('row_security', 'on', false);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер создания аккаунта
CREATE TRIGGER trigger_create_account
AFTER INSERT ON finance.users
FOR EACH ROW EXECUTE FUNCTION finance.create_default_account();




-- Функция проверки даты
CREATE OR REPLACE FUNCTION finance.validate_transaction_date()
RETURNS TRIGGER AS $$
BEGIN
    -- Нельзя создавать транзакции в будущем (более чем на 1 день)
    IF NEW.date > CURRENT_TIMESTAMP + INTERVAL '1 day' THEN
        RAISE EXCEPTION 'Transaction date cannot be in the future';
    END IF;
    
    -- Нельзя создавать транзакции старше 10 лет
    IF NEW.date < CURRENT_TIMESTAMP - INTERVAL '10 years' THEN
        RAISE EXCEPTION 'Transaction date cannot be older than 10 years';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер проверки даты
CREATE TRIGGER trigger_validate_date
BEFORE INSERT OR UPDATE ON finance.transactions
FOR EACH ROW EXECUTE FUNCTION finance.validate_transaction_date();

-- ===== 2. НАСТРОЙКА ROW LEVEL SECURITY (RLS) =====

-- Функция для получения текущего user_id из сессии
CREATE OR REPLACE FUNCTION finance.current_user_id()
RETURNS INTEGER AS $$
BEGIN
    RETURN current_setting('app.current_user_id', true)::INTEGER;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql STABLE;

-- Включаем RLS на таблицах
ALTER TABLE finance.accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE finance.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE finance.budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE finance.users_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE finance.users ENABLE ROW LEVEL SECURITY;

-- Категории доступны всем пользователям (общие), RLS не включаем

-- Политика для accounts: пользователь видит только свои аккаунты
CREATE POLICY accounts_user_policy ON finance.accounts
    FOR ALL
    USING (user_id = finance.current_user_id())
    WITH CHECK (user_id = finance.current_user_id());

-- Политика для transactions: пользователь видит только транзакции по своим аккаунтам
CREATE POLICY transactions_user_policy ON finance.transactions
    FOR ALL
    USING (
        account_id IN (
            SELECT account_id FROM finance.accounts 
            WHERE user_id = finance.current_user_id()
        )
    )
    WITH CHECK (
        account_id IN (
            SELECT account_id FROM finance.accounts 
            WHERE user_id = finance.current_user_id()
        )
    );

-- Политика для budgets: пользователь видит только свои бюджеты
CREATE POLICY budgets_user_policy ON finance.budgets
    FOR ALL
    USING (user_id = finance.current_user_id())
    WITH CHECK (user_id = finance.current_user_id());

-- Политика для users_info: пользователь видит только свою информацию
CREATE POLICY users_info_user_policy ON finance.users_info
    FOR ALL
    USING (user_id = finance.current_user_id())
    WITH CHECK (user_id = finance.current_user_id());

-- Политика для users: пользователь видит только себя
-- Для SELECT: разрешаем поиск по email для логина (когда current_user_id NULL)
-- и доступ к своим данным (когда current_user_id установлен)
CREATE POLICY users_select_policy ON finance.users
    FOR SELECT
    USING (
        user_id = finance.current_user_id() 
        OR finance.current_user_id() IS NULL  -- Разрешаем SELECT при логине/регистрации
    );

-- Политика для INSERT: разрешаем создание новых пользователей (регистрация)
CREATE POLICY users_insert_policy ON finance.users
    FOR INSERT
    WITH CHECK (true);  -- Разрешаем создание любых пользователей при регистрации

-- Политика для UPDATE/DELETE: только свои данные
CREATE POLICY users_modify_policy ON finance.users
    FOR UPDATE
    USING (user_id = finance.current_user_id())
    WITH CHECK (user_id = finance.current_user_id());

CREATE POLICY users_delete_policy ON finance.users
    FOR DELETE
    USING (user_id = finance.current_user_id());

-- ===== 3. ТАБЛИЦА ИСТОРИИ ИЗМЕНЕНИЙ =====

-- Таблица истории изменений для критических данных (транзакции, балансы)
CREATE TABLE IF NOT EXISTS finance.transaction_history (
    history_id SERIAL PRIMARY KEY,
    transaction_id INT NOT NULL,
    account_id INT NOT NULL,
    old_amount NUMERIC,
    new_amount NUMERIC,
    old_type TEXT,
    new_type TEXT,
    old_date TIMESTAMP,
    new_date TIMESTAMP,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INT,
    operation_type TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS finance.account_balance_history (
    history_id SERIAL PRIMARY KEY,
    account_id INT NOT NULL,
    old_balance NUMERIC,
    new_balance NUMERIC,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INT,
    reason TEXT
);

-- Индексы для истории
CREATE INDEX IF NOT EXISTS idx_transaction_history_transaction_id ON finance.transaction_history(transaction_id);
CREATE INDEX IF NOT EXISTS idx_transaction_history_user_id ON finance.transaction_history(user_id);
CREATE INDEX IF NOT EXISTS idx_account_balance_history_account_id ON finance.account_balance_history(account_id);
CREATE INDEX IF NOT EXISTS idx_account_balance_history_user_id ON finance.account_balance_history(user_id);

-- ===== 4. ПРЕДСТАВЛЕНИЯ (VIEWS) =====

-- Представление: Отчет по транзакциям пользователя с категориями
CREATE OR REPLACE VIEW finance.user_transactions_report AS
SELECT 
    t.transaction_id,
    t.account_id,
    a.user_id,
    c.name AS category_name,
    t.amount,
    t.type,
    t.date,
    t.description,
    t.merchant,
    a.name AS account_name,
    a.currency
FROM finance.transactions t
JOIN finance.accounts a ON t.account_id = a.account_id
JOIN finance.categories c ON t.category_id = c.category_id
ORDER BY t.date DESC;

-- Представление: Отчет по бюджетам с текущими расходами
CREATE OR REPLACE VIEW finance.budget_usage_report AS
SELECT 
    b.budget_id,
    b.user_id,
    b.category_id,
    c.name AS category_name,
    b.period,
    b.limit_amount,
    COALESCE(SUM(CASE WHEN t.type = 'expense' THEN t.amount ELSE 0 END), 0) AS current_spending,
    (b.limit_amount - COALESCE(SUM(CASE WHEN t.type = 'expense' THEN t.amount ELSE 0 END), 0)) AS remaining,
    CASE 
        WHEN COALESCE(SUM(CASE WHEN t.type = 'expense' THEN t.amount ELSE 0 END), 0) > b.limit_amount 
        THEN 'EXCEEDED' 
        WHEN COALESCE(SUM(CASE WHEN t.type = 'expense' THEN t.amount ELSE 0 END), 0) > b.limit_amount * 0.8 
        THEN 'WARNING' 
        ELSE 'OK' 
    END AS status
FROM finance.budgets b
LEFT JOIN finance.categories c ON b.category_id = c.category_id
LEFT JOIN finance.transactions t ON t.category_id = b.category_id 
    AND t.account_id IN (SELECT account_id FROM finance.accounts WHERE user_id = b.user_id)
    AND t.type = 'expense'
GROUP BY b.budget_id, b.user_id, b.category_id, c.name, b.period, b.limit_amount;

-- Представление для ADMIN: Общая статистика по всем пользователям
CREATE OR REPLACE VIEW finance.admin_users_statistics AS
SELECT 
    u.user_id,
    u.email,
    u.currency_preference,
    u.role,
    COUNT(DISTINCT a.account_id) AS accounts_count,
    COALESCE(SUM(a.balance), 0) AS total_balance,
    COUNT(DISTINCT t.transaction_id) AS transactions_count,
    COALESCE(SUM(CASE WHEN t.type = 'income' THEN t.amount ELSE 0 END), 0) AS total_income,
    COALESCE(SUM(CASE WHEN t.type = 'expense' THEN t.amount ELSE 0 END), 0) AS total_expense,
    COUNT(DISTINCT b.budget_id) AS budgets_count
FROM finance.users u
LEFT JOIN finance.accounts a ON u.user_id = a.user_id
LEFT JOIN finance.transactions t ON a.account_id = t.account_id
LEFT JOIN finance.budgets b ON u.user_id = b.user_id
GROUP BY u.user_id, u.email, u.currency_preference, u.role;

-- Представление для ADMIN: Статистика по категориям (все пользователи)
CREATE OR REPLACE VIEW finance.admin_categories_statistics AS
SELECT 
    c.category_id,
    c.name AS category_name,
    c.parent_id,
    COUNT(DISTINCT t.transaction_id) AS transactions_count,
    COUNT(DISTINCT t.account_id) AS accounts_count,
    COUNT(DISTINCT a.user_id) AS users_count,
    COALESCE(SUM(CASE WHEN t.type = 'income' THEN t.amount ELSE 0 END), 0) AS total_income,
    COALESCE(SUM(CASE WHEN t.type = 'expense' THEN t.amount ELSE 0 END), 0) AS total_expense,
    COALESCE(AVG(CASE WHEN t.type = 'expense' THEN t.amount ELSE NULL END), 0) AS avg_expense
FROM finance.categories c
LEFT JOIN finance.transactions t ON c.category_id = t.category_id
LEFT JOIN finance.accounts a ON t.account_id = a.account_id
GROUP BY c.category_id, c.name, c.parent_id
ORDER BY total_expense DESC;

-- ===== 5. ХРАНИМЫЕ ПРОЦЕДУРЫ =====

-- Процедура: Создание транзакции с проверкой баланса
CREATE OR REPLACE PROCEDURE finance.create_transaction_with_balance_check(
    p_account_id INT,
    p_category_id INT,
    p_amount NUMERIC,
    p_type TEXT,
    p_date TIMESTAMP,
    p_description TEXT DEFAULT NULL,
    p_merchant TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_balance NUMERIC;
    v_user_id INT;
BEGIN
    -- Получаем текущий баланс и user_id
    SELECT balance, user_id INTO v_current_balance, v_user_id
    FROM finance.accounts
    WHERE account_id = p_account_id;
    
    IF v_current_balance IS NULL THEN
        RAISE EXCEPTION 'Account not found';
    END IF;
    
    -- Проверяем баланс для расходов
    IF p_type = 'expense' AND v_current_balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient balance. Current balance: %, Required: %', v_current_balance, p_amount;
    END IF;
    
    -- Создаем транзакцию (триггер обновит баланс)
    INSERT INTO finance.transactions (
        account_id, category_id, amount, type, date, description, merchant
    ) VALUES (
        p_account_id, p_category_id, p_amount, p_type, p_date, p_description, p_merchant
    );
END;
$$;

-- Процедура: Пересчет баланса для аккаунта
CREATE OR REPLACE PROCEDURE finance.recalculate_account_balance(
    p_account_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_balance NUMERIC;
    v_old_balance NUMERIC;
    v_user_id INT;
BEGIN
    -- Получаем старый баланс и user_id
    SELECT balance, user_id INTO v_old_balance, v_user_id
    FROM finance.accounts
    WHERE account_id = p_account_id;
    
    IF v_old_balance IS NULL THEN
        RAISE EXCEPTION 'Account not found';
    END IF;
    
    -- Пересчитываем баланс на основе всех транзакций
    SELECT COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END), 0)
    INTO v_new_balance
    FROM finance.transactions
    WHERE account_id = p_account_id;
    
    -- Обновляем баланс
    UPDATE finance.accounts
    SET balance = v_new_balance
    WHERE account_id = p_account_id;
    
    -- Записываем в историю
    INSERT INTO finance.account_balance_history (
        account_id, old_balance, new_balance, user_id, reason
    ) VALUES (
        p_account_id, v_old_balance, v_new_balance, finance.current_user_id(), 'Recalculation'
    );
END;
$$;

-- Процедура для ADMIN: Глобальное обновление балансов всех аккаунтов
CREATE OR REPLACE PROCEDURE finance.admin_recalculate_all_balances()
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = finance, public
AS $$
DECLARE
    v_account RECORD;
    v_new_balance NUMERIC;
    v_old_balance NUMERIC;
    v_updated_count INT := 0;
BEGIN
    -- Пересчитываем балансы для всех аккаунтов
    FOR v_account IN SELECT account_id, balance, user_id FROM finance.accounts
    LOOP
        -- Пересчитываем баланс на основе всех транзакций
        SELECT COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END), 0)
        INTO v_new_balance
        FROM finance.transactions
        WHERE account_id = v_account.account_id;
        
        v_old_balance := v_account.balance;
        
        -- Обновляем баланс только если он изменился
        IF v_old_balance != v_new_balance THEN
            UPDATE finance.accounts
            SET balance = v_new_balance
            WHERE account_id = v_account.account_id;
            
            -- Записываем в историю
            INSERT INTO finance.account_balance_history (
                account_id, old_balance, new_balance, user_id, reason
            ) VALUES (
                v_account.account_id, v_old_balance, v_new_balance, finance.current_user_id(), 'Admin Recalculation'
            );
            
            v_updated_count := v_updated_count + 1;
        END IF;
    END LOOP;
    
    RAISE NOTICE 'Updated % account balances', v_updated_count;
END;
$$;

-- Процедура для ADMIN: Глобальное обновление транзакций по параметрам
CREATE OR REPLACE PROCEDURE finance.admin_bulk_update_transactions(
    p_category_id INT DEFAULT NULL,
    p_transaction_type TEXT DEFAULT NULL,
    p_start_date TIMESTAMP DEFAULT NULL,
    p_end_date TIMESTAMP DEFAULT NULL,
    p_update_amount NUMERIC DEFAULT NULL,
    p_update_description TEXT DEFAULT NULL
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = finance, public
AS $$
DECLARE
    v_sql TEXT;
    v_updated_count INT;
BEGIN
    -- Формируем динамический SQL для обновления
    v_sql := 'UPDATE finance.transactions SET ';
    
    IF p_update_amount IS NOT NULL THEN
        v_sql := v_sql || 'amount = ' || p_update_amount || ', ';
    END IF;
    
    IF p_update_description IS NOT NULL THEN
        v_sql := v_sql || 'description = ''' || p_update_description || ''', ';
    END IF;
    
    -- Убираем последнюю запятую
    v_sql := RTRIM(v_sql, ', ');
    
    -- Добавляем условия WHERE
    v_sql := v_sql || ' WHERE 1=1';
    
    IF p_category_id IS NOT NULL THEN
        v_sql := v_sql || ' AND category_id = ' || p_category_id;
    END IF;
    
    IF p_transaction_type IS NOT NULL THEN
        v_sql := v_sql || ' AND type = ''' || p_transaction_type || '''';
    END IF;
    
    IF p_start_date IS NOT NULL THEN
        v_sql := v_sql || ' AND date >= ''' || p_start_date || '''';
    END IF;
    
    IF p_end_date IS NOT NULL THEN
        v_sql := v_sql || ' AND date <= ''' || p_end_date || '''';
    END IF;
    
    -- Выполняем обновление
    EXECUTE v_sql;
    GET DIAGNOSTICS v_updated_count = ROW_COUNT;
    
    RAISE NOTICE 'Updated % transactions', v_updated_count;
END;
$$;

-- ===== 6. ХРАНИМЫЕ ФУНКЦИИ =====

-- Функция: Проверка существования email (без RLS для регистрации)
CREATE OR REPLACE FUNCTION finance.check_email_exists(p_email TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER -- Выполняется с правами создателя функции
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM finance.users WHERE email = p_email
    );
END;
$$;

-- Функция: Генерация отчета по транзакциям с динамическим SQL
CREATE OR REPLACE FUNCTION finance.generate_transactions_report(
    p_user_id INT DEFAULT NULL,
    p_start_date TIMESTAMP DEFAULT NULL,
    p_end_date TIMESTAMP DEFAULT NULL,
    p_transaction_type TEXT DEFAULT NULL,
    p_category_id INT DEFAULT NULL
)
RETURNS TABLE (
    transaction_id INT,
    account_id INT,
    category_name TEXT,
    amount NUMERIC,
    type TEXT,
    date TIMESTAMP,
    description TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
BEGIN
    -- Динамическое формирование SQL запроса
    v_sql := '
        SELECT 
            t.transaction_id,
            t.account_id,
            c.name AS category_name,
            t.amount,
            t.type,
            t.date,
            t.description
        FROM finance.transactions t
        JOIN finance.accounts a ON t.account_id = a.account_id
        JOIN finance.categories c ON t.category_id = c.category_id
        WHERE 1=1';
    
    IF p_user_id IS NOT NULL THEN
        v_sql := v_sql || ' AND a.user_id = ' || p_user_id;
    END IF;
    
    IF p_start_date IS NOT NULL THEN
        v_sql := v_sql || ' AND t.date >= ''' || p_start_date || '''';
    END IF;
    
    IF p_end_date IS NOT NULL THEN
        v_sql := v_sql || ' AND t.date <= ''' || p_end_date || '''';
    END IF;
    
    IF p_transaction_type IS NOT NULL THEN
        v_sql := v_sql || ' AND t.type = ''' || p_transaction_type || '''';
    END IF;
    
    IF p_category_id IS NOT NULL THEN
        v_sql := v_sql || ' AND t.category_id = ' || p_category_id;
    END IF;
    
    v_sql := v_sql || ' ORDER BY t.date DESC';
    
    -- Выполнение динамического SQL
    RETURN QUERY EXECUTE v_sql;
END;
$$;

-- Функция: Статистика по категориям с динамическим SQL
CREATE OR REPLACE FUNCTION finance.get_category_statistics(
    p_user_id INT,
    p_start_date TIMESTAMP DEFAULT NULL,
    p_end_date TIMESTAMP DEFAULT NULL
)
RETURNS TABLE (
    category_id INT,
    category_name TEXT,
    total_income NUMERIC,
    total_expense NUMERIC,
    transaction_count BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
BEGIN
    -- Динамическое формирование SQL
    v_sql := '
        SELECT 
            c.category_id,
            c.name AS category_name,
            COALESCE(SUM(CASE WHEN t.type = ''income'' THEN t.amount ELSE 0 END), 0) AS total_income,
            COALESCE(SUM(CASE WHEN t.type = ''expense'' THEN t.amount ELSE 0 END), 0) AS total_expense,
            COUNT(t.transaction_id) AS transaction_count
        FROM finance.categories c
        LEFT JOIN finance.transactions t ON c.category_id = t.category_id
        LEFT JOIN finance.accounts a ON t.account_id = a.account_id
        WHERE a.user_id = ' || p_user_id;
    
    IF p_start_date IS NOT NULL THEN
        v_sql := v_sql || ' AND t.date >= ''' || p_start_date || '''';
    END IF;
    
    IF p_end_date IS NOT NULL THEN
        v_sql := v_sql || ' AND t.date <= ''' || p_end_date || '''';
    END IF;
    
    v_sql := v_sql || '
        GROUP BY c.category_id, c.name
        ORDER BY total_expense DESC';
    
    RETURN QUERY EXECUTE v_sql;
END;
$$;

-- ===== 7. ТРИГГЕРЫ ДЛЯ ИСТОРИИ ИЗМЕНЕНИЙ =====

-- Триггер для записи истории транзакций
CREATE OR REPLACE FUNCTION finance.log_transaction_history()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO finance.transaction_history (
            transaction_id, account_id, new_amount, new_type, new_date,
            operation_type, user_id
        ) VALUES (
            NEW.transaction_id, NEW.account_id, NEW.amount, NEW.type, NEW.date,
            'INSERT', finance.current_user_id()
        );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO finance.transaction_history (
            transaction_id, account_id,
            old_amount, new_amount,
            old_type, new_type,
            old_date, new_date,
            operation_type, user_id
        ) VALUES (
            NEW.transaction_id, NEW.account_id,
            OLD.amount, NEW.amount,
            OLD.type, NEW.type,
            OLD.date, NEW.date,
            'UPDATE', finance.current_user_id()
        );
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO finance.transaction_history (
            transaction_id, account_id,
            old_amount, old_type, old_date,
            operation_type, user_id
        ) VALUES (
            OLD.transaction_id, OLD.account_id,
            OLD.amount, OLD.type, OLD.date,
            'DELETE', finance.current_user_id()
        );
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$;

CREATE TRIGGER trigger_log_transaction_history
AFTER INSERT OR UPDATE OR DELETE ON finance.transactions
FOR EACH ROW EXECUTE FUNCTION finance.log_transaction_history();

-- Триггер для записи истории изменений баланса
CREATE OR REPLACE FUNCTION finance.log_balance_history()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.balance != NEW.balance THEN
        INSERT INTO finance.account_balance_history (
            account_id, old_balance, new_balance, user_id, reason
        ) VALUES (
            NEW.account_id, OLD.balance, NEW.balance, finance.current_user_id(), 'Transaction'
        );
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_log_balance_history
AFTER UPDATE ON finance.accounts
FOR EACH ROW EXECUTE FUNCTION finance.log_balance_history();

-- ===== 8. СОЗДАНИЕ ПОЛЬЗОВАТЕЛЕЙ БД =====

-- Создание пользователей PostgreSQL для подключения от имени разных ролей
DO $$
BEGIN
    -- Создаем пользователя для admin (с правами администратора)
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'finance_admin_user') THEN
        CREATE USER finance_admin_user WITH PASSWORD 'admin_password_123';
    END IF;
    
    -- Создаем пользователя для обычных пользователей (с правами клиента)
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'finance_client_user') THEN
        CREATE USER finance_client_user WITH PASSWORD 'client_password_123';
    END IF;
    
    -- Создаем пользователя для операторов (с правами оператора)
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'finance_operator_user') THEN
        CREATE USER finance_operator_user WITH PASSWORD 'operator_password_123';
    END IF;
END
$$;

-- ===== 9. РОЛИ И ПРАВА ДОСТУПА =====

-- Создание ролей (используем DO блок для проверки существования)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'finance_admin') THEN
        CREATE ROLE finance_admin WITH NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'finance_operator') THEN
        CREATE ROLE finance_operator WITH NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'finance_client') THEN
        CREATE ROLE finance_client WITH NOLOGIN;
    END IF;
END
$$;

-- Администратор: полный доступ ко всем объектам
GRANT ALL PRIVILEGES ON SCHEMA finance TO finance_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA finance TO finance_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA finance TO finance_admin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA finance TO finance_admin;
GRANT ALL PRIVILEGES ON ALL PROCEDURES IN SCHEMA finance TO finance_admin;

-- Оператор: доступ к созданию и изменению данных (но не удалению критических)
GRANT USAGE ON SCHEMA finance TO finance_operator;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA finance TO finance_operator;
GRANT SELECT ON finance.transaction_history TO finance_operator;
GRANT SELECT ON finance.account_balance_history TO finance_operator;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA finance TO finance_operator;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA finance TO finance_operator;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA finance TO finance_operator;
-- Оператор не может удалять транзакции и историю
REVOKE DELETE ON finance.transactions FROM finance_operator;
REVOKE DELETE ON finance.transaction_history FROM finance_operator;
REVOKE DELETE ON finance.account_balance_history FROM finance_operator;

-- Клиент: только чтение своих данных
GRANT USAGE ON SCHEMA finance TO finance_client;
GRANT SELECT ON finance.users TO finance_client;
GRANT SELECT, INSERT, UPDATE, DELETE ON finance.users_info TO finance_client;
GRANT SELECT, INSERT, UPDATE, DELETE ON finance.accounts TO finance_client;
GRANT SELECT ON finance.categories TO finance_client;
GRANT SELECT, INSERT, UPDATE, DELETE ON finance.transactions TO finance_client;
GRANT SELECT, INSERT, UPDATE, DELETE ON finance.budgets TO finance_client;
GRANT INSERT ON finance.transaction_history TO finance_client;
GRANT INSERT ON finance.account_balance_history TO finance_client;
GRANT SELECT ON finance.user_transactions_report TO finance_client;
GRANT SELECT ON finance.budget_usage_report TO finance_client;
GRANT SELECT, INSERT, UPDATE ON finance.users TO finance_client;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA finance TO finance_client;

-- ===== 5. НАЗНАЧЕНИЕ РОЛЕЙ ПОЛЬЗОВАТЕЛЯМ =====

-- Назначаем роли пользователям БД
GRANT finance_admin TO finance_admin_user;
GRANT finance_operator TO finance_operator_user;
GRANT finance_client TO finance_client_user;

-- Даем права на подключение к БД
GRANT CONNECT ON DATABASE finance TO finance_admin_user;
GRANT CONNECT ON DATABASE finance TO finance_client_user;
GRANT CONNECT ON DATABASE finance TO finance_operator_user;

-- Даем права на использование схемы
GRANT USAGE ON SCHEMA finance TO finance_admin_user;
GRANT USAGE ON SCHEMA finance TO finance_client_user;
GRANT USAGE ON SCHEMA finance TO finance_operator_user;

-- Ограничиваем доступ по умолчанию в схеме finance
REVOKE ALL ON SCHEMA finance FROM PUBLIC;

-- Выдаём доступ на использование схемы текущему пользователю (который создан через POSTGRES_USER)
GRANT USAGE ON SCHEMA finance TO CURRENT_USER;

-- Выдаём доступ только на CRUD к таблицам
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE
    finance.users,
    finance.users_info,
    finance.accounts,
    finance.categories,
    finance.transactions,
    finance.budgets,
    finance.transaction_history,
    finance.account_balance_history
TO CURRENT_USER;

-- Выдаём права на использование последовательностей (SERIAL)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA finance TO CURRENT_USER;

-- Выдаём права на представления
GRANT SELECT ON finance.user_transactions_report TO CURRENT_USER;
GRANT SELECT ON finance.budget_usage_report TO CURRENT_USER;

-- Выдаём права на функции и процедуры
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA finance TO CURRENT_USER;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA finance TO CURRENT_USER;

-- Устанавливаем владельца схемы
ALTER SCHEMA finance OWNER TO CURRENT_USER;

-- ===== 11. НАЗНАЧЕНИЕ РОЛЕЙ ПОЛЬЗОВАТЕЛЯМ БД =====

-- Назначаем роли пользователям БД
GRANT finance_admin TO finance_admin_user;
GRANT finance_operator TO finance_operator_user;
GRANT finance_client TO finance_client_user;

-- Даем права на подключение к БД
GRANT CONNECT ON DATABASE finance TO finance_admin_user;
GRANT CONNECT ON DATABASE finance TO finance_client_user;
GRANT CONNECT ON DATABASE finance TO finance_operator_user;

-- Даем права на использование схемы
GRANT USAGE ON SCHEMA finance TO finance_admin_user;
GRANT USAGE ON SCHEMA finance TO finance_client_user;
GRANT USAGE ON SCHEMA finance TO finance_operator_user;

-- Дополнительные права для admin_user (полный доступ)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA finance TO finance_admin_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA finance TO finance_admin_user;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA finance TO finance_admin_user;
GRANT ALL PRIVILEGES ON ALL PROCEDURES IN SCHEMA finance TO finance_admin_user;

-- Дополнительные права для operator_user
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA finance TO finance_operator_user;
GRANT SELECT ON finance.transaction_history TO finance_operator_user;
GRANT SELECT ON finance.account_balance_history TO finance_operator_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA finance TO finance_operator_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA finance TO finance_operator_user;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA finance TO finance_operator_user;
REVOKE DELETE ON finance.transactions FROM finance_operator_user;

-- Дополнительные права для client_user
GRANT SELECT, INSERT, UPDATE, DELETE ON finance.users_info TO finance_client_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON finance.accounts TO finance_client_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON finance.transactions TO finance_client_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON finance.budgets TO finance_client_user;
GRANT SELECT, INSERT, UPDATE ON finance.users TO finance_client_user;
GRANT SELECT ON finance.user_transactions_report TO finance_client_user;
GRANT SELECT ON finance.budget_usage_report TO finance_client_user;
GRANT SELECT ON finance.admin_users_statistics TO finance_client_user;
GRANT SELECT ON finance.admin_categories_statistics TO finance_client_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA finance TO finance_client_user;

