#!/bin/bash
#SBATCH -J vllm_server
#SBATCH -p gh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 01:00:00

# Load modules and environment
# module load cuda/12.1
module load gcc cuda
source .venv/bin/activate

# Start vLLM server
export HOST=$(hostname)
export PORT=8000
export MODEL_NAME="ibm-granite/granite-4.0-h-350m"

vllm serve $MODEL_NAME --port $PORT --host 0.0.0.0 > vllm.log 2>&1 &
VLLM_PID=$!

# Wait vLLM serve for readiness
MAX_WAIT=300
SECONDS=0
until curl -s http://127.0.0.1:8000/v1/models > /dev/null; do
  if (( SECONDS > MAX_WAIT )); then
    echo "Timed out waiting for vLLM (check vllm.log)"
    kill $VLLM_PID
    exit 1
  fi
  echo "Waiting for vLLM to start... ($SECONDS sec)"
  sleep 15
done

echo "vLLM ready, running simulation..."
python simulate.py --policy_model gpt --num_agents 100 --episode_length 240
kill $VLLM_PID
