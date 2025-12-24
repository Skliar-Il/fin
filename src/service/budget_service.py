from typing import Optional, List
from src.repository.budget_repository import BudgetRepository
from src.repository.user_repository import UserRepository
from src.repository.category_repository import CategoryRepository
from src.database.models import Budget
from decimal import Decimal


class BudgetService:
    def __init__(self):
        self.budget_repo = BudgetRepository()
        self.user_repo = UserRepository()
        self.category_repo = CategoryRepository()
    
    async def create_budget(self, user_id: int, category_id: int, period: str,
                            limit_amount: Decimal) -> Budget:
        """Create a new budget"""
        user = await self.user_repo.get_by_id(user_id)
        if not user:
            raise ValueError(f"User with id {user_id} not found")
        
        category = await self.category_repo.get_by_id(category_id)
        if not category:
            raise ValueError(f"Category with id {category_id} not found")
        
        return await self.budget_repo.create(user_id, category_id, period, limit_amount)
    
    async def get_budget(self, budget_id: int) -> Optional[Budget]:
        """Get budget by ID"""
        return await self.budget_repo.get_by_id(budget_id)
    
    async def get_user_budgets(self, user_id: int, skip: int = 0, limit: int = 100) -> List[Budget]:
        """Get all budgets for a user"""
        return await self.budget_repo.get_by_user_id(user_id, skip, limit)
    
    async def get_category_budgets(self, category_id: int, skip: int = 0, limit: int = 100) -> List[Budget]:
        """Get all budgets for a category"""
        return await self.budget_repo.get_by_category_id(category_id, skip, limit)
    
    async def get_all_budgets(self, skip: int = 0, limit: int = 100) -> List[Budget]:
        """Get all budgets"""
        return await self.budget_repo.get_all(skip, limit)
    
    async def update_budget(self, budget_id: int, user_id: Optional[int] = None,
                            category_id: Optional[int] = None,
                            period: Optional[str] = None,
                            limit_amount: Optional[Decimal] = None) -> Optional[Budget]:
        """Update budget (user_id нельзя менять)"""
        # user_id не обновляется, бюджет привязан к пользователю
        
        if category_id is not None:
            category = await self.category_repo.get_by_id(category_id)
            if not category:
                raise ValueError(f"Category with id {category_id} not found")
        
        return await self.budget_repo.update(budget_id, user_id, category_id, period, limit_amount)
    
    async def delete_budget(self, budget_id: int) -> bool:
        """Delete budget"""
        return await self.budget_repo.delete(budget_id)

