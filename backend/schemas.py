
import re
from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator


class RegisterRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    email: EmailStr | None = None
    login: str = Field(
        min_length=3,
        max_length=32,
        pattern=r"^[a-zA-Z0-9._-]+$",
    )
    password: str = Field(max_length=128)

    @field_validator("password")
    @classmethod
    def validate_password(cls, value: str) -> str:
        if len(value) < 8:
            raise ValueError("Пароль должен содержать минимум 8 символов")

        if not re.search(r"[A-Z]", value):
            raise ValueError("Пароль должен содержать заглавную латинскую букву")

        if not re.search(r"[a-z]", value):
            raise ValueError("Пароль должен содержать строчную латинскую букву")

        if not re.search(r"[0-9]", value):
            raise ValueError("Пароль должен содержать цифру")

        if not re.search(r"[^\w\s]|_", value):
            raise ValueError("Пароль должен содержать специальный символ")

        return value


class LoginRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    login: str = Field(min_length=1, max_length=32)
    password: str = Field(min_length=1, max_length=128)


class DeleteAccountRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    password: str = Field(min_length=1, max_length=128)
