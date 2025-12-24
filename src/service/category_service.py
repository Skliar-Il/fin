from typing import Optional, List
from src.repository.category_repository import CategoryRepository
from src.database.models import Category


class CategoryService:
    def __init__(self):
        self.category_repo = CategoryRepository()
    
    async def create_category(self, name: str, parent_id: Optional[int] = None) -> Category:
        """Create a new category"""
        if parent_id:
            parent = await self.category_repo.get_by_id(parent_id)
            if not parent:
                raise ValueError(f"Parent category with id {parent_id} not found")
        return await self.category_repo.create(name, parent_id)
    
    async def get_category(self, category_id: int) -> Optional[Category]:
        """Get category by ID"""
        return await self.category_repo.get_by_id(category_id)
    
    async def get_all_categories(self, skip: int = 0, limit: int = 100) -> List[Category]:
        """Get all categories"""
        return await self.category_repo.get_all(skip, limit)
    
    async def get_child_categories(self, parent_id: Optional[int], skip: int = 0, limit: int = 100) -> List[Category]:
        """Get categories by parent_id"""
        return await self.category_repo.get_by_parent_id(parent_id, skip, limit)
    
    async def update_category(self, category_id: int, name: Optional[str] = None,
                              parent_id: Optional[int] = None) -> Optional[Category]:
        """Update category"""
        if parent_id is not None:
            if parent_id == category_id:
                raise ValueError("Category cannot be its own parent")
            parent = await self.category_repo.get_by_id(parent_id)
            if not parent:
                raise ValueError(f"Parent category with id {parent_id} not found")
        return await self.category_repo.update(category_id, name, parent_id)
    
    async def delete_category(self, category_id: int) -> bool:
        """Delete category"""
        return await self.category_repo.delete(category_id)

