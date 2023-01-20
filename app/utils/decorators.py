import json
from functools import wraps

from .exceptions import ExceptionNotFound
from .exceptions import ExceptionHandler
from .exceptions import ExceptionAccessDenied
from .exceptions import ErrorHTTPBadRequest

from .constants import HTTP_OK
from .constants import HTTP_BAD_REQUEST
from .constants import HTTP_UNAUTHORIZED
from .constants import HTTP_CONFLICT
from .constants import HTTP_NOT_FOUND

from .response import json_response


def handler_response(logger):
    def handler_except_method(method):
        @wraps(method)
        def method_wrapper(*args, **kwargs):
            try:
                response = method(*args, **kwargs)
                return json_response(HTTP_OK, response)
            except ExceptionAccessDenied as e:
                logger.error(e.__str__())
                error = {'error': e.__str__()}
                return json_response(HTTP_UNAUTHORIZED, error)
            except ExceptionHandler as e:
                logger.error(e.__str__())
                error = {'error': e.__str__()}
                return json_response(HTTP_CONFLICT, error)
            except ExceptionNotFound as e:
                logger.error(e.__str__())
                error = {'error': e.__str__()}
                return json_response(HTTP_NOT_FOUND, error)
            except (Exception, ErrorHTTPBadRequest) as e:
                logger.error(e.__str__())
                error = {'error': e.__str__()}
                return json_response(HTTP_BAD_REQUEST, error)
        return method_wrapper
    return handler_except_method