from fastapi import Request
from typing import Optional
from starlette.middleware.base import BaseHTTPMiddleware
from src.database.connection import current_user_id, current_user_role
from src.auth.jwt_service import JWTService


class AuthMiddleware(BaseHTTPMiddleware):
    """Middleware для установки user_id в контексте для RLS из JWT токена"""
    
    async def dispatch(self, request: Request, call_next):
        # Получаем токен из заголовка Authorization
        authorization = request.headers.get("Authorization")
        user_id = None
        user_role = None
        
        if authorization and authorization.startswith("Bearer "):
            token = authorization.split(" ")[1]
            user_data = JWTService.get_user_data_from_token(token)
            if user_data:
                user_id = user_data.get("user_id")
                user_role = user_data.get("role", "user")
        
        # Устанавливаем user_id и role в контексте для использования в connection
        if user_id:
            current_user_id.set(user_id)
            request.state.user_id = user_id
        else:
            current_user_id.set(None)
            request.state.user_id = None
        
        if user_role:
            current_user_role.set(user_role)
            request.state.user_role = user_role
        else:
            current_user_role.set(None)
            request.state.user_role = None
        
        try:
            response = await call_next(request)
        finally:
            # Очищаем контекст после запроса
            current_user_id.set(None)
            current_user_role.set(None)
        
        return response


def get_current_user_id(request: Request) -> Optional[int]:
    """Получить текущий user_id из request state"""
    return getattr(request.state, 'user_id', None)

