from fastapi import FastAPI # Includes Starlette

app = FastAPI()

# Notes : Refer to https://fastapi.tiangolo.com/tutorial/body/
"""
(1) uvicorn main:app --reload &
    uvicorn is a ASYNCRHNOUS Web Server Gate Interface (ASGI). Like WSGI, it is a convention for webserver to forward requests to PYTHON web appliction.
(2) Endoints
    localhost:8000
    localhost:8000/docs --> SWAGGER
        ueses openapi to define schema; can be vieweed ad localhost:8000/openapi.json

"""
#

@app.get("/")
async def root():
    return {"message": "Hello World"}

# -------------------------------
# Path Parameters
# -------------------------------

# Shows path parameters with get
#  http://127.0.0.1:8000/items/3 --> good
#  http://127.0.0.1:8000/items/"3" --> error; uses pydantic to check the data type, and gives a friendly error message
@app.get("/items/{item_id}")
async def read_item(item_id):
    return {"item_id": item_id}

# Uses Enum to limit the set of inputs we allow input
# http://127.0.0.1:8000/models/alexnet # the address is maped to the decorator @app.get. Appears to have some templating; alaxnet -> model_name
from enum import Enum
class ModelName(str, Enum):
    alexnet = "alexnet"
    resnet = "resnet"
    lenet = "lenet"
@app.get("/models/{model_name}")
async def get_model(model_name: ModelName):
    if model_name == ModelName.alexnet:
        return {"model_name": model_name, "message": "Deep Learning FTW!"}

    if model_name.value == "lenet":
        return {"model_name": model_name, "message": "LeCNN all the images"}

    return {"model_name": model_name, "message": "Have some residuals"}





# -------------------------------
# Query Parameters
# -------------------------------
fake_items_db = [{"item_name": "Foo"}, {"item_name": "Bar"}, {"item_name": "Baz"}]
from typing import Optional

# call with: http://127.0.0.1:8000/items/?skip=0&limit=10
@app.get("/items/")
async def read_item(skip: int = 0, limit: int = 10):
    return fake_items_db[skip : skip + limit]


# -------------------------------
# Query Parameters with a post; uses data model
# -------------------------------
from typing import Optional
from pydantic import BaseModel

class Item(BaseModel):
    name: str
    description: Optional[str] = None
    price: float
    tax: Optional[float] = None

app = FastAPI()

# call via swagger: http://localhost:8000/docs#/default/create_item_items__post
# curl -X POST "http://localhost:8000/items/" -H  "accept: application/json" -H  "Content-Type: application/json" -d "{\"name\":\"Tom Chang\",\"description\":\"Awesome\",\"price\":10000,\"tax\":0}"
@app.post("/items/")
async def create_item(item: Item):
    return item