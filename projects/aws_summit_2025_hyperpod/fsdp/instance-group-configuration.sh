if [[ "$1" == "--help" ]]; then
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --hyperpod_cluster_name <value>    Hyperpod 클러스터 이름 (기본값: ml-cluster)"
    exit 0
fi

HYPERPOD_CLUSTER_NAME="ml-cluster"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --hyperpod_cluster_name)
            shift
            HYPERPOD_CLUSTER_NAME="$1"
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
    shift
done

LIFECYCLE_S3_BUCKET="sagemaker-hyperpod-eks-bucket-569659514718-us-east-1"
EXCUTION_ROLE="arn:aws:iam::569659514718:role/sagemaker-hyperpod-eks-SMHP-Exec-Role-us-east-1"
INSTANCE_GROUPS=$(cat <<EOF
[
    {
        "InstanceGroupName": "worker-group-1",
        "InstanceType": "ml.g5.12xlarge",
        "InstanceCount": 0,
        "LifeCycleConfig": {
            "SourceS3Uri": "s3://$LIFECYCLE_S3_BUCKET",
            "OnCreate": "on_create.sh"
        },
        "ExecutionRole": "$EXCUTION_ROLE",
        "InstanceStorageConfigs": [
            {
                "EbsVolumeConfig": {
                    "VolumeSizeInGB": 500
                }
            }
        ]
    },
        {
        "InstanceGroupName": "worker-group-2",
        "InstanceType": "ml.m5.2xlarge",
        "InstanceCount": 0,
        "LifeCycleConfig": {
            "SourceS3Uri": "s3://$LIFECYCLE_S3_BUCKET",
            "OnCreate": "on_create.sh"
        },
        "ExecutionRole": "$EXCUTION_ROLE",
        "InstanceStorageConfigs": [
            {
                "EbsVolumeConfig": {
                    "VolumeSizeInGB": 500
                }
            }
        ]
    },
    {
        "InstanceGroupName": "worker-group-3",
        "InstanceType": "ml.p5.48xlarge",
        "InstanceCount": 1,
        "LifeCycleConfig": {
            "SourceS3Uri": "s3://$LIFECYCLE_S3_BUCKET",
            "OnCreate": "on_create.sh"
        },
        "ExecutionRole": "$EXCUTION_ROLE",
        "InstanceStorageConfigs": [
            {
                "EbsVolumeConfig": {
                    "VolumeSizeInGB": 500
                }
            }
        ]
    }
]
EOF
)

aws sagemaker update-cluster --cluster-name $HYPERPOD_CLUSTER_NAME \
    --instance-groups "$INSTANCE_GROUPS"
