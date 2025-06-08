1. HyperPod Cluster 프로비저닝
```bash
bash hyperpod-eks-cluster-creation.sh
```

- 현재 한국 리전(`ap-northeast-2`)에서 HyperPod 클러스터 지원하지 않음
- 지원하는 리전 설정이 선행되어야 함. (`aws configure` & `~/.aws/config`에서 리전 설정)

2. FSx for Lustre
```bash
cd fsx && ./fsx-csi-driver-creation.sh
```
- EKS에 FSx for Lustre를 연동하기 위한 CSI Driver Helm Chart 설치
- 설치 이전, IRSA를 위한 IAM Role 및 ServiceAccount 구성

3. S3 MountPoint
```bash
cd s3 && ./s3-csi-driver-creation.sh
```

