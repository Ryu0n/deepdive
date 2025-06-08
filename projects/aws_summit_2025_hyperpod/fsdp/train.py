import os

import torch
import torch.nn as nn
import torch.distributed as dist
from torch.nn.parallel import DistributedDataParallel as DDP

import argparse
import logging


class Model(torch.nn.Module):
    def __init__(self, dims: int):
        super().__init__()
        self.layers = nn.ModuleList(
            [
                nn.Linear(100, dims),
                nn.Linear(dims, dims),
                nn.Linear(dims, dims),
                nn.Linear(dims, 10),
            ],
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        for layer in self.layers:
            x = layer(x)
        return torch.nn.functional.softmax(x)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--dims", type=int)
    parser.add_argument("--save_path", type=str, required=True)
    args, _ = parser.parse_known_args()

    print(f"CUDA Available: {torch.cuda.is_available()}")

    dist.init_process_group(backend="nccl", init_method="env://")
    dist.barrier()
    print(f"Process group initialized")
    model = Model(args.dims)

    rank = os.getenv("RANK")
    device = torch.device(f"cuda:{rank}")
    print(f"Device: {device.index}")
    model.to(device)
    print("!!")
    ddp_model = DDP(
        model,
        device_ids=[device],
    )
    print("!!!")

    bsz = 4
    data = torch.randn(bsz, 100).float().to(device)
    label = torch.randint(low=0, high=10, size=(bsz,)).long().to(device)

    optimizer = torch.optim.SGD(params=model.parameters(), lr=0.01)
    criterion = torch.nn.CrossEntropyLoss()
    dist.barrier()
    for epoch in range(10):
        optimizer.zero_grad()
        logits = ddp_model.forward(data[int(rank)])
        loss: torch.Tensor = criterion.forward(logits, label[int(rank)])
        print(f"Rank: {rank} | loss: {loss.item()}")
        dist.broadcast(loss, src=0)
        print(f"Rank: {rank} | synced loss: {loss.item()}")
        loss.backward()
        optimizer.step()

    state_dict = ddp_model.module.to("cpu").state_dict()
    if int(rank) == 0:
        torch.save(state_dict, f"{args.save_path}/final_ckpt.pt")

    print("All finished")
    dist.barrier()
    dist.destroy_process_group()

    with open(f"{args.save_path}/data/a.txt", "r") as f:
        lines = f.readlines()
        for line in lines:
            print(line.strip())
