from fastapi import APIRouter, HTTPException, Query, Depends
from typing import List
from src.service.account_service import AccountService
from src.schemas import AccountCreate, AccountUpdate, AccountResponse
from src.routers.auth_router import get_current_user_id

router = APIRouter(prefix="/accounts", tags=["accounts"])
account_service = AccountService()


@router.post("/", response_model=AccountResponse, status_code=201)
async def create_account(account: AccountCreate, user_id: int = Depends(get_current_user_id)):
    """Create a new account (user_id берется из JWT токена)"""
    try:
        return await account_service.create_account(
            user_id, account.name, account.type,
            account.balance, account.currency
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/", response_model=List[AccountResponse])
async def get_my_accounts(user_id: int = Depends(get_current_user_id)):
    """Get all accounts for current user"""
    accounts = await account_service.get_user_accounts(user_id)
    return accounts


@router.get("/{account_id}", response_model=AccountResponse)
async def get_account(account_id: int, user_id: int = Depends(get_current_user_id)):
    """Get account by ID"""
    account = await account_service.get_account(account_id)
    if not account:
        raise HTTPException(status_code=404, detail="Account not found")
    if account.user_id != user_id:
        raise HTTPException(status_code=403, detail="Access denied")
    return account


@router.put("/{account_id}", response_model=AccountResponse)
async def update_account(account_id: int, account_update: AccountUpdate, user_id: int = Depends(get_current_user_id)):
    """Update account"""
    account = await account_service.get_account(account_id)
    if not account:
        raise HTTPException(status_code=404, detail="Account not found")
    if account.user_id != user_id:
        raise HTTPException(status_code=403, detail="Access denied")
    
    updated_account = await account_service.update_account(
        account_id,
        account_update.name,
        account_update.type,
        account_update.balance,
        account_update.currency
    )
    if not updated_account:
        raise HTTPException(status_code=404, detail="Account not found")
    return updated_account


@router.delete("/{account_id}", status_code=204)
async def delete_account(account_id: int, user_id: int = Depends(get_current_user_id)):
    """Delete account"""
    account = await account_service.get_account(account_id)
    if not account:
        raise HTTPException(status_code=404, detail="Account not found")
    if account.user_id != user_id:
        raise HTTPException(status_code=403, detail="Access denied")
    
    success = await account_service.delete_account(account_id)
    if not success:
        raise HTTPException(status_code=404, detail="Account not found")

