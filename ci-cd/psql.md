# Get the stack information for the stack with the specific description
STACK_DETAILS=$(aws cloudformation describe-stacks --query "Stacks[*]" --output json | jq -r '.[] | select(.Description == "Agentic AI with Bedrock Agents workshop")')

# Extract the stack name from the stack details
export STACK_NAME=$(echo "$STACK_DETAILS" | jq -r '.StackName')

export DB_ENDPOINT=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs[?OutputKey=='DBClusterEndpoint'].OutputValue" --output text)

## Connect to PostgreSQL using psql
```sql
psql --host=$DB_ENDPOINT \
     --port=5432 \
     --username=postgres \
     --password \
     --dbname=petstore

-- List all tables in the current schema
\dt

-- Show database conent from tables:
SELECT * FROM public.address;
SELECT * FROM public.category;
SELECT * FROM public.customer;
SELECT * FROM public."order";
SELECT * FROM public.pet;
SELECT * FROM public.pettag;
SELECT * FROM public.tag;
SELECT * FROM public."user";