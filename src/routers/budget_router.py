from fastapi import APIRouter, HTTPException, Query, Depends
from typing import List
from src.service.budget_service import BudgetService
from src.schemas import BudgetCreate, BudgetUpdate, BudgetResponse
from src.routers.auth_router import get_current_user_id

router = APIRouter(prefix="/budgets", tags=["budgets"])
budget_service = BudgetService()


@router.post("/", response_model=BudgetResponse, status_code=201)
async def create_budget(budget: BudgetCreate, user_id: int = Depends(get_current_user_id)):
    """Create a new budget (user_id берется из JWT токена)"""
    try:
        return await budget_service.create_budget(
            user_id,
            budget.category_id,
            budget.period,
            budget.limit_amount
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/", response_model=List[BudgetResponse])
async def get_my_budgets_from_list(skip: int = Query(0, ge=0), limit: int = Query(100, ge=1, le=100), user_id: int = Depends(get_current_user_id)):
    """Get all budgets for current user (alias for /me)"""
    return await budget_service.get_user_budgets(user_id, skip, limit)




@router.get("/{budget_id}", response_model=BudgetResponse)
async def get_budget(budget_id: int, user_id: int = Depends(get_current_user_id)):
    """Get budget by ID"""
    budget = await budget_service.get_budget(budget_id)
    if not budget:
        raise HTTPException(status_code=404, detail="Budget not found")
    if budget.user_id != user_id:
        raise HTTPException(status_code=403, detail="Access denied")
    return budget


@router.get("/category/{category_id}", response_model=List[BudgetResponse])
async def get_my_category_budgets(category_id: int, skip: int = Query(0, ge=0), limit: int = Query(100, ge=1, le=100), user_id: int = Depends(get_current_user_id)):
    """Get all budgets for a category (только свои бюджеты)"""
    # RLS автоматически отфильтрует только бюджеты текущего пользователя
    return await budget_service.get_category_budgets(category_id, skip, limit)


@router.put("/{budget_id}", response_model=BudgetResponse)
async def update_budget(budget_id: int, budget_update: BudgetUpdate, user_id: int = Depends(get_current_user_id)):
    """Update budget"""
    budget = await budget_service.get_budget(budget_id)
    if not budget:
        raise HTTPException(status_code=404, detail="Budget not found")
    if budget.user_id != user_id:
        raise HTTPException(status_code=403, detail="Access denied")
    
    try:
        budget = await budget_service.update_budget(
            budget_id,
            None,
            budget_update.category_id,
            budget_update.period,
            budget_update.limit_amount
        )
        if not budget:
            raise HTTPException(status_code=404, detail="Budget not found")
        return budget
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.delete("/{budget_id}", status_code=204)
async def delete_budget(budget_id: int, user_id: int = Depends(get_current_user_id)):
    """Delete budget"""
    budget = await budget_service.get_budget(budget_id)
    if not budget:
        raise HTTPException(status_code=404, detail="Budget not found")
    if budget.user_id != user_id:
        raise HTTPException(status_code=403, detail="Access denied")
    
    success = await budget_service.delete_budget(budget_id)
    if not success:
        raise HTTPException(status_code=404, detail="Budget not found")

