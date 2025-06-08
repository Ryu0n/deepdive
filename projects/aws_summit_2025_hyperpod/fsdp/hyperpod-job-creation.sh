if [[ "$1" == "--help" ]]; then
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --hyperpod_cluster_name <value>    Hyperpod 클러스터 이름 (기본값: ml-cluster)"
    echo "  --region <value>                   AWS 리전 (기본값: us-east-1)"
    echo "  --namespace <value>                namespace (기본값: kubeflow)"
    echo "  --job_name <value>                 Hyperpod job 이름 (기본값: hyperpod-cli-test)"
    echo "  --image_sha <value>                사용할 이미지 SHA (기본값: ECR 이미지 URL 포함 SHA256)"
    echo "  --entry_script <value>             실행할 스크립트 (기본값: \"/app/train.py --dims 100 --save_path ./\")"
    echo "  --instance_type <value>            인스턴스 타입 (기본값: ml.g5.12xlarge)"
    echo "  --node_count <value>               노드 개수 (기본값: 1)"
    echo "  --tasks_per_node <value>           노드 당 태스크 개수 (기본값: 1)"
    echo "  --mount_path_in_container <value>  컨테이너 내 마운트 경로 (기본값: /app/ckpts), S3 버킷(sagemaker-hyperpod-s3-mountpoint-poza)에는 루트 경로에 저장"
    exit 0
fi

HYPERPOD_CLUSTER_NAME=ml-cluster
REGION=us-east-1
NAMESPACE=default

MOUNT_PATH_IN_CONTAINER=/app/ckpts
JOB_NAME=hyperpod-cli-test
IMAGE_SHA=569659514718.dkr.ecr.us-east-1.amazonaws.com/torch-distributed@sha256:48b6f33988ce9aae5460cede02ac4eca646720e9de03987dade8aa03eb4f1fc8
ENTRY_SCRIPT="/app/train.py --dims 100 --save_path ${MOUNT_PATH_IN_CONTAINER}"
INSTANCE_TYPE=ml.g5.12xlarge
NODE_COUNT=1
TASKS_PER_NODE=1
RESULTS_DIR=./result
PERSISTENT_VOLUME_CLAIM=s3-claim

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --hyperpod_cluster_name)
            shift
            HYPERPOD_CLUSTER_NAME="$1"
            ;;
        --region)
            shift
            REGION="$1"
            ;;
        --namespace)
            shift
            NAMESPACE="$1"
            ;;
        --job_name)
            shift
            JOB_NAME="$1"
            ;;
        --image_sha)
            shift
            IMAGE_SHA="$1"
            ;;
        --entry_script)
            shift
            ENTRY_SCRIPT="$1"
            ;;
        --instance_type)
            shift
            INSTANCE_TYPE="$1"
            ;;
        --node_count)
            shift
            NODE_COUNT="$1"
            ;;
        --tasks_per_node)
            shift
            TASKS_PER_NODE="$1"
            ;;
        --mount_path_in_container)
            shift
            MOUNT_PATH_IN_CONTAINER="$1"
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
    shift
done

echo "Connecting to Hyperpod cluster $HYPERPOD_CLUSTER_NAME in region $REGION and namespace $NAMESPACE ..."
hyperpod connect-cluster --cluster-name $HYPERPOD_CLUSTER_NAME \
--region $REGION \
--namespace $NAMESPACE

echo "Creating Hyperpod job $JOB_NAME with image $IMAGE_SHA ..."
hyperpod start-job --job-name $JOB_NAME \
--job-kind kubeflow/PyTorchJob \
--scheduler-type Kueue \
--image $IMAGE_SHA \
--entry-script "$ENTRY_SCRIPT" \
--pull-policy Always \
--instance-type $INSTANCE_TYPE \
--node-count $NODE_COUNT \
--tasks-per-node $TASKS_PER_NODE \
--results-dir $RESULTS_DIR \
--persistent-volume-claims "$PERSISTENT_VOLUME_CLAIM:$MOUNT_PATH_IN_CONTAINER" \
