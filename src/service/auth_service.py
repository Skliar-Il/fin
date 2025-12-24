from typing import Optional
from fastapi import HTTPException, status
from src.service.user_service import UserService
from src.auth.jwt_service import JWTService
from src.schemas import Token


class AuthService:
    def __init__(self):
        self.user_service = UserService()
        self.jwt_service = JWTService()
    
    async def authenticate_user(self, email: str, password: str) -> Optional[Token]:
        user = await self.user_service.get_user_by_email(email)
        if not user:
            return None
        
        verify_result = self.jwt_service.verify_password(password, user.password)
        if not verify_result:
            return None
        
        access_token = self.jwt_service.create_access_token(data={
            "sub": str(user.user_id),
            "role": user.role if hasattr(user, 'role') else 'user'
        })
        return Token(access_token=access_token, token_type="bearer")
    
    async def register_user(self, email: str, password: str, currency_preference: str) -> Token:
        try:
            user = await self.user_service.create_user(email, password, currency_preference)
            access_token = self.jwt_service.create_access_token(data={
                "sub": str(user.user_id),
                "role": user.role if hasattr(user, 'role') else 'user'
            })
            return Token(access_token=access_token, token_type="bearer")
        except ValueError as e:
            error_message = str(e)
            if "already exists" in error_message.lower():
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"User with email {email} already exists"
                )
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=error_message
            )
        except Exception as e:
            error_str = str(e).lower()
            if "unique" in error_str or "duplicate" in error_str or "already exists" in error_str:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"User with email {email} already exists"
                )
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to create user"
            )

