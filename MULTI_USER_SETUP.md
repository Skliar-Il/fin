# Настройка подключения от имени разных пользователей БД

## Описание

Приложение теперь подключается к PostgreSQL от имени разных пользователей в зависимости от роли пользователя приложения:

- **finance_admin_user** - для пользователей с ролью `admin`
- **finance_client_user** - для пользователей с ролью `user`
- **finance_operator_user** - для пользователей с ролью `operator`

## Пользователи БД

### 1. finance_admin_user
- **Пароль**: `admin_password_123`
- **Роль**: `finance_admin`
- **Права**: Полный доступ ко всем объектам схемы `finance`
- **Использование**: Подключение от имени администраторов приложения

### 2. finance_client_user
- **Пароль**: `client_password_123`
- **Роль**: `finance_client`
- **Права**: Только чтение (SELECT) своих данных (через RLS)
- **Использование**: Подключение от имени обычных пользователей

### 3. finance_operator_user
- **Пароль**: `operator_password_123`
- **Роль**: `finance_operator`
- **Права**: Создание и изменение данных, но без удаления критических
- **Использование**: Подключение от имени операторов

## Как это работает

1. **Middleware** извлекает роль из JWT токена
2. **Connection.py** выбирает соответствующий пользователь БД на основе роли
3. **Создается отдельный engine и session maker** для каждой роли
4. **RLS** дополнительно ограничивает доступ к данным

## Конфигурация

Настройки пользователей БД находятся в `.env`:

```env
DB_USER_ADMIN=finance_admin_user
DB_PASSWORD_ADMIN=admin_password_123

DB_USER_CLIENT=finance_client_user
DB_PASSWORD_CLIENT=client_password_123

DB_USER_OPERATOR=finance_operator_user
DB_PASSWORD_OPERATOR=operator_password_123
```

## Преимущества

1. **Безопасность**: Разделение прав на уровне БД
2. **Аудит**: Можно отслеживать, кто и от какого пользователя БД подключался
3. **Изоляция**: Каждая роль имеет свой пул подключений
4. **Гибкость**: Легко изменить права для конкретной роли

## Проверка работы

```bash
# Проверить подключение от имени admin
docker-compose exec db psql -U finance_admin_user -d finance -c "SELECT current_user;"

# Проверить подключение от имени client
docker-compose exec db psql -U finance_client_user -d finance -c "SELECT current_user;"

# Проверить подключение от имени operator
docker-compose exec db psql -U finance_operator_user -d finance -c "SELECT current_user;"
```

