from pydantic_settings import BaseSettings
from pathlib import Path
from typing import Optional
import os
from dotenv import load_dotenv

# Загружаем переменные из .env файла
load_dotenv(Path(__file__).parent.parent / ".env")


class Settings(BaseSettings):
    # Database settings (базовые настройки)
    db_host: str = os.getenv("DB_HOST", "localhost")
    db_port: int = int(os.getenv("DB_PORT", "5432"))
    db_name: str = os.getenv("DB_NAME", "finance")
    db_schema: str = os.getenv("DB_SCHEMA", "finance")
    
    # Пользователи БД для разных ролей
    db_user_admin: str = os.getenv("DB_USER_ADMIN", "finance_admin_user")
    db_password_admin: str = os.getenv("DB_PASSWORD_ADMIN", "admin_password_123")
    
    db_user_client: str = os.getenv("DB_USER_CLIENT", "finance_client_user")
    db_password_client: str = os.getenv("DB_PASSWORD_CLIENT", "client_password_123")
    
    db_user_operator: str = os.getenv("DB_USER_OPERATOR", "finance_operator_user")
    db_password_operator: str = os.getenv("DB_PASSWORD_OPERATOR", "operator_password_123")
    
    # Старые настройки для обратной совместимости
    db_user: str = os.getenv("DB_USER", "finance_app_user")
    db_password: str = os.getenv("DB_PASSWORD", "strong_password_here")
    
    def get_database_url(self, user: str = None, password: str = None) -> str:
        """Получить URL подключения к БД для конкретного пользователя"""
        if user and password:
            return f"postgresql+asyncpg://{user}:{password}@{self.db_host}:{self.db_port}/{self.db_name}"
        return f"postgresql+asyncpg://{self.db_user}:{self.db_password}@{self.db_host}:{self.db_port}/{self.db_name}"
    
    def get_asyncpg_url(self, user: str = None, password: str = None) -> str:
        """Получить asyncpg URL для конкретного пользователя"""
        if user and password:
            return f"postgresql://{user}:{password}@{self.db_host}:{self.db_port}/{self.db_name}"
        return f"postgresql://{self.db_user}:{self.db_password}@{self.db_host}:{self.db_port}/{self.db_name}"
    
    # Database URL for SQLAlchemy (по умолчанию)
    @property
    def database_url(self) -> str:
        return self.get_database_url()
    
    # Database URL for asyncpg (по умолчанию)
    @property
    def asyncpg_url(self) -> str:
        return self.get_asyncpg_url()
    
    # Application settings
    app_title: str = os.getenv("APP_TITLE", "Finance API")
    app_version: str = os.getenv("APP_VERSION", "1.0.0")
    debug: bool = os.getenv("DEBUG", "False").lower() == "true"
    
    # JWT settings
    jwt_secret_key: str = os.getenv("JWT_SECRET_KEY", "your-secret-key-change-in-production")
    jwt_algorithm: str = os.getenv("JWT_ALGORITHM", "HS256")
    jwt_access_token_expire_minutes: int = int(os.getenv("JWT_ACCESS_TOKEN_EXPIRE_MINUTES", "1440"))  # 24 hours
    
    class Config:
        # Ищем .env файл в корне проекта (на уровень выше src)
        env_file = str(Path(__file__).parent.parent / ".env")
        env_file_encoding = "utf-8"
        case_sensitive = False


settings = Settings()

