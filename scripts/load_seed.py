#!/usr/bin/env python3
import asyncio
import asyncpg
import os
import subprocess
from pathlib import Path

async def load_seed_data():
    db_host = os.getenv("DB_HOST", "localhost")
    db_port = int(os.getenv("DB_PORT", "5432"))
    db_name = os.getenv("DB_NAME", "finance")
    db_user = os.getenv("DB_USER", "finance_app_user")
    db_password = os.getenv("DB_PASSWORD", "strong_password_here")
    
    seed_file = Path(__file__).parent.parent / "seed_data.sql"
    
    if not seed_file.exists():
        print(f"Error: seed file not found at {seed_file}")
        return
    
    print(f"Connecting to database {db_name} at {db_host}:{db_port} as {db_user}...")
    
    try:
        conn = await asyncpg.connect(
            host=db_host,
            port=db_port,
            user=db_user,
            password=db_password,
            database=db_name
        )
        
        print("Clearing existing data...")
        try:
            await conn.execute("""
                TRUNCATE TABLE finance.transaction_history CASCADE;
                TRUNCATE TABLE finance.account_balance_history CASCADE;
                TRUNCATE TABLE finance.transactions CASCADE;
                TRUNCATE TABLE finance.budgets CASCADE;
                TRUNCATE TABLE finance.accounts CASCADE;
                TRUNCATE TABLE finance.users_info CASCADE;
                TRUNCATE TABLE finance.users CASCADE;
                TRUNCATE TABLE finance.categories CASCADE;
            """)
            await conn.execute("ALTER SEQUENCE finance.categories_category_id_seq RESTART WITH 1;")
            await conn.execute("ALTER SEQUENCE finance.users_user_id_seq RESTART WITH 1;")
            await conn.execute("ALTER SEQUENCE finance.accounts_account_id_seq RESTART WITH 1;")
            await conn.execute("ALTER SEQUENCE finance.transactions_transaction_id_seq RESTART WITH 1;")
            await conn.execute("ALTER SEQUENCE finance.budgets_budget_id_seq RESTART WITH 1;")
            print("Existing data cleared.")
        except Exception as e:
            print(f"Warning: Could not clear data (might not exist): {e}")
        
        await conn.close()
        
        print(f"Loading seed data from {seed_file}...")
        
        with open(seed_file, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        result = subprocess.run(
            ['docker-compose', 'exec', '-T', 'db', 'psql', '-U', db_user, '-d', db_name],
            input=sql_content,
            capture_output=True,
            text=True,
            cwd=Path(__file__).parent.parent
        )
        
        if result.returncode != 0:
            print(f"Error executing seed file:")
            print(result.stdout)
            print(result.stderr)
            raise Exception(f"psql failed with return code {result.returncode}")
        
        print("Seed data loaded successfully!")
        
        conn = await asyncpg.connect(
            host=db_host,
            port=db_port,
            user=db_user,
            password=db_password,
            database=db_name
        )
        
        result = await conn.fetch("""
            SELECT 
                'users' as table_name, COUNT(*) as count FROM finance.users
            UNION ALL
            SELECT 'categories', COUNT(*) FROM finance.categories
            UNION ALL
            SELECT 'accounts', COUNT(*) FROM finance.accounts
            UNION ALL
            SELECT 'transactions', COUNT(*) FROM finance.transactions
            UNION ALL
            SELECT 'budgets', COUNT(*) FROM finance.budgets
            UNION ALL
            SELECT 'users_info', COUNT(*) FROM finance.users_info
            ORDER BY table_name;
        """)
        
        print("\nData summary:")
        for row in result:
            print(f"  {row['table_name']}: {row['count']} records")
        
        await conn.close()
        
    except Exception as e:
        print(f"Error loading seed data: {e}")
        raise

if __name__ == "__main__":
    asyncio.run(load_seed_data())

