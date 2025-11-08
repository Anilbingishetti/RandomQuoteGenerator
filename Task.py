import requests

def handler(event, context):
    """
    AWS Lambda handler entry-point.
    """
    url = "https://api.quotable.io/random"
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
        quote = data["content"]
        author = data["author"]

        # Return a Lambda-compatible response
        return {
            "statusCode": 200,
            "body": f'"{quote}" — {author}'
        }
    else:
        return {
            "statusCode": 500,
            "body": "Failed to retrieve quote. Try again later."
        }
