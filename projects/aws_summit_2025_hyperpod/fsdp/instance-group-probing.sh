#!/bin/bash

if [[ "$1" == "--help" ]]; then
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --hyperpod_cluster_name <value>    Hyperpod 클러스터 이름 (기본값: ml-cluster)"
    echo "  --instance_group_name <value>       인스턴스 그룹 이름 (기본값: worker-group-1)"
    exit 0
fi

HYPERPOD_CLUSTER_NAME="ml-cluster"
INSTANCE_GROUP_NAME="worker-group-1"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --hyperpod_cluster_name)
            shift
            HYPERPOD_CLUSTER_NAME="$1"
            ;;
        --instance_group_name)
            shift
            INSTANCE_GROUP_NAME="$1"
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
    shift
done


while true; do
    CURRENT_COUNT=$(aws sagemaker describe-cluster --cluster-name $HYPERPOD_CLUSTER_NAME --query 'InstanceGroups[?InstanceGroupName==`'"$INSTANCE_GROUP_NAME"'`].CurrentCount' --output text)
    
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    if [ $CURRENT_COUNT -gt 0 ]; then
        echo "Current timestamp: $timestamp / $INSTANCE_GROUP_NAME 의 인스턴스 카운트가 생성되었습니다."
        break
    elif [ $CURRENT_COUNT -eq 0 ]; then
        echo "Current timestamp: $timestamp / $INSTANCE_GROUP_NAME 의 인스턴스 카운트가 0입니다."
        bash ./instance-group-configuration.sh
        sleep 60
    fi

done

