from typing import Optional, List
from src.repository.transaction_repository import TransactionRepository
from src.repository.account_repository import AccountRepository
from src.repository.category_repository import CategoryRepository
from src.database.models import Transaction
from decimal import Decimal
from datetime import datetime


class TransactionService:
    def __init__(self):
        self.transaction_repo = TransactionRepository()
        self.account_repo = AccountRepository()
        self.category_repo = CategoryRepository()
    
    async def create_transaction(self, account_id: int, category_id: int, amount: Decimal,
                                 type: str, date: datetime, description: Optional[str] = None,
                                 merchant: Optional[str] = None) -> Transaction:
        """Create a new transaction"""
        account = await self.account_repo.get_by_id(account_id)
        if not account:
            raise ValueError(f"Account with id {account_id} not found")
        
        category = await self.category_repo.get_by_id(category_id)
        if not category:
            raise ValueError(f"Category with id {category_id} not found")
        
        return await self.transaction_repo.create(
            account_id, category_id, amount, type, date, description, merchant
        )
    
    async def get_transaction(self, transaction_id: int) -> Optional[Transaction]:
        """Get transaction by ID"""
        return await self.transaction_repo.get_by_id(transaction_id)
    
    async def get_account_transactions(self, account_id: int, skip: int = 0, limit: int = 100) -> List[Transaction]:
        """Get all transactions for an account"""
        return await self.transaction_repo.get_by_account_id(account_id, skip, limit)
    
    async def get_category_transactions(self, category_id: int, skip: int = 0, limit: int = 100) -> List[Transaction]:
        """Get all transactions for a category"""
        return await self.transaction_repo.get_by_category_id(category_id, skip, limit)
    
    async def get_all_transactions(self, skip: int = 0, limit: int = 100) -> List[Transaction]:
        """Get all transactions"""
        return await self.transaction_repo.get_all(skip, limit)
    
    async def update_transaction(self, transaction_id: int, account_id: Optional[int] = None,
                                 category_id: Optional[int] = None,
                                 amount: Optional[Decimal] = None,
                                 type: Optional[str] = None,
                                 date: Optional[datetime] = None,
                                 description: Optional[str] = None,
                                 merchant: Optional[str] = None) -> Optional[Transaction]:
        """Update transaction (account_id нельзя менять)"""
        # account_id не обновляется, транзакция привязана к аккаунту
        
        if category_id is not None:
            category = await self.category_repo.get_by_id(category_id)
            if not category:
                raise ValueError(f"Category with id {category_id} not found")
        
        return await self.transaction_repo.update(
            transaction_id, account_id, category_id, amount, type, date, description, merchant
        )
    
    async def delete_transaction(self, transaction_id: int) -> bool:
        """Delete transaction"""
        return await self.transaction_repo.delete(transaction_id)

