from enum import Enum
from pydantic import BaseModel, Field

class RequestSchema(BaseModel):
    query_params: dict = None
    json_body: dict = None