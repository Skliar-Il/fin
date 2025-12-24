from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import declarative_base
from sqlalchemy import text, event
from sqlalchemy.engine import Engine
from src.config import settings
import asyncpg
from typing import Optional, AsyncGenerator, Dict
from contextvars import ContextVar
import json
import logging
from datetime import datetime

# Настройка логгера для БД
db_logger = logging.getLogger("database")
db_logger.setLevel(logging.INFO)

# Создаем handler для файла логов, если его еще нет
if not db_logger.handlers:
    file_handler = logging.FileHandler('database.log')
    file_handler.setLevel(logging.INFO)
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    file_handler.setFormatter(formatter)
    db_logger.addHandler(file_handler)
    
    # Также добавляем вывод в консоль
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(formatter)
    db_logger.addHandler(console_handler)

# Context variable для хранения текущего user_id
current_user_id: ContextVar[Optional[int]] = ContextVar('current_user_id', default=None)
# Context variable для хранения текущей роли
current_user_role: ContextVar[Optional[str]] = ContextVar('current_user_role', default=None)

# Словарь для хранения engines для разных пользователей
_engines: Dict[str, any] = {}
_session_makers: Dict[str, any] = {}
_pools: Dict[str, asyncpg.Pool] = {}


def get_engine_for_role(role: Optional[str] = None):
    """Получить engine для конкретной роли"""
    if role == 'admin':
        if 'admin' not in _engines:
            db_user = settings.db_user_admin
            _engines['admin'] = create_async_engine(
                settings.get_database_url(settings.db_user_admin, settings.db_password_admin),
                echo=settings.debug,
                future=True
            )
            db_logger.info(f"Created engine for role 'admin' with DB user: {db_user}")
        return _engines['admin']
    elif role == 'operator':
        if 'operator' not in _engines:
            db_user = settings.db_user_operator
            _engines['operator'] = create_async_engine(
                settings.get_database_url(settings.db_user_operator, settings.db_password_operator),
                echo=settings.debug,
                future=True
            )
            db_logger.info(f"Created engine for role 'operator' with DB user: {db_user}")
        return _engines['operator']
    elif role == 'user':
        if 'client' not in _engines:
            db_user = settings.db_user_client
            _engines['client'] = create_async_engine(
                settings.get_database_url(settings.db_user_client, settings.db_password_client),
                echo=settings.debug,
                future=True
            )
            db_logger.info(f"Created engine for role 'user' with DB user: {db_user}")
        return _engines['client']
    else:
        # По умолчанию используем основной engine
        if 'default' not in _engines:
            db_user = settings.db_user
            _engines['default'] = create_async_engine(
                settings.database_url,
                echo=settings.debug,
                future=True
            )
            db_logger.info(f"Created default engine with DB user: {db_user}")
        return _engines['default']


def get_session_maker_for_role(role: Optional[str] = None):
    """Получить session maker для конкретной роли"""
    engine = get_engine_for_role(role)
    role_key = role or 'default'
    
    if role_key not in _session_makers:
        _session_makers[role_key] = async_sessionmaker(
            engine,
            class_=AsyncSession,
            expire_on_commit=False,
            autocommit=False,
            autoflush=False
        )
    return _session_makers[role_key]


# SQLAlchemy setup (по умолчанию)
engine = get_engine_for_role()
AsyncSessionLocal = get_session_maker_for_role()


