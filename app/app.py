from fastapi import FastAPI
from fastapi import Request
from fastapi.middleware.cors import CORSMiddleware

from schemas.request import RequestSchema
from utils.decorators import handler_response
from utils.logger import logger

from controllers.health import HealthResource
from controllers.devops import DevopsResource
from schemas.devops import DevopsSchema

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# health
@app.get("/health")
@handler_response(logger=logger)
def health():
    return HealthResource().on_get()


# devops
@app.post("/devops")
@handler_response(logger=logger)
def create_devops(payload: DevopsSchema, request: Request):
    request = RequestSchema(
        query_params=request.query_params,
        json_body=payload
    )
    return DevopsResource().on_post(request)
