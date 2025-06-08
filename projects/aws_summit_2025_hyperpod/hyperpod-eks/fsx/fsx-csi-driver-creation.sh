EKS_CLUSTER_NAME=sagemaker-hyperpod-eks-cluster
AWS_REGION=us-east-1

eksctl utils associate-iam-oidc-provider --cluster $EKS_CLUSTER_NAME --approve

helm install aws-fsx-csi-driver aws-fsx-csi-driver -f values.yaml -n kube-system

eksctl create iamserviceaccount \
  --name fsx-csi-controller-sa \
  --override-existing-serviceaccounts \
  --namespace kube-system \
  --cluster $EKS_CLUSTER_NAME \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonFSxFullAccess \
  --approve \
  --role-name AmazonEKSFSxLustreCSIDriverFullAccess \
  --region $AWS_REGION

SA_ROLE_ARN=$(aws iam get-role --role-name AmazonEKSFSxLustreCSIDriverFullAccess --query 'Role.Arn' --output text)

kubectl annotate serviceaccount -n kube-system fsx-csi-controller-sa \
  eks.amazonaws.com/role-arn=${SA_ROLE_ARN} --overwrite=true

kubectl rollout restart deployment fsx-csi-controller -n kube-system

kubectl apply -f manifests/storageclass.yaml
kubectl apply -f manifests/pvc.yaml