from sqlalchemy import Column, Integer, String, Numeric, Float, Date, DateTime, ForeignKey, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime

Base = declarative_base()


class User(Base):
    __tablename__ = "users"
    __table_args__ = {"schema": "finance"}
    
    user_id = Column(Integer, primary_key=True, index=True)
    email = Column(Text, unique=True, nullable=False, index=True)
    password = Column(Text, nullable=False)
    currency_preference = Column(Text, nullable=False)
    role = Column(Text, nullable=False, default='user')
    
    # Relationships
    user_info = relationship("UserInfo", back_populates="user", uselist=False, cascade="all, delete-orphan")
    accounts = relationship("Account", back_populates="user", cascade="all, delete-orphan")
    budgets = relationship("Budget", back_populates="user", cascade="all, delete-orphan")


class UserInfo(Base):
    __tablename__ = "users_info"
    __table_args__ = {"schema": "finance"}
    
    user_id = Column(Integer, ForeignKey("finance.users.user_id", ondelete="CASCADE"), primary_key=True)
    fname = Column(Text, nullable=False)
    lname = Column(Text, nullable=False)
    patronymic = Column(Text, nullable=True)
    date_birth = Column(Date, nullable=True)
    
    # Relationships
    user = relationship("User", back_populates="user_info")


class Account(Base):
    __tablename__ = "accounts"
    __table_args__ = {"schema": "finance"}
    
    account_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("finance.users.user_id", ondelete="CASCADE"), nullable=False)
    name = Column(Text, nullable=False)
    type = Column(Text, nullable=False)
    balance = Column(Float, nullable=False)
    currency = Column(Text, nullable=False)
    
    # Relationships
    user = relationship("User", back_populates="accounts")
    transactions = relationship("Transaction", back_populates="account", cascade="all, delete-orphan")


class Category(Base):
    __tablename__ = "categories"
    __table_args__ = {"schema": "finance"}
    
    category_id = Column(Integer, primary_key=True, index=True)
    name = Column(Text, nullable=False)
    parent_id = Column(Integer, ForeignKey("finance.categories.category_id", ondelete="SET NULL"), nullable=True)
    
    # Relationships
    parent = relationship("Category", remote_side=[category_id], backref="children")
    transactions = relationship("Transaction", back_populates="category")
    budgets = relationship("Budget", back_populates="category", cascade="all, delete-orphan")


class Transaction(Base):
    __tablename__ = "transactions"
    __table_args__ = {"schema": "finance"}
    
    transaction_id = Column(Integer, primary_key=True, index=True)
    account_id = Column(Integer, ForeignKey("finance.accounts.account_id", ondelete="CASCADE"), nullable=False)
    category_id = Column(Integer, ForeignKey("finance.categories.category_id", ondelete="RESTRICT"), nullable=False)
    amount = Column(Numeric, nullable=False)
    type = Column(Text, nullable=False)
    date = Column(DateTime, nullable=False, default=datetime.utcnow)
    description = Column(Text, nullable=True)
    merchant = Column(Text, nullable=True)
    
    # Relationships
    account = relationship("Account", back_populates="transactions")
    category = relationship("Category", back_populates="transactions")


class Budget(Base):
    __tablename__ = "budgets"
    __table_args__ = {"schema": "finance"}
    
    budget_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("finance.users.user_id", ondelete="CASCADE"), nullable=False)
    category_id = Column(Integer, ForeignKey("finance.categories.category_id", ondelete="CASCADE"), nullable=False)
    period = Column(Text, nullable=False)
    limit_amount = Column(Numeric, nullable=False)
    
    # Relationships
    user = relationship("User", back_populates="budgets")
    category = relationship("Category", back_populates="budgets")

