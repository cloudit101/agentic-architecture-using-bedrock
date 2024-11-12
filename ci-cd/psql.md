# PostgreSQL Connection Commands

## Connect to PostgreSQL using psql
```sql
export STACK_NAME="Agentic-Architecture-Stack"
export DB_ENDPOINT=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs[?OutputKey=='DBClusterEndpoint'].OutputValue" --output text)
psql --host=$DB_ENDPOINT \
     --port=5432 \
     --username=postgres \
     --password \
     --dbname=petstore

-- List all schemas in the current database
\dn

-- List all databases in the PostgreSQL server
\l

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