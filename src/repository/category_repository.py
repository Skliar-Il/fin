from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, delete
from sqlalchemy.orm import selectinload
from typing import Optional, List
from src.database.models import Category
from src.database.connection import database


class CategoryRepository:
    @staticmethod
    async def create(name: str, parent_id: Optional[int] = None) -> Category:
        """Create a new category"""
        async for session in database.get_session():
            category = Category(
                name=name,
                parent_id=parent_id
            )
            session.add(category)
            await session.flush()
            await session.refresh(category)
            await session.commit()
            return category
    
    @staticmethod
    async def get_by_id(category_id: int) -> Optional[Category]:
        """Get category by ID"""
        async for session in database.get_session():
            result = await session.execute(
                select(Category)
                .options(selectinload(Category.parent), selectinload(Category.children))
                .where(Category.category_id == category_id)
            )
            return result.scalar_one_or_none()
    
    @staticmethod
    async def get_all(skip: int = 0, limit: int = 100) -> List[Category]:
        """Get all categories with pagination"""
        async for session in database.get_session():
            result = await session.execute(
                select(Category).offset(skip).limit(limit)
            )
            return list(result.scalars().all())
    
    @staticmethod
    async def get_by_parent_id(parent_id: Optional[int], skip: int = 0, limit: int = 100) -> List[Category]:
        """Get categories by parent_id"""
        async for session in database.get_session():
            result = await session.execute(
                select(Category)
                .where(Category.parent_id == parent_id)
                .offset(skip)
                .limit(limit)
            )
            return list(result.scalars().all())
    
    @staticmethod
    async def update(category_id: int, name: Optional[str] = None,
                     parent_id: Optional[int] = None) -> Optional[Category]:
        """Update category"""
        async for session in database.get_session():
            update_data = {}
            if name is not None:
                update_data["name"] = name
            if parent_id is not None:
                update_data["parent_id"] = parent_id
            
            await session.execute(
                update(Category).where(Category.category_id == category_id).values(**update_data)
            )
            await session.commit()
        return await CategoryRepository.get_by_id(category_id)
    
    @staticmethod
    async def delete(category_id: int) -> bool:
        """Delete category"""
        async for session in database.get_session():
            await session.execute(
                delete(Category).where(Category.category_id == category_id)
            )
            await session.commit()
        return True
