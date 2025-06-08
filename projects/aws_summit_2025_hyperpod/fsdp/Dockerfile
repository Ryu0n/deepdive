FROM pytorch/pytorch:2.1.1-cuda12.1-cudnn8-runtime

ARG DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends gcc
RUN pip install --upgrade pip && pip install poetry

WORKDIR /app

COPY pyproject.toml /app/
COPY poetry.lock /app/
RUN poetry config virtualenvs.create false && poetry install --only main

COPY ./ /app/

CMD [ "/bin/sh" ]
