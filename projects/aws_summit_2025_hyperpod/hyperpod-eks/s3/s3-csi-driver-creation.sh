aws iam create-policy \
    --policy-name S3MountpointAccessPolicy \
    --policy-document file://iam/s3accesspolicy.json

EKS_CLUSTER_NAME=sagemaker-hyperpod-eks-cluster-3
AWS_REGION=us-east-1
ROLE_NAME=SM_HP3_S3_CSI_ROLE
POLICY_ARN=$(aws iam list-policies --query 'Policies[?PolicyName==`S3MountpointAccessPolicy`]' | jq '.[0].Arn' |  tr -d '"')

eksctl create iamserviceaccount \
    --name s3-csi-driver-sa \
    --namespace kube-system \
    --cluster $EKS_CLUSTER_NAME \
    --attach-policy-arn $POLICY_ARN \
    --approve \
    --role-name $ROLE_NAME \
    --region $AWS_REGION \
    --role-only

ROLE_ARN=$(aws iam get-role --role-name $ROLE_NAME  --query 'Role.Arn' --output text)
eksctl create addon --name aws-mountpoint-s3-csi-driver --cluster $EKS_CLUSTER_NAME --service-account-role-arn $ROLE_ARN --force

kubectl apply -f manifests/pvc.yaml
kubectl apply -f manifests/pv.yaml