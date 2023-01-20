import json
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from .exceptions import ErrorHTTPStatusCode

__CONTENT_TYPE_JSON = "application/json"
__HTTP_STATUS_CODE_OK = 200

def json_response(status_code, data={}):

    response = JSONResponse(
        status_code=status_code, 
        content=data
    )

    return response