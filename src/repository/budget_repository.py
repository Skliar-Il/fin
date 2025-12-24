from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, delete
from sqlalchemy.orm import selectinload
from typing import Optional, List
from src.database.models import Budget
from src.database.connection import database
from decimal import Decimal


class BudgetRepository:
    @staticmethod
    async def create(user_id: int, category_id: int, period: str,
                     limit_amount: Decimal) -> Budget:
        """Create a new budget"""
        async for session in database.get_session():
            budget = Budget(
                user_id=user_id,
                category_id=category_id,
                period=period,
                limit_amount=limit_amount
            )
            session.add(budget)
            await session.flush()
            await session.refresh(budget)
            await session.commit()
            return budget
    
    @staticmethod
    async def get_by_id(budget_id: int) -> Optional[Budget]:
        """Get budget by ID"""
        async for session in database.get_session():
            result = await session.execute(
                select(Budget)
                .options(selectinload(Budget.user), selectinload(Budget.category))
                .where(Budget.budget_id == budget_id)
            )
            return result.scalar_one_or_none()
    
    @staticmethod
    async def get_by_user_id(user_id: int, skip: int = 0, limit: int = 100) -> List[Budget]:
        """Get all budgets for a user"""
        async for session in database.get_session():
            result = await session.execute(
                select(Budget)
                .where(Budget.user_id == user_id)
                .offset(skip)
                .limit(limit)
            )
            return list(result.scalars().all())
    
    @staticmethod
    async def get_by_category_id(category_id: int, skip: int = 0, limit: int = 100) -> List[Budget]:
        """Get all budgets for a category"""
        async for session in database.get_session():
            result = await session.execute(
                select(Budget)
                .where(Budget.category_id == category_id)
                .offset(skip)
                .limit(limit)
            )
            return list(result.scalars().all())
    
    @staticmethod
    async def get_all(skip: int = 0, limit: int = 100) -> List[Budget]:
        """Get all budgets with pagination"""
        async for session in database.get_session():
            result = await session.execute(
                select(Budget).offset(skip).limit(limit)
            )
            return list(result.scalars().all())
    
    @staticmethod
    async def update(budget_id: int, user_id: Optional[int] = None,
                     category_id: Optional[int] = None,
                     period: Optional[str] = None,
                     limit_amount: Optional[Decimal] = None) -> Optional[Budget]:
        """Update budget"""
        async for session in database.get_session():
            update_data = {}
            if user_id is not None:
                update_data["user_id"] = user_id
            if category_id is not None:
                update_data["category_id"] = category_id
            if period is not None:
                update_data["period"] = period
            if limit_amount is not None:
                update_data["limit_amount"] = limit_amount
            
            await session.execute(
                update(Budget).where(Budget.budget_id == budget_id).values(**update_data)
            )
            await session.commit()
        return await BudgetRepository.get_by_id(budget_id)
    
    @staticmethod
    async def delete(budget_id: int) -> bool:
        """Delete budget"""
        async for session in database.get_session():
            await session.execute(
                delete(Budget).where(Budget.budget_id == budget_id)
            )
            await session.commit()
        return True
