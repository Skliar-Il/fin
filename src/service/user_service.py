from typing import Optional, List
from src.repository.user_repository import UserRepository, UserInfoRepository
from src.database.models import User, UserInfo
from src.auth.jwt_service import JWTService


class UserService:
    def __init__(self):
        self.user_repo = UserRepository()
        self.user_info_repo = UserInfoRepository()
    
    async def create_user(self, email: str, password: str, currency_preference: str, role: str = 'user') -> User:
        existing_user = await self.user_repo.get_by_email(email)
        if existing_user:
            raise ValueError(f"User with email {email} already exists")
        hashed_password = JWTService.get_password_hash(password)
        try:
            user = await self.user_repo.create(email, hashed_password, currency_preference, role)
            return user
        except ValueError as e:
            raise
        except Exception as e:
            error_str = str(e).lower()
            if "unique" in error_str or "duplicate" in error_str or "already exists" in error_str:
                raise ValueError(f"User with email {email} already exists") from e
            raise
    
    async def get_user(self, user_id: int) -> Optional[User]:
        """Get user by ID"""
        return await self.user_repo.get_by_id(user_id)
    
    async def get_user_by_email(self, email: str) -> Optional[User]:
        """Get user by email"""
        return await self.user_repo.get_by_email(email)
    
    async def get_all_users(self, skip: int = 0, limit: int = 100) -> List[User]:
        """Get all users"""
        return await self.user_repo.get_all(skip, limit)
    
    async def update_user(self, user_id: int, email: Optional[str] = None,
                          password: Optional[str] = None,
                          currency_preference: Optional[str] = None) -> Optional[User]:
        """Update user"""
        if email:
            existing_user = await self.user_repo.get_by_email(email)
            if existing_user and existing_user.user_id != user_id:
                raise ValueError(f"User with email {email} already exists")
        # Хешируем пароль, если он передан
        hashed_password = None
        if password:
            hashed_password = JWTService.get_password_hash(password)
        return await self.user_repo.update(user_id, email, hashed_password, currency_preference)
    
    async def delete_user(self, user_id: int) -> bool:
        """Delete user"""
        return await self.user_repo.delete(user_id)
    
    async def create_user_info(self, user_id: int, fname: str, lname: str,
                               patronymic: Optional[str] = None,
                               date_birth: Optional[str] = None) -> UserInfo:
        """Create user info"""
        existing_info = await self.user_info_repo.get_by_user_id(user_id)
        if existing_info:
            raise ValueError(f"User info for user_id {user_id} already exists")
        return await self.user_info_repo.create(user_id, fname, lname, patronymic, date_birth)
    
    async def get_user_info(self, user_id: int) -> Optional[UserInfo]:
        """Get user info"""
        return await self.user_info_repo.get_by_user_id(user_id)
    
    async def update_user_info(self, user_id: int, fname: Optional[str] = None,
                                lname: Optional[str] = None,
                                patronymic: Optional[str] = None,
                                date_birth: Optional[str] = None) -> Optional[UserInfo]:
        """Update user info"""
        return await self.user_info_repo.update(user_id, fname, lname, patronymic, date_birth)
    
    async def delete_user_info(self, user_id: int) -> bool:
        """Delete user info"""
        return await self.user_info_repo.delete(user_id)

