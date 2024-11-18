aws cloudformation deploy \
    --template-file ./template.yaml \
    --stack-name Agentic-Architecture-Stack \
    --capabilities CAPABILITY_NAMED_IAM \
    --region us-west-2

aws cloudformation delete-stack --stack-name Agentic-Architecture-Stack

wget https://ws-assets-prod-iad-r-pdx-f3b3f9f1a7d6a3d0.s3.us-west-2.amazonaws.com/4b5336de-e5b8-4b90-b1d8-dec31125cd95/dataloader.sh
chmod +x dataloader.sh
./dataloader.sh

aws cloudformation deploy \
    --template-file ./template.yaml \
    --stack-name agentic-architecture-stack \
    --capabilities CAPABILITY_NAMED_IAM \
    --region us-west-2


sudo yum update -y
sudo yum install -y postgresql15
sudo yum install -y git

# Install dependencies
sudo yum groupinstall -y "Development Tools"
sudo yum install -y openssl-devel bzip2-devel libffi-devel xz-devel

# Download and compile Python 3.12
cd /opt
sudo wget https://www.python.org/ftp/python/3.12.0/Python-3.12.0.tgz
sudo tar xzf Python-3.12.0.tgz
cd Python-3.12.0
sudo ./configure --enable-optimizations
sudo make altinstall

# Get the latest datalaoder
wget https://ws-assets-prod-iad-r-pdx-f3b3f9f1a7d6a3d0.s3.us-west-2.amazonaws.com/4b5336de-e5b8-4b90-b1d8-dec31125cd95/dataloader.sh
chmod +x dataloader.sh

git clone https://github.com/aws-samples/agentic-architecture-using-bedrock.git

