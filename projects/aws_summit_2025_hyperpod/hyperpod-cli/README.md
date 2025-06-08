```bash
bash hyperpod-cli-installation.sh
```
- `hyperpod` CLI 설치 이전에 가상환경 구성 및 활성화가 선행되어야 함.

```bash
hyperpod --help

(hyperpod) (base)  shawn 🍖   ~/Documents/Github/ops-sandbox/hyperpod-cli   ops-836  hyperpod --help                                                

Find more information at: https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-hyperpod.html

Basic Commands:
  * get-clusters    Get clusters information for HyperPod EKS clusters.
  * connect-cluster Creates a connection from users local terminal to the HyperPod cluster 
                    allowing user to start and preform other basic operations with training jobs.
  * start-job       Start a training job from a file on HyperPod cluster.
  * get-job         Show details of a specific training job submitted on HyperPod cluster.
  * list-jobs       List training job on a HyperPod cluster.
  * cancel-job      Cancel training job on a HyperPod cluster.
  * patch-job       Patch a job with specific operation on a HyperPod cluster.
Troubleshooting and Debugging Commands:
  * get-log         Get logs for a pod of training job running on HyperPod cluster.
  * list-pods       List all pods associated with a training job on HyperPod cluster.
  * exec            Execute a command on a pod of a training job on HyperPod cluster.

Usage:
  hyperpod [command] [options]

Use "hyperpod <command> --help" for more information about a given command.

(hyperpod) (base)  shawn 🍖   ~/Documents/Github/ops-sandbox/hyperpod-cli   ops-836  hyperpod get-clusters --output table
Updated context arn:aws:eks:us-east-1:569659514718:cluster/sagemaker-hyperpod-eks-cluster in /tmp/kubeconfig
 Cluster    | InstanceType   |   TotalNodes | AcceleratorDevicesAvailable   |   NodeHealthStatus=Schedulable | DeepHealthCheckStatus=Passed
------------+----------------+--------------+-------------------------------+--------------------------------+--------------------------------
 ml-cluster | ml.g5.12xlarge |            1 | 4                             |                              1 | N/A
 ml-cluster | ml.m5.2xlarge  |            1 | N/A                           |                              1 | N/A
```

