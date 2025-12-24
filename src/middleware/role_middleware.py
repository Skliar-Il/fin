from fastapi import Request, HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import List, Optional, Tuple
from src.auth.jwt_service import JWTService

security = HTTPBearer()


def get_user_data_from_request(credentials: HTTPAuthorizationCredentials = Depends(security)) -> dict:
    """Dependency для получения данных пользователя из токена"""
    token = credentials.credentials
    user_data = JWTService.get_user_data_from_token(token)
    
    if not user_data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    return user_data


def require_admin(user_data: dict = Depends(get_user_data_from_request)) -> Tuple[int, str]:
    """Dependency для проверки роли admin"""
    user_role = user_data.get("role", "user")
    
    if user_role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. Required role: admin"
        )
    
    return user_data.get("user_id"), user_role


def require_user_or_admin(user_data: dict = Depends(get_user_data_from_request)) -> Tuple[int, str]:
    """Dependency для проверки роли user или admin"""
    user_role = user_data.get("role", "user")
    
    if user_role not in ["user", "admin"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. Required roles: user, admin"
        )
    
    return user_data.get("user_id"), user_role


def get_current_user_role(request: Request) -> Optional[str]:
    """Получить роль текущего пользователя"""
    authorization = request.headers.get("Authorization")
    if not authorization or not authorization.startswith("Bearer "):
        return None
    
    token = authorization.split(" ")[1]
    user_data = JWTService.get_user_data_from_token(token)
    if user_data:
        return user_data.get("role")
    return None

