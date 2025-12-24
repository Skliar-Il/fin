from fastapi import APIRouter, HTTPException, Query, Depends
from typing import List
from src.service.transaction_service import TransactionService
from src.schemas import TransactionCreate, TransactionUpdate, TransactionResponse
from src.routers.auth_router import get_current_user_id
from src.service.account_service import AccountService

router = APIRouter(prefix="/transactions", tags=["transactions"])
transaction_service = TransactionService()
account_service = AccountService()


@router.post("/", response_model=TransactionResponse, status_code=201)
async def create_transaction(transaction: TransactionCreate, user_id: int = Depends(get_current_user_id)):
    """Create a new transaction"""
    account = await account_service.get_account(transaction.account_id)
    if not account:
        raise HTTPException(status_code=404, detail="Account not found")
    if account.user_id != user_id:
        raise HTTPException(status_code=403, detail="Access denied")
    
    try:
        return await transaction_service.create_transaction(
            transaction.account_id,
            transaction.category_id,
            transaction.amount,
            transaction.type,
            transaction.date,
            transaction.description,
            transaction.merchant
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/", response_model=List[TransactionResponse])
async def get_my_transactions(skip: int = Query(0, ge=0), limit: int = Query(100, ge=1, le=100), user_id: int = Depends(get_current_user_id)):
    """Get all transactions for current user"""
    accounts = await account_service.get_user_accounts(user_id)
    if not accounts:
        return []
    
    all_transactions = []
    for account in accounts:
        transactions = await transaction_service.get_account_transactions(account.account_id, skip, limit)
        all_transactions.extend(transactions)
    
    return sorted(all_transactions, key=lambda x: x.date, reverse=True)[skip:skip+limit]


@router.get("/{transaction_id}", response_model=TransactionResponse)
async def get_transaction(transaction_id: int, user_id: int = Depends(get_current_user_id)):
    """Get transaction by ID"""
    transaction = await transaction_service.get_transaction(transaction_id)
    if not transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")
    
    account = await account_service.get_account(transaction.account_id)
    if not account or account.user_id != user_id:
        raise HTTPException(status_code=403, detail="Access denied")
    
    return transaction




@router.get("/category/{category_id}", response_model=List[TransactionResponse])
async def get_my_category_transactions(category_id: int, skip: int = Query(0, ge=0), limit: int = Query(100, ge=1, le=100), user_id: int = Depends(get_current_user_id)):
    """Get all transactions for a category (только свои транзакции)"""
    # RLS автоматически отфильтрует только транзакции текущего пользователя
    return await transaction_service.get_category_transactions(category_id, skip, limit)


@router.put("/{transaction_id}", response_model=TransactionResponse)
async def update_transaction(transaction_id: int, transaction_update: TransactionUpdate, user_id: int = Depends(get_current_user_id)):
    """Update transaction"""
    transaction = await transaction_service.get_transaction(transaction_id)
    if not transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")
    
    account = await account_service.get_account(transaction.account_id)
    if not account or account.user_id != user_id:
        raise HTTPException(status_code=403, detail="Access denied")
    
    try:
        transaction = await transaction_service.update_transaction(
            transaction_id,
            transaction_update.account_id,
            transaction_update.category_id,
            transaction_update.amount,
            transaction_update.type,
            transaction_update.date,
            transaction_update.description,
            transaction_update.merchant
        )
        if not transaction:
            raise HTTPException(status_code=404, detail="Transaction not found")
        
        if transaction_update.account_id:
            new_account = await account_service.get_account(transaction_update.account_id)
            if not new_account or new_account.user_id != user_id:
                raise HTTPException(status_code=403, detail="Access denied to target account")
        
        return transaction
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.delete("/{transaction_id}", status_code=204)
async def delete_transaction(transaction_id: int, user_id: int = Depends(get_current_user_id)):
    """Delete transaction"""
    transaction = await transaction_service.get_transaction(transaction_id)
    if not transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")
    
    account = await account_service.get_account(transaction.account_id)
    if not account or account.user_id != user_id:
        raise HTTPException(status_code=403, detail="Access denied")
    
    success = await transaction_service.delete_transaction(transaction_id)
    if not success:
        raise HTTPException(status_code=404, detail="Transaction not found")

