from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker
from sqlalchemy import text
from src.database.connection import AsyncSessionLocal, current_user_id
from typing import Optional, AsyncGenerator
from contextvars import ContextVar

# Context variable для хранения текущей роли
current_user_role: ContextVar[Optional[str]] = ContextVar('current_user_role', default=None)


class RoleBasedDatabase:
    """Класс для создания подключений с ролями пользователя"""
    
    @staticmethod
    async def get_session_with_role(
        user_id: Optional[int] = None,
        user_role: Optional[str] = None
    ) -> AsyncGenerator[AsyncSession, None]:
        """
        Получить сессию БД с установленной ролью пользователя
        
        Args:
            user_id: ID пользователя
            user_role: Роль пользователя ('admin' или 'user')
        """
        effective_user_id = user_id if user_id is not None else current_user_id.get()
        effective_role = user_role if user_role is not None else current_user_role.get()
        
        async with AsyncSessionLocal() as session:
            try:
                # Устанавливаем user_id для RLS
                if effective_user_id is not None:
                    await session.execute(text(f"SET LOCAL app.current_user_id = {effective_user_id}"))
                
                # Устанавливаем роль пользователя для доступа к данным
                if effective_role == 'admin':
                    # Admin может работать от имени любого пользователя или видеть все данные
                    # Устанавливаем роль в БД
                    await session.execute(text("SET LOCAL ROLE finance_admin"))
                elif effective_role == 'user':
                    # User работает только со своими данными (RLS уже настроен)
                    await session.execute(text("SET LOCAL ROLE finance_client"))
                
                yield session
                await session.commit()
            except Exception:
                await session.rollback()
                raise
            finally:
                await session.close()


# Глобальный экземпляр
role_db = RoleBasedDatabase()

