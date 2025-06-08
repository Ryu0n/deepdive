if [[ "$1" == "--help" ]]; then
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --account-id <value>   AWS Account ID (default: aws sts get-caller-identity 결과)"
    echo "  --region <value>       AWS 리전 (default: aws configure get region 결과)"
    echo "  --repository <value>   ECR Repository (default: torch-distributed)"
    echo "  --tag <value>          Docker tag (default: 0.0.1)"
    exit 0
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region)
REPOSITORY=torch-distributed
TAG=0.0.1

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --account-id)
            shift
            ACCOUNT_ID="$1"
            ;;
        --region)
            shift
            REGION="$1"
            ;;
        --repository)
            shift
            REPOSITORY="$1"
            ;;
        --tag)
            shift
            TAG="$1"
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
    shift
done

ECR_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPOSITORY}"
echo "Building Docker image for $REPOSITORY with ECR URI: $ECR_URI:$TAG ..."
docker build . -f Dockerfile -t $ECR_URI:$TAG

echo "Pushing Docker image ($ECR_URI:$TAG) to ECR ..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_URI
docker push "$ECR_URI:$TAG"
