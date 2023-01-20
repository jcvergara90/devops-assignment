import os
import json
from schemas.devops import validate_devops_schema
from schemas.devops import DevopsSchema
from utils.exceptions import ExceptionHandler


class DevopsResource(object):
    resource = 'Devops'

    def _validate_payload(self, payload):
        errors = validate_devops_schema(payload)
        if errors is not None:
            raise ExceptionHandler(errors)

    def _prepare_message(self, payload):
        to = payload.get('to')
        message = f'Hello {to} your message will be send'
        return message

    def on_post(self, request):
        payload = request.json_body
        self._validate_payload(payload)
        data = {
            'message': self._prepare_message(payload)
        }
        return data
