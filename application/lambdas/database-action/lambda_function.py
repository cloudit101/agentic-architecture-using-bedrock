import json
import os
import psycopg2
import logging
import boto3
import uuid
import time
from botocore.exceptions import ConnectTimeoutError, BotoCoreError, ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))
    
    # Extracting the necessary details from the event
    try:
        agent = event['agent']
        actionGroup = event['actionGroup']
        function = event['function']
        parameters = event.get('parameters', [])
    except KeyError as e:
        logger.error("Missing key in event: %s", e)
        return {
            "statusCode": 400,
            "body": json.dumps({"error": f"Missing key in event: {e}"})
        }
    
    # Extract the SQL query from parameters
    sql_query = next((param['value'] for param in parameters if param['name'] == 'sql_query'), None)
    if sql_query:
        sql_query = sql_query.rstrip(';')  # Remove trailing semicolon if present
    logger.info("Initial SQL query: %s", sql_query)
    
    if not sql_query:
        logger.error("No SQL query found in parameters")
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "No SQL query found in parameters"})
        }
    
    user_question = next((param['value'] for param in parameters if param['name'] == 'user_question'), None)
    if user_question:
        logger.info("User question: %s", user_question)
        
    if not user_question:
        logger.error("User question found in parameters")
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "No User question found in parameters"})
        }
    
    # Fetch PostgreSQL connection details from environment variables
    rds_host = os.environ.get('RDS_HOST', 'petstore-instance-1.c7icaemqq3d4.us-east-1.rds.amazonaws.com')
    rds_db = os.environ.get('RDS_DB', 'petstore')
    rds_port = os.environ.get('RDS_PORT', '5432')
    rds_username = os.environ.get('RDS_USERNAME', 'postgres')
    rds_password = os.environ.get('RDS_PASSWORD', 'petstoremaster')
    
    # Initialize Bedrock Agent Runtime client
    # bedrock_agent_runtime_client = boto3.client('bedrock-agent-runtime')
    bedrock_agent_runtime_client=boto3.client(
            service_name="bedrock-agent-runtime", region_name='us-east-1'
        )
    logger.info("bedrock_agent_runtime_client: %s", bedrock_agent_runtime_client)
    
    # Define maximum number of retries to prevent infinite loops
    MAX_RETRIES = 10
    retries = 0
    
    while retries < MAX_RETRIES:
        try:
            # Establish the connection to the PostgreSQL RDS database
            connection = psycopg2.connect(
                host=rds_host,
                port=rds_port,
                database=rds_db,
                user=rds_username,
                password=rds_password
            )
            cursor = connection.cursor()
            
            logger.info("Executing SQL query: %s", sql_query)
            # Execute the SQL query
            cursor.execute(sql_query)
            
            # Commit the transaction if it's an INSERT, UPDATE, or DELETE statement
            if sql_query.strip().upper().startswith(("INSERT", "UPDATE", "DELETE")):
                connection.commit()
            
            # Fetch results if it's a SELECT statement
            if sql_query.strip().upper().startswith("SELECT"):
                columns = [desc[0] for desc in cursor.description]
                rows = cursor.fetchall()
                result = [dict(zip(columns, row)) for row in rows]
            else:
                result = {"message": "Query executed successfully"}
            
            logger.info("SQL result: %s", result)
            
            # Close the cursor and connection
            cursor.close()
            connection.close()
            
            response_body = {
                'TEXT': {
                    'body': json.dumps(result)
                }
            }
            
            # If execution is successful, break out of the loop
            break
        
        except Exception as e:
            logger.error("Error executing query: %s", e, exc_info=True)
            
            # Create the inputText JSON object
            correctionInputText = {
                "SQL Statement": sql_query,
                "User question": user_question,
                "Error Message": str(e)
            }
            # formattedInputString = ', '.join([f"{key}={value}" for key, value in correctionInputText.items()])
            logger.info("correctionInputText: %s", correctionInputText)
            
            try:
                # Wait for 2 seconds
                time.sleep(2)
                session_id = uuid.uuid4().hex
                logger.info("Generated session_id: %s", session_id)
                
                # Define additional parameters for the agent invocation
                enable_trace = False  # Set as needed
                end_session = False    # Set as needed
        
                # Invoke the Bedrock Agent to get a corrected SQL query
                agent_response = bedrock_agent_runtime_client.invoke_agent(
                    sessionId=session_id,
                    inputText=json.dumps(correctionInputText),
                    # inputText=correctionInputText,
                    agentId='R77GGNZXV2',
                    agentAliasId='TSTALIASID'
                )
                
                logger.info("Agent response: %s", agent_response)
                
                completion = ""
                for event in agent_response.get("completion"):
                    chunk = event["chunk"]
                    completion = completion + chunk["bytes"].decode()
                
                logger.info("Agent completion: %s", completion)
                corrected_sql = completion
                
                if not corrected_sql:
                    logger.error("Agent did not return a corrected SQL query.")
                    response_body = {
                        'TEXT': {
                            'body': {"error": "Agent failed to provide a corrected SQL query."}
                        }
                    }
                    break  # Exit the loop since we cannot proceed without a valid query
                
                logger.info("Agent provided corrected SQL query: %s", corrected_sql)
                sql_query = corrected_sql.rstrip(';')  # Update sql_query with corrected version
            
            except Exception as agent_error:
                logger.error("Error invoking Bedrock Agent: %s", agent_error, exc_info=True)
                response_body = {
                    'TEXT': {
                        'body': {"error": f"Failed to invoke agent: {str(agent_error)}"}
                    }
                }
                break  # Exit the loop since agent invocation failed
            
            retries += 1
            logger.info("Retrying SQL execution (%d/%d)...", retries, MAX_RETRIES)
    
    else:
        # If maximum retries reached without success
        logger.error("Maximum retries reached. Unable to execute SQL query successfully.")
        response_body = {
            'TEXT': {
                'body': {"error": "Maximum retries reached. Unable to execute SQL query successfully."}
            }
        }
    
    # Construct the function response
    function_response = {
        'actionGroup': actionGroup,
        'function': function,
        'functionResponse': {
            'responseBody': response_body
        }
    }
    
    session_attributes = event.get('sessionAttributes', {})
    prompt_session_attributes = event.get('promptSessionAttributes', {})
    
    # Construct the action response
    action_response = {
        'messageVersion': '1.0', 
        'response': function_response,
        'sessionAttributes': session_attributes,
        'promptSessionAttributes': prompt_session_attributes
    }
    
    logger.info("Response: %s", action_response)
    
    return action_response