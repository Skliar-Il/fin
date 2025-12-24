from pydantic import BaseModel, EmailStr
from typing import Optional
from decimal import Decimal
from datetime import datetime, date


# Auth Schemas
class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    user_id: Optional[int] = None


class UserLogin(BaseModel):
    email: EmailStr
    password: str


# User Schemas
class UserCreate(BaseModel):
    email: EmailStr
    password: str
    currency_preference: str


class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    password: Optional[str] = None
    currency_preference: Optional[str] = None


class UserResponse(BaseModel):
    user_id: int
    email: str
    currency_preference: str
    role: str
    
    class Config:
        from_attributes = True


# UserInfo Schemas
class UserInfoCreate(BaseModel):
    fname: str
    lname: str
    patronymic: Optional[str] = None
    date_birth: Optional[date] = None


class UserInfoUpdate(BaseModel):
    fname: Optional[str] = None
    lname: Optional[str] = None
    patronymic: Optional[str] = None
    date_birth: Optional[date] = None


class UserInfoResponse(BaseModel):
    user_id: int
    fname: str
    lname: str
    patronymic: Optional[str]
    date_birth: Optional[date]
    
    class Config:
        from_attributes = True


# Account Schemas
class AccountCreate(BaseModel):
    name: str
    type: str
    balance: float
    currency: str


class AccountUpdate(BaseModel):
    name: Optional[str] = None
    type: Optional[str] = None
    balance: Optional[float] = None
    currency: Optional[str] = None


class AccountResponse(BaseModel):
    account_id: int
    user_id: int
    name: str
    type: str
    balance: float
    currency: str
    
    class Config:
        from_attributes = True


# Category Schemas
class CategoryCreate(BaseModel):
    name: str
    parent_id: Optional[int] = None


class CategoryUpdate(BaseModel):
    name: Optional[str] = None
    parent_id: Optional[int] = None


class CategoryResponse(BaseModel):
    category_id: int
    name: str
    parent_id: Optional[int]
    
    class Config:
        from_attributes = True


# Transaction Schemas
class TransactionCreate(BaseModel):
    account_id: int
    category_id: int
    amount: Decimal
    type: str
    date: datetime
    description: Optional[str] = None
    merchant: Optional[str] = None


class TransactionUpdate(BaseModel):
    account_id: Optional[int] = None
    category_id: Optional[int] = None
    amount: Optional[Decimal] = None
    type: Optional[str] = None
    date: Optional[datetime] = None
    description: Optional[str] = None
    merchant: Optional[str] = None


class TransactionResponse(BaseModel):
    transaction_id: int
    account_id: int
    category_id: int
    amount: Decimal
    type: str
    date: datetime
    description: Optional[str]
    merchant: Optional[str]
    
    class Config:
        from_attributes = True


# Budget Schemas
class BudgetCreate(BaseModel):
    category_id: int
    period: str
    limit_amount: Decimal


class BudgetUpdate(BaseModel):
    category_id: Optional[int] = None
    period: Optional[str] = None
    limit_amount: Optional[Decimal] = None


class BudgetResponse(BaseModel):
    budget_id: int
    user_id: int
    category_id: int
    period: str
    limit_amount: Decimal
    
    class Config:
        from_attributes = True

