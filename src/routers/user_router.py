from fastapi import APIRouter, HTTPException, Query, Depends
from typing import List
from src.service.user_service import UserService
from src.schemas import (
    UserCreate, UserUpdate, UserResponse,
    UserInfoCreate, UserInfoUpdate, UserInfoResponse
)
from src.routers.auth_router import get_current_user_id

router = APIRouter(prefix="/users", tags=["users"])
user_service = UserService()


@router.get("/me", response_model=UserResponse)
async def get_my_user(user_id: int = Depends(get_current_user_id)):
    user = await user_service.get_user(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.put("/me", response_model=UserResponse)
async def update_my_user(user_update: UserUpdate, user_id: int = Depends(get_current_user_id)):
    try:
        user = await user_service.update_user(
            user_id,
            user_update.email,
            user_update.password,
            user_update.currency_preference
        )
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return user
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.delete("/me", status_code=204)
async def delete_my_user(user_id: int = Depends(get_current_user_id)):
    success = await user_service.delete_user(user_id)
    if not success:
        raise HTTPException(status_code=404, detail="User not found")


# UserInfo endpoints
@router.post("/me/info", response_model=UserInfoResponse, status_code=201)
async def create_my_user_info(user_info: UserInfoCreate, user_id: int = Depends(get_current_user_id)):
    try:
        return await user_service.create_user_info(
            user_id, user_info.fname, user_info.lname,
            user_info.patronymic, user_info.date_birth
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/me/info", response_model=UserInfoResponse)
async def get_my_user_info(user_id: int = Depends(get_current_user_id)):
    user_info = await user_service.get_user_info(user_id)
    if not user_info:
        raise HTTPException(status_code=404, detail="User info not found")
    return user_info


@router.put("/me/info", response_model=UserInfoResponse)
async def update_my_user_info(user_info_update: UserInfoUpdate, user_id: int = Depends(get_current_user_id)):
    user_info = await user_service.update_user_info(
        user_id,
        user_info_update.fname,
        user_info_update.lname,
        user_info_update.patronymic,
        user_info_update.date_birth
    )
    if not user_info:
        raise HTTPException(status_code=404, detail="User info not found")
    return user_info


@router.delete("/me/info", status_code=204)
async def delete_my_user_info(user_id: int = Depends(get_current_user_id)):
    success = await user_service.delete_user_info(user_id)
    if not success:
        raise HTTPException(status_code=404, detail="User info not found")

