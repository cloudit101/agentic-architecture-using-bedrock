aws cloudformation deploy \
    --template-file ./template.yaml \
    --stack-name Agentic-Architecture-Stack \
    --capabilities CAPABILITY_NAMED_IAM \
    --region us-west-2

aws cloudformation delete-stack --stack-name Agentic-Architecture-Stack

wget https://ws-assets-prod-iad-r-pdx-f3b3f9f1a7d6a3d0.s3.us-west-2.amazonaws.com/4b5336de-e5b8-4b90-b1d8-dec31125cd95/dataloader.sh
chmod +x dataloader.sh
./dataloader.sh