class Database:
    def __init__(self):
        self.pools: Dict[str, asyncpg.Pool] = {}
    
    async def connect(self):
        """Create asyncpg connection pools for different roles"""
        # Создаем пулы для разных ролей
        self.pools['admin'] = await asyncpg.create_pool(
            settings.get_asyncpg_url(settings.db_user_admin, settings.db_password_admin),
            min_size=2,
            max_size=10
        )
        self.pools['client'] = await asyncpg.create_pool(
            settings.get_asyncpg_url(settings.db_user_client, settings.db_password_client),
            min_size=5,
            max_size=20
        )
        self.pools['operator'] = await asyncpg.create_pool(
            settings.get_asyncpg_url(settings.db_user_operator, settings.db_password_operator),
            min_size=2,
            max_size=10
        )
        # Пул по умолчанию
        self.pools['default'] = await asyncpg.create_pool(
            settings.asyncpg_url,
            min_size=2,
            max_size=10
        )
    
    async def disconnect(self):
        """Close all asyncpg connection pools"""
        for pool in self.pools.values():
            if pool:
                await pool.close()
        self.pools.clear()
    
    async def get_session(self, user_id: Optional[int] = None, user_role: Optional[str] = None) -> AsyncGenerator[AsyncSession, None]:
        """
        Get SQLAlchemy async session with optional user_id and role for RLS.
        Подключается от имени соответствующего пользователя БД в зависимости от роли.
        """
        # Используем переданные значения или берем из контекста
        effective_user_id = user_id if user_id is not None else current_user_id.get()
        effective_role = user_role if user_role is not None else current_user_role.get()
        
        # Определяем пользователя БД для логирования
        db_user_map = {
            'admin': settings.db_user_admin,
            'operator': settings.db_user_operator,
            'user': settings.db_user_client,
            None: settings.db_user
        }
        db_user = db_user_map.get(effective_role, settings.db_user)
        
        db_logger.info(
            f"Creating session - App Role: {effective_role or 'default'}, "
            f"DB User: {db_user}, App User ID: {effective_user_id}"
        )
        
        # Получаем session maker для конкретной роли
        session_maker = get_session_maker_for_role(effective_role)
        
        async with session_maker() as session:
            try:
                # Устанавливаем user_id в сессии PostgreSQL для RLS
                if effective_user_id is not None:
                    await session.execute(text(f"SET LOCAL app.current_user_id = {effective_user_id}"))
                    db_logger.debug(f"Set app.current_user_id = {effective_user_id}")
                
                # Подключение уже происходит от имени правильного пользователя БД
                # (admin_user, client_user, operator_user)
                # Дополнительно устанавливаем роль для доступа к данным
                if effective_role == 'admin':
                    try:
                        await session.execute(text("SET LOCAL ROLE finance_admin"))
                        db_logger.debug("Set ROLE finance_admin")
                    except Exception as e:
                        db_logger.warning(f"Failed to set ROLE finance_admin: {e}")
                elif effective_role == 'user':
                    try:
                        await session.execute(text("SET LOCAL ROLE finance_client"))
                        db_logger.debug("Set ROLE finance_client")
                    except Exception as e:
                        db_logger.warning(f"Failed to set ROLE finance_client: {e}")
                elif effective_role == 'operator':
                    try:
                        await session.execute(text("SET LOCAL ROLE finance_operator"))
                        db_logger.debug("Set ROLE finance_operator")
                    except Exception as e:
                        db_logger.warning(f"Failed to set ROLE finance_operator: {e}")
                
                # Получаем текущего пользователя БД для логирования
                try:
                    result = await session.execute(text("SELECT current_user, session_user"))
                    row = result.first()
                    if row:
                        db_logger.info(f"Session active - DB User: {row[0]}, Session User: {row[1]}")
                except Exception as e:
                    db_logger.warning(f"Failed to get current user: {e}")
                
                yield session
            except Exception as e:
                await session.rollback()
                db_logger.error(
                    f"Session error - App Role: {effective_role}, DB User: {db_user}, "
                    f"App User ID: {effective_user_id}, Error: {str(e)}"
                )
                raise
            finally:
                await session.close()
                db_logger.debug(f"Session closed - App Role: {effective_role}, DB User: {db_user}")
    
    async def get_connection(self, role: Optional[str] = None) -> asyncpg.Connection:
        """Get asyncpg connection from pool for specific role"""
        pool_key = role or 'default'
        if pool_key not in self.pools:
            await self.connect()
        
        db_user_map = {
            'admin': settings.db_user_admin,
            'operator': settings.db_user_operator,
            'user': settings.db_user_client,
            None: settings.db_user
        }
        db_user = db_user_map.get(role, settings.db_user)
        
        db_logger.info(f"Acquiring connection - App Role: {role or 'default'}, DB User: {db_user}")
        conn = await self.pools[pool_key].acquire()
        db_logger.debug(f"Connection acquired - App Role: {role or 'default'}, DB User: {db_user}")
        return conn
    
    async def release_connection(self, conn: asyncpg.Connection, role: Optional[str] = None):
        """Release asyncpg connection back to pool"""
        pool_key = role or 'default'
        if pool_key in self.pools:
            db_user_map = {
                'admin': settings.db_user_admin,
                'operator': settings.db_user_operator,
                'user': settings.db_user_client,
                None: settings.db_user
            }
            db_user = db_user_map.get(role, settings.db_user)
            db_logger.debug(f"Releasing connection - App Role: {role or 'default'}, DB User: {db_user}")
            await self.pools[pool_key].release(conn)


# Global database instance
database = Database()

