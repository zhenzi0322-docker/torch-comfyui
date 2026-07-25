

## 拉取镜像

```bash
docker pull zhenzi0322/torch-comfyui:latest
```

使用镜像

`docker-compose.yml`:

```yaml
services:
  comfyui-gpu0:
    image: torch-comfyui:latest
    container_name: comfyui-gpu0
    runtime: nvidia
    hostname: comfyui-gpu0
    environment:
      - NVIDIA_VISIBLE_DEVICES=0
      - HOSTNAME=001
    volumes:
      - ./server:/workspace/server
      - ./flux2Comfyui:/workspace/flux2Comfyui
      - ./logs/comfyui-gpu0:/workspace/logs
      - ./server/conf/config/monitor.conf:/etc/supervisor/conf.d/monitor.conf
    shm_size: "16g"
    mem_limit: 80g
    cpuset: "4-18"
    command: [ "supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n" ]
    stdin_open: true
    tty: true
    restart: unless-stopped
```

## 测试是否可用

```
docker run --rm --runtime=nvidia nvidia/cuda:12.6.0-base-ubuntu22.04 nvidia-smi
```