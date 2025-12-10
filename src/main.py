import json
import boto3



def lambda_handler(event, context):
    dynamodb = boto3.resource("dynamodb")
    tableName = 'trees-db'
    table = dynamodb.Table(tableName)
    all_items = []
    body = ''

    try:
        response = table.scan()
        all_items.extend(response['Items'])

        body += '<div class="grid">'
        for item in all_items:
            body += f"""
            <div class="card">
                <img src="{item['treeurl']}">
                <div class="card-body">
                <div class="card-title">{item['treename']}</div>
                </div>
            </div>
            """

        body += '</div>'

    except Exception as e:
        body = 'Error: ' + str(e)

    return {
        'statusCode': 200,
        'body': body,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET,OPTIONS",
            "Access-Control-Allow-Headers": "*",
            "Content-Type": "text/html"
        }
    }




