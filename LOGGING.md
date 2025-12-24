# Система логирования

## Описание

В приложении реализована система логирования, которая отслеживает:
1. **HTTP запросы** - все входящие запросы и ответы с информацией о пользователе
2. **Подключения к БД** - создание сессий, подключений и выполнение запросов

## Файлы логов

- `database.log` - логи подключений к БД и выполнения SQL запросов
- `http_requests.log` - логи HTTP запросов и ответов

## Что логируется

### HTTP запросы (LoggingMiddleware)

Для каждого HTTP запроса логируется:
- Метод запроса (GET, POST, PUT, DELETE и т.д.)
- Путь запроса
- ID пользователя приложения (из JWT токена)
- Роль пользователя приложения (admin, user, operator)
- IP адрес клиента
- Статус ответа
- Время выполнения запроса

**Пример лога:**
```
2025-12-23 08:10:15 - http - INFO - REQUEST - Method: GET, Path: /users/me, App User ID: 1, App Role: admin, Client: 127.0.0.1
2025-12-23 08:10:15 - http - INFO - RESPONSE - Method: GET, Path: /users/me, Status: 200, App User ID: 1, App Role: admin, Time: 0.045s
```

### Подключения к БД (connection.py)

Для каждого подключения к БД логируется:
- Создание engines для разных ролей
- Создание пулов подключений
- Создание сессий с указанием:
  - Роли пользователя приложения
  - Пользователя БД (finance_admin_user, finance_client_user, finance_operator_user)
  - ID пользователя приложения
- Установка RLS параметров
- Получение и освобождение подключений
- Ошибки подключения

**Пример лога:**
```
2025-12-23 08:10:15 - database - INFO - Created engine for role 'admin' with DB user: finance_admin_user
2025-12-23 08:10:15 - database - INFO - Creating session - App Role: admin, DB User: finance_admin_user, App User ID: 1
2025-12-23 08:10:15 - database - INFO - Session active - DB User: finance_admin_user, Session User: finance_admin_user
2025-12-23 08:10:15 - database - DEBUG - Session committed - App Role: admin, DB User: finance_admin_user
```

## Уровни логирования

- **INFO** - основная информация о запросах и подключениях
- **DEBUG** - детальная информация (установка параметров, закрытие сессий)
- **WARNING** - предупреждения (например, если не удалось установить роль)
- **ERROR** - ошибки подключения или выполнения запросов

## Настройка

Логирование настраивается в:
- `src/database/connection.py` - для БД запросов
- `src/middleware/logging_middleware.py` - для HTTP запросов

По умолчанию логи пишутся в файлы и выводятся в консоль.

## Просмотр логов

```bash
# Просмотр логов БД
tail -f database.log

# Просмотр логов HTTP запросов
tail -f http_requests.log

# Поиск запросов конкретного пользователя
grep "App User ID: 1" http_requests.log

# Поиск запросов от имени admin
grep "App Role: admin" http_requests.log

# Поиск подключений от имени finance_admin_user
grep "DB User: finance_admin_user" database.log
```

## Примеры использования

### Отслеживание запросов пользователя
```bash
grep "App User ID: 1" http_requests.log | tail -20
```

### Отслеживание подключений к БД
```bash
grep "Creating session" database.log | tail -20
```

### Поиск ошибок
```bash
grep "ERROR" database.log
grep "ERROR" http_requests.log
```

## Важно

- Файлы логов добавлены в `.gitignore` и не попадут в репозиторий
- Логи могут расти быстро, рекомендуется настроить ротацию логов
- В production рекомендуется использовать более продвинутые системы логирования (ELK, Splunk и т.д.)

