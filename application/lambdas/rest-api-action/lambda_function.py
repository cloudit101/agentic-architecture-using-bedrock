import json
import urllib.request
import logging
import os

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # Log the incoming event
    logger.info(f"Received event: {json.dumps(event)}")
    
    # Parse the event data to extract necessary parameters
    message_version = event.get("messageVersion", "1.0")
    session_id = event.get("sessionId", "")
    api_path = event.get("apiPath", "/breeds/list/all")
    http_method = event.get("httpMethod", "GET")
    action_group = event.get("actionGroup", "")
    session_attributes = event.get("sessionAttributes", {})
    prompt_session_attributes = event.get("promptSessionAttributes", {})
    
    # Initialize response body
    response_body = {}

    # Ensure that the input and apiPath are valid
    if api_path == "/breeds/list/all" and http_method == "GET":
        try:
            # Log the API request details
            url = "https://dog.ceo/api/breeds/list/all"
            logger.info(f"Making API request to {url}")
            
            # Call the Dog CEO API using urllib
            with urllib.request.urlopen(url) as response:
                status_code = response.getcode()
                
                # Log the status code
                logger.info(f"API response status code: {status_code}")
                
                if status_code == 200:
                    breeds_data = json.loads(response.read().decode())
                    
                    # Log the successful response
                    logger.info(f"API response data: {json.dumps(breeds_data)}")
                    
                    # Prepare the response body for successful request
                    response_body = {
                        "status": "success",
                        "breeds": breeds_data.get("message", {}),
                        "message": f"Retrieved {len(breeds_data['message'])} breeds."
                    }
                    
                    # Construct the action response according to AWS Bedrock documentation
                    action_response = {
                        'actionGroup': action_group,
                        'apiPath': api_path,
                        'httpMethod': http_method,
                        'httpStatusCode': 200,
                        'responseBody': response_body
                    }
                else:
                    # Prepare the response body for failure
                    response_body = {
                        "status": "error",
                        "message": f"Failed to fetch breeds. Status code: {status_code}"
                    }
                    
                    # Log the failure response
                    logger.error(f"API error: {json.dumps(response_body)}")
                    
                    action_response = {
                        'actionGroup': action_group,
                        'apiPath': api_path,
                        'httpMethod': http_method,
                        'httpStatusCode': status_code,
                        'responseBody': response_body
                    }

        except Exception as e:
            # Prepare the response body for exception
            response_body = {
                "status": "error",
                "message": "An error occurred while fetching the breed list.",
                "error": str(e)
            }
            
            # Log the exception
            logger.error(f"Exception occurred: {str(e)}")
            
            action_response = {
                'actionGroup': action_group,
                'apiPath': api_path,
                'httpMethod': http_method,
                'httpStatusCode': 500,
                'responseBody': response_body
            }

    else:
        # Handle invalid input or incorrect API path
        response_body = {
            "status": "error",
            "message": "Invalid input or API path."
        }
        
        # Log invalid input
        logger.error(f"Invalid input or API path: {json.dumps(response_body)}")

        action_response = {
            'actionGroup': action_group,
            'apiPath': api_path,
            'httpMethod': http_method,
            'httpStatusCode': 400,
            'responseBody': response_body
        }

    # Prepare the final response as per AWS Bedrock documentation
    api_response = {
        'messageVersion': '1.0', 
        'response': action_response,
        'sessionAttributes': session_attributes,
        'promptSessionAttributes': prompt_session_attributes
    }

    # Log the final API response
    logger.info(f"Final API response: {json.dumps(api_response)}")

    # Return the API response
    return api_response