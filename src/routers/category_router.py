from fastapi import APIRouter, HTTPException, Query
from typing import List, Optional
from src.service.category_service import CategoryService
from src.schemas import CategoryCreate, CategoryUpdate, CategoryResponse

router = APIRouter(prefix="/categories", tags=["categories"])
category_service = CategoryService()


@router.post("/", response_model=CategoryResponse, status_code=201)
async def create_category(category: CategoryCreate):
    """Create a new category"""
    try:
        return await category_service.create_category(category.name, category.parent_id)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/", response_model=List[CategoryResponse])
async def get_categories(skip: int = Query(0, ge=0), limit: int = Query(100, ge=1, le=100)):
    """Get all categories"""
    return await category_service.get_all_categories(skip, limit)


@router.get("/{category_id}", response_model=CategoryResponse)
async def get_category(category_id: int):
    """Get category by ID"""
    category = await category_service.get_category(category_id)
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    return category


@router.get("/parent/{parent_id}", response_model=List[CategoryResponse])
async def get_child_categories(parent_id: Optional[int], skip: int = Query(0, ge=0), limit: int = Query(100, ge=1, le=100)):
    """Get categories by parent_id"""
    return await category_service.get_child_categories(parent_id, skip, limit)


@router.put("/{category_id}", response_model=CategoryResponse)
async def update_category(category_id: int, category_update: CategoryUpdate):
    """Update category"""
    try:
        category = await category_service.update_category(
            category_id,
            category_update.name,
            category_update.parent_id
        )
        if not category:
            raise HTTPException(status_code=404, detail="Category not found")
        return category
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.delete("/{category_id}", status_code=204)
async def delete_category(category_id: int):
    """Delete category"""
    success = await category_service.delete_category(category_id)
    if not success:
        raise HTTPException(status_code=404, detail="Category not found")

