FROM pytorch/pytorch:2.10.0-cuda13.0-cudnn9-runtime

ENV HOSTNAME='comfyui-gpu'
ENV PIP_BREAK_SYSTEM_PACKAGES=1
ENV MAX_CONTINUOUS_TASK=5
ENV TASK_NUMBER=1
ENV COMYUI_LIMI_NUMBER=2

WORKDIR /workspace

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        python3-dev \
        build-essential \
        libglib2.0-0 \
        redis-server \
        supervisor \
        tmux \
        vim \
        libmagickwand-dev \
        libgl1 \
        git \
        git-lfs \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY static/comfyui_requirements.txt /tmp/comfyui_requirements.txt
COPY static/server_requirements.txt /tmp/server_requirements.txt
COPY static/demo.txt /tmp/demo.txt

COPY conf /workspace/conf

RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

RUN wget -P /tmp https://github.com/nunchaku-ai/nunchaku/releases/download/v1.2.1/nunchaku-1.2.1+cu13.0torch2.10-cp312-cp312-linux_x86_64.whl

RUN python -m pip install /tmp/nunchaku-1.2.1+cu13.0torch2.10-cp312-cp312-linux_x86_64.whl

RUN python -m pip install pip -U && python -m pip install -r /tmp/server_requirements.txt && \
    python -m pip install -r /tmp/comfyui_requirements.txt && \
    rm -f /tmp/comfyui_requirements.txt /tmp/server_requirements.txt && mkdir -p /workspace/logs

RUN python -m pip install -r /tmp/demo.txt && rm -f /tmp/demo.txt

RUN python -m pip install --no-build-isolation git+https://github.com/facebookresearch/sam2 -vv

RUN python -m pip uninstall flash-attn -y && python -m pip install starlette==0.52.1

RUN mkdir -p /etc/supervisor/conf.d

RUN mv /workspace/conf/redis.conf /etc/redis/redis.conf

RUN mv /workspace/conf/redis-service.conf /etc/supervisor/conf.d/