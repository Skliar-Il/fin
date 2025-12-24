from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, delete, text
from sqlalchemy.orm import selectinload
from typing import Optional, List
from src.database.models import Account
from src.database.connection import database, current_user_id


class AccountRepository:
    @staticmethod
    async def create(user_id: int, name: str, type: str, 
                     balance: float, currency: str) -> Account:
        async for session in database.get_session():
            current_user = current_user_id.get()
            if current_user is not None:
                await session.execute(text(f"SET LOCAL app.current_user_id = {current_user}"))
            
            account = Account(
                user_id=user_id,
                name=name,
                type=type,
                balance=balance,
                currency=currency
            )
            session.add(account)
            await session.flush()
            await session.refresh(account)
            await session.commit()
            return account
    
    @staticmethod
    async def get_by_id(account_id: int) -> Optional[Account]:
        """Get account by ID"""
        async for session in database.get_session():
            result = await session.execute(
                select(Account)
                .options(selectinload(Account.user), selectinload(Account.transactions))
                .where(Account.account_id == account_id)
            )
            return result.scalar_one_or_none()
    
    @staticmethod
    async def get_by_user_id(user_id: int) -> List[Account]:
        """Get all accounts for a user"""
        async for session in database.get_session():
            result = await session.execute(
                select(Account)
                .where(Account.user_id == user_id)
            )
            return list(result.scalars().all())
    
    @staticmethod
    async def get_all(skip: int = 0, limit: int = 100) -> List[Account]:
        """Get all accounts with pagination"""
        async for session in database.get_session():
            result = await session.execute(
                select(Account).offset(skip).limit(limit)
            )
            return list(result.scalars().all())
    
    @staticmethod
    async def update(account_id: int, name: Optional[str] = None,
                     type: Optional[str] = None,
                     balance: Optional[float] = None,
                     currency: Optional[str] = None) -> Optional[Account]:
        async for session in database.get_session():
            user_id = current_user_id.get()
            if user_id is not None:
                await session.execute(text(f"SET LOCAL app.current_user_id = {user_id}"))
            
            update_data = {}
            if name is not None:
                update_data["name"] = name
            if type is not None:
                update_data["type"] = type
            if balance is not None:
                update_data["balance"] = balance
            if currency is not None:
                update_data["currency"] = currency
            
            await session.execute(
                update(Account).where(Account.account_id == account_id).values(**update_data)
            )
            await session.commit()
        return await AccountRepository.get_by_id(account_id)
    
    @staticmethod
    async def delete(account_id: int) -> bool:
        async for session in database.get_session():
            user_id = current_user_id.get()
            if user_id is not None:
                await session.execute(text(f"SET LOCAL app.current_user_id = {user_id}"))
            
            await session.execute(
                delete(Account).where(Account.account_id == account_id)
            )
            await session.commit()
        return True
