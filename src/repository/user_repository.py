from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, delete, text
from sqlalchemy.orm import selectinload
from typing import Optional, List
from src.database.models import User, UserInfo
from src.database.connection import database
import logging

logger = logging.getLogger(__name__)


class UserRepository:
    @staticmethod
    async def create(email: str, password: str, currency_preference: str, role: str = 'user') -> User:
        async for session in database.get_session():
            try:
                logger.info(f"Creating user with email: {email}")
                user = User(
                    email=email,
                    password=password,
                    currency_preference=currency_preference,
                    role=role
                )
                session.add(user)
                await session.flush()
                await session.refresh(user)
                await session.commit()
                return user
            except Exception as e:
                logger.error(f"Error creating user: {e}", exc_info=True)
                error_str = str(e).lower()
                if "unique" in error_str or "duplicate" in error_str or "already exists" in error_str:
                    raise ValueError(f"User with email {email} already exists") from e
                raise
        return None

    @staticmethod
    async def get_by_id(user_id: int) -> Optional[User]:
        async for session in database.get_session():
            result = await session.execute(
                select(User)
                .options(selectinload(User.user_info), selectinload(User.accounts))
                .where(User.user_id == user_id)
            )
            return result.scalar_one_or_none()
    
    @staticmethod
    async def get_by_email(email: str) -> Optional[User]:
        async for session in database.get_session():
            result = await session.execute(
                text("SELECT user_id, email, password, currency_preference, role FROM finance.users WHERE email = :email LIMIT 1"),
                {"email": email}
            )
            row = result.first()
            if not row:
                return None
            
            user = User(
                user_id=row.user_id,
                email=row.email,
                password=row.password,
                currency_preference=row.currency_preference,
                role=row.role if hasattr(row, 'role') else 'user'
            )
            return user
    
    @staticmethod
    async def get_all(skip: int = 0, limit: int = 100) -> List[User]:
        async for session in database.get_session():
            result = await session.execute(
                select(User).offset(skip).limit(limit)
            )
            return list(result.scalars().all())
    
    @staticmethod
    async def update(user_id: int, email: Optional[str] = None, 
                     password: Optional[str] = None, 
                     currency_preference: Optional[str] = None) -> Optional[User]:
        async for session in database.get_session():
            update_data = {}
            if email is not None:
                update_data["email"] = email
            if password is not None:
                update_data["password"] = password
            if currency_preference is not None:
                update_data["currency_preference"] = currency_preference
            
            await session.execute(
                update(User).where(User.user_id == user_id).values(**update_data)
            )
            await session.commit()
        return await UserRepository.get_by_id(user_id)
    
    @staticmethod
    async def delete(user_id: int) -> bool:
        async for session in database.get_session():
            await session.execute(
                delete(User).where(User.user_id == user_id)
            )
            await session.commit()
        return True


class UserInfoRepository:
    @staticmethod
    async def create(user_id: int, fname: str, lname: str, 
                     patronymic: Optional[str] = None, 
                     date_birth: Optional[str] = None) -> UserInfo:
        async for session in database.get_session():
            user_info = UserInfo(
                user_id=user_id,
                fname=fname,
                lname=lname,
                patronymic=patronymic,
                date_birth=date_birth
            )
            session.add(user_info)
            await session.flush()
            await session.refresh(user_info)
            await session.commit()
            return user_info
    
    @staticmethod
    async def get_by_user_id(user_id: int) -> Optional[UserInfo]:
        async for session in database.get_session():
            result = await session.execute(
                select(UserInfo).where(UserInfo.user_id == user_id)
            )
            return result.scalar_one_or_none()
    
    @staticmethod
    async def update(user_id: int, fname: Optional[str] = None,
                     lname: Optional[str] = None,
                     patronymic: Optional[str] = None,
                     date_birth: Optional[str] = None) -> Optional[UserInfo]:
        async for session in database.get_session():
            update_data = {}
            if fname is not None:
                update_data["fname"] = fname
            if lname is not None:
                update_data["lname"] = lname
            if patronymic is not None:
                update_data["patronymic"] = patronymic
            if date_birth is not None:
                update_data["date_birth"] = date_birth
            
            await session.execute(
                update(UserInfo).where(UserInfo.user_id == user_id).values(**update_data)
            )
            await session.commit()
        return await UserInfoRepository.get_by_user_id(user_id)
    
    @staticmethod
    async def delete(user_id: int) -> bool:
        async for session in database.get_session():
            await session.execute(
                delete(UserInfo).where(UserInfo.user_id == user_id)
            )
            await session.commit()
        return True

