from fastapi import APIRouter, Depends, HTTPException, status, Request, Query
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import List, Optional, Tuple
from datetime import datetime
from decimal import Decimal
from src.auth.jwt_service import JWTService
from src.middleware.role_middleware import require_admin
from src.database.connection import database, get_engine_for_role
from src.config import settings
import asyncpg
from sqlalchemy import text

router = APIRouter(prefix="/admin", tags=["admin"])
security = HTTPBearer()


@router.get("/statistics/users")
async def get_users_statistics(user_data: Tuple[int, str] = Depends(require_admin)):
    """Получить статистику по всем пользователям (только для admin)"""
    user_id, role = user_data
    async for session in database.get_session(user_id, role):
        result = await session.execute(
            text("SELECT * FROM finance.admin_users_statistics ORDER BY user_id")
        )
        rows = result.fetchall()
        return [
            {
                "user_id": row.user_id,
                "email": row.email,
                "currency_preference": row.currency_preference,
                "role": row.role,
                "accounts_count": row.accounts_count,
                "total_balance": float(row.total_balance),
                "transactions_count": row.transactions_count,
                "total_income": float(row.total_income),
                "total_expense": float(row.total_expense),
                "budgets_count": row.budgets_count
            }
            for row in rows
        ]


@router.get("/statistics/categories")
async def get_categories_statistics(user_data: Tuple[int, str] = Depends(require_admin)):
    """Получить статистику по категориям (только для admin)"""
    user_id, role = user_data
    async for session in database.get_session(user_id, role):
        result = await session.execute(
            text("SELECT * FROM finance.admin_categories_statistics")
        )
        rows = result.fetchall()
        return [
            {
                "category_id": row.category_id,
                "category_name": row.category_name,
                "parent_id": row.parent_id,
                "transactions_count": row.transactions_count,
                "accounts_count": row.accounts_count,
                "users_count": row.users_count,
                "total_income": float(row.total_income),
                "total_expense": float(row.total_expense),
                "avg_expense": float(row.avg_expense)
            }
            for row in rows
        ]


@router.post("/recalculate-all-balances")
async def recalculate_all_balances(user_data: Tuple[int, str] = Depends(require_admin)):
    """Пересчитать балансы всех аккаунтов (только для admin)"""
    user_id, role = user_data
    
    if role == 'admin':
        db_user = settings.db_user_admin
        db_password = settings.db_password_admin
    elif role == 'operator':
        db_user = settings.db_user_operator
        db_password = settings.db_password_operator
    else:
        db_user = settings.db_user
        db_password = settings.db_password
    
    conn = await asyncpg.connect(
        host=settings.db_host,
        port=settings.db_port,
        user=db_user,
        password=db_password,
        database=settings.db_name
    )
    
    try:
        tr = conn.transaction()
        await tr.start()
        try:
            await conn.execute(f"SET LOCAL app.current_user_id = {user_id}")
            await conn.execute("CALL finance.admin_recalculate_all_balances()")
            await tr.commit()
        except Exception:
            await tr.rollback()
            raise
    finally:
        await conn.close()
    
    return {"message": "All balances recalculated successfully"}


@router.post("/bulk-update-transactions")
async def bulk_update_transactions(
    user_data: Tuple[int, str] = Depends(require_admin),
    category_id: Optional[int] = Query(None),
    transaction_type: Optional[str] = Query(None),
    start_date: Optional[str] = Query(None),
    end_date: Optional[str] = Query(None),
    update_amount: Optional[Decimal] = Query(None),
    update_description: Optional[str] = Query(None)
):
    """Глобальное обновление транзакций по параметрам (только для admin)"""
    user_id, role = user_data
    
    if role == 'admin':
        db_user = settings.db_user_admin
        db_password = settings.db_password_admin
    elif role == 'operator':
        db_user = settings.db_user_operator
        db_password = settings.db_password_operator
    else:
        db_user = settings.db_user
        db_password = settings.db_password
    
    conn = await asyncpg.connect(
        host=settings.db_host,
        port=settings.db_port,
        user=db_user,
        password=db_password,
        database=settings.db_name
    )
    
    try:
        tr = conn.transaction()
        await tr.start()
        try:
            await conn.execute(f"SET LOCAL app.current_user_id = {user_id}")
            
            sql_parts = []
            
            if category_id is not None:
                sql_parts.append(f"p_category_id => {category_id}")
            else:
                sql_parts.append("p_category_id => NULL")
            
            if transaction_type:
                escaped_type = transaction_type.replace("'", "''")
                sql_parts.append(f"p_transaction_type => '{escaped_type}'")
            else:
                sql_parts.append("p_transaction_type => NULL")
            
            if start_date:
                sql_parts.append(f"p_start_date => '{start_date}'::timestamp")
            else:
                sql_parts.append("p_start_date => NULL")
            
            if end_date:
                sql_parts.append(f"p_end_date => '{end_date}'::timestamp")
            else:
                sql_parts.append("p_end_date => NULL")
            
            if update_amount is not None:
                sql_parts.append(f"p_update_amount => {update_amount}")
            else:
                sql_parts.append("p_update_amount => NULL")
            
            if update_description:
                escaped_desc = update_description.replace("'", "''")
                sql_parts.append(f"p_update_description => '{escaped_desc}'")
            else:
                sql_parts.append("p_update_description => NULL")
            
            sql = f"CALL finance.admin_bulk_update_transactions({', '.join(sql_parts)})"
            
            await conn.execute(sql)
            await tr.commit()
        except Exception:
            await tr.rollback()
            raise
    finally:
        await conn.close()
    
    return {"message": "Transactions updated successfully"}

