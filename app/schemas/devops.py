from pydantic import BaseModel, Field, ValidationError

class DevopsSchema(BaseModel):
    message: str
    to: str
    from_: str = Field(alias="from")
    time_to_life_sec: int = Field(alias="timeToLifeSec")

    class Config:
        allow_population_by_field_name = True

    @property
    def timeToLifeSec(self):
        return self.time_to_life_sec

    @timeToLifeSec.setter
    def timeToLifeSec(self, value):
        self.time_to_life_sec = value

def validate_devops_schema(data):
    errors = None
    try:
        DevopsSchema(
            message=data.get('message'),
            to=data.get('to'),
            from_=data.get('from_'),
            time_to_life_sec=data.get('time_to_life_sec')
        )
    except ValidationError as e:
        errors = e
    return errors