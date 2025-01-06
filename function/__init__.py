import logging
import json
import time
import azure.functions as func
from .. import ToolsB as tools

def main(req: func.HttpRequest) -> func.HttpResponse:
    start = time.time()
    logging.info('Python HTTP trigger function processed a request.')

    try:
        # Decode and return request body as JSON
        req_body = req.get_json()
    except ValueError:
        numA, numB = None, None
        pass
    else:
        numA = req_body.get('A')
        numB = req_body.get('B')        

    if numA and numB:
        # Call Common Functions
        sum2 = tools.sum2(numA, numB)
        sub2 = tools.sub2(numA, numB)
        pow2 = tools.pow2(numA, numB)
        div2 = tools.div2(numA, numB)

        dt1 = time.time()-start
        return func.HttpResponse(
            json.dumps({
                'method': req.method,
                'url': req.url,
                'headers': dict(req.headers),
                'params': dict(req.params),
                'get_body': req.get_body().decode(),
                'timer': dt1,
                'return': 'Function App recieved %s and %s' %({numA}, {numB}) ,
                'Sum': sum2,
                'Sub': sub2,
                'Pow': pow2,
                'Div': div2
            })
            )

    else:
        dt1 = time.time()-start
        return func.HttpResponse(
            json.dumps({
                'method': req.method,
                'url': req.url,
                'headers': dict(req.headers),
                'params': dict(req.params),
                'get_body': req.get_body().decode(),
                'timer': dt1,
                'return': 'Please pass numbers A,B to Function App in the request body'
            })
            , status_code=400
        )
