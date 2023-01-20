import os
from datetime  import datetime

class HealthResource(object):

    def on_get(self):
        data = {
            'message': 'The Devops api is healthy.',
            'status': 'ok',
            'datetime': str(datetime.now())
        }
        return data