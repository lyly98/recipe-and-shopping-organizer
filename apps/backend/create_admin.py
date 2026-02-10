#!/usr/bin/env python3
"""Create the first admin user."""
import asyncio
import sys
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent / "src"))

from app.core.config import settings
from app.core.db.database import local_session
from app.core.security import get_password_hash
from app.models.user import User
from sqlalchemy import select


async def create_admin():
    """Create admin user if it doesn't exist."""
    async with local_session() as session:
        # Check if admin exists
        query = select(User).filter_by(email=settings.ADMIN_EMAIL)
        result = await session.execute(query)
        user = result.scalar_one_or_none()

        if user:
            print(f"✅ Admin user already exists: {settings.ADMIN_USERNAME}")
            print(f"   Email: {settings.ADMIN_EMAIL}")
            return

        # Create admin user
        admin_user = User(
            name=settings.ADMIN_NAME,
            username=settings.ADMIN_USERNAME,
            email=settings.ADMIN_EMAIL,
            hashed_password=get_password_hash(settings.ADMIN_PASSWORD),
            is_superuser=True,
        )

        session.add(admin_user)
        await session.commit()
        await session.refresh(admin_user)

        print(f"✅ Admin user created successfully!")
        print(f"   Username: {settings.ADMIN_USERNAME}")
        print(f"   Email: {settings.ADMIN_EMAIL}")
        print(f"   Password: {settings.ADMIN_PASSWORD}")
        print(f"\n🔐 Use these credentials to login!")


if __name__ == "__main__":
    asyncio.run(create_admin())
