```bash
bash hyperpod-job-creation.sh --namespace default --image_sha 569659514718.dkr.ecr.us-east-1.amazonaws.com/llama-distributed:0.0.1 --entry_script "/app/train_llama3.py --data_dir /app/train-data --data_type inst_pretrain --work_dir /app/ckpts --gpus 0 1 2 3 4 5 6 7" --instance-type ml.p5.48xlarge --tasks_per_node 8
```

- `deploy.sh` : 도커 이미지 빌드 및 ECR 레포지토리 배포 (태그에 입력된 레포지토리로 푸시됨)
- `hyperpod-job-creation.sh` : HyperPod 클러스터에 작업(`PytorchJob`, Helm Chart 배포됨) 제출. 자세한 내용은 옵션 참고.
- `instance-group-configuration.sh` : HyperPod 클러스터의 인스턴스 그룹 설정