from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, delete, text
from sqlalchemy.orm import selectinload
from typing import Optional, List
from datetime import datetime
from src.database.models import Transaction
from src.database.connection import database, current_user_id
from decimal import Decimal


class TransactionRepository:
    @staticmethod
    def _make_naive_datetime(dt: datetime) -> datetime:
        if dt.tzinfo is not None:
            return dt.replace(tzinfo=None)
        return dt
    
    @staticmethod
    async def create(account_id: int, category_id: int, amount: Decimal,
                     type: str, date: datetime, description: Optional[str] = None,
                     merchant: Optional[str] = None) -> Transaction:
        async for session in database.get_session():
            user_id = current_user_id.get()
            if user_id is not None:
                await session.execute(text(f"SET LOCAL app.current_user_id = {user_id}"))
            
            naive_date = TransactionRepository._make_naive_datetime(date)
            
            transaction = Transaction(
                account_id=account_id,
                category_id=category_id,
                amount=amount,
                type=type,
                date=naive_date,
                description=description,
                merchant=merchant
            )
            session.add(transaction)
            await session.flush()
            await session.refresh(transaction)
            await session.commit()
            return transaction
    
    @staticmethod
    async def get_by_id(transaction_id: int) -> Optional[Transaction]:
        """Get transaction by ID"""
        async for session in database.get_session():
            result = await session.execute(
                select(Transaction)
                .options(selectinload(Transaction.account), selectinload(Transaction.category))
                .where(Transaction.transaction_id == transaction_id)
            )
            return result.scalar_one_or_none()
    
    @staticmethod
    async def get_by_account_id(account_id: int, skip: int = 0, limit: int = 100) -> List[Transaction]:
        """Get all transactions for an account"""
        async for session in database.get_session():
            result = await session.execute(
                select(Transaction)
                .where(Transaction.account_id == account_id)
                .order_by(Transaction.date.desc())
                .offset(skip)
                .limit(limit)
            )
            return list(result.scalars().all())
    
    @staticmethod
    async def get_by_category_id(category_id: int, skip: int = 0, limit: int = 100) -> List[Transaction]:
        """Get all transactions for a category"""
        async for session in database.get_session():
            result = await session.execute(
                select(Transaction)
                .where(Transaction.category_id == category_id)
                .order_by(Transaction.date.desc())
                .offset(skip)
                .limit(limit)
            )
            return list(result.scalars().all())
    
    @staticmethod
    async def get_all(skip: int = 0, limit: int = 100) -> List[Transaction]:
        """Get all transactions with pagination"""
        async for session in database.get_session():
            result = await session.execute(
                select(Transaction)
                .order_by(Transaction.date.desc())
                .offset(skip)
                .limit(limit)
            )
            return list(result.scalars().all())
    
    @staticmethod
    async def update(transaction_id: int, account_id: Optional[int] = None,
                     category_id: Optional[int] = None,
                     amount: Optional[Decimal] = None,
                     type: Optional[str] = None,
                     date: Optional[datetime] = None,
                     description: Optional[str] = None,
                     merchant: Optional[str] = None) -> Optional[Transaction]:
        async for session in database.get_session():
            user_id = current_user_id.get()
            if user_id is not None:
                await session.execute(text(f"SET LOCAL app.current_user_id = {user_id}"))
            
            update_data = {}
            if account_id is not None:
                update_data["account_id"] = account_id
            if category_id is not None:
                update_data["category_id"] = category_id
            if amount is not None:
                update_data["amount"] = amount
            if type is not None:
                update_data["type"] = type
            if date is not None:
                update_data["date"] = TransactionRepository._make_naive_datetime(date)
            if description is not None:
                update_data["description"] = description
            if merchant is not None:
                update_data["merchant"] = merchant
            
            await session.execute(
                update(Transaction).where(Transaction.transaction_id == transaction_id).values(**update_data)
            )
            await session.commit()
        return await TransactionRepository.get_by_id(transaction_id)
    
    @staticmethod
    async def delete(transaction_id: int) -> bool:
        async for session in database.get_session():
            user_id = current_user_id.get()
            if user_id is not None:
                await session.execute(text(f"SET LOCAL app.current_user_id = {user_id}"))
            
            await session.execute(
                delete(Transaction).where(Transaction.transaction_id == transaction_id)
            )
            await session.commit()
        return True
