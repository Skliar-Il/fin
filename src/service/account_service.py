from typing import Optional, List
from src.repository.account_repository import AccountRepository
from src.repository.user_repository import UserRepository
from src.database.models import Account


class AccountService:
    def __init__(self):
        self.account_repo = AccountRepository()
        self.user_repo = UserRepository()
    
    async def create_account(self, user_id: int, name: str, type: str,
                             balance: float, currency: str) -> Account:
        user = await self.user_repo.get_by_id(user_id)
        if not user:
            raise ValueError(f"User with id {user_id} not found")
        
        return await self.account_repo.create(user_id, name, type, balance, currency)
    
    async def get_account(self, account_id: int) -> Optional[Account]:
        """Get account by ID"""
        return await self.account_repo.get_by_id(account_id)
    
    async def get_user_accounts(self, user_id: int) -> List[Account]:
        """Get all accounts for a user"""
        return await self.account_repo.get_by_user_id(user_id)
    
    async def get_all_accounts(self, skip: int = 0, limit: int = 100) -> List[Account]:
        """Get all accounts"""
        return await self.account_repo.get_all(skip, limit)
    
    async def update_account(self, account_id: int, name: Optional[str] = None,
                             type: Optional[str] = None,
                             balance: Optional[float] = None,
                             currency: Optional[str] = None) -> Optional[Account]:
        """Update account"""
        return await self.account_repo.update(account_id, name, type, balance, currency)
    
    async def delete_account(self, account_id: int) -> bool:
        """Delete account"""
        return await self.account_repo.delete(account_id)

