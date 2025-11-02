# EconAgent: Large Language Model-Empowered Agents for Simulating Macroeconomic Activities
Official implementation of this ACL 2024 paper.

It's based on [Foundation](https://github.com/MaciejMacko/ai-economist), An Economic Simulation Framework, which is announced by this paper: 

Zheng, Stephan, et al. "The ai economist: Improving equality and productivity with ai-driven tax policies." arXiv preprint arXiv:2004.13332 (2020).

# Run
Simulate with GPT-3.5, 100 agents, and 240 months (fill openai.api_key in simulate_utils.py): 

`python simulate.py --policy_model gpt --num_agents 100 --episode_length 240`

Simulate with Composite, 100 agents, and 240 months:

`python simulate.py --policy_model complex --num_agents 100 --episode_length 240`

For RL approaches, *i.e.*, **The ai economist**, we just follow their training codes and use the trained models for simulations. See appendix in the paper for details.

# Update in 2024.8.16
The simulation was only tested using gpt-3.5-turbo-0613, but this model seems to no longer be accessible and has been replaced by gpt-4o-mini. If `gpt_error` is significantly greater than 0 (e.g., exceeding 10), meaning GPT generates many unreasonable decisions, please adjust the prompts accordingly, especially the parts related to format instruction:

*"Please share your decisions in a JSON format. The format should have two keys: 'work' (a value between 0 and 1 with intervals of 0.02, indicating the willingness or propensity to work) and 'consumption' (a value between 0 and 1 with intervals of 0.02, indicating the proportion of all your savings and income you intend to spend on essential goods)."*

# Install uv
Install [uv](https://docs.astral.sh/uv/) by:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

# Two ways to run the simulation
## Execute in uv venv environment
```bash
export MODEL_NAME="google/gemma-3-270m" # Choose a model from HuggingFace
vllm serve $MODEL_NAME --port 8000 --host 0.0.0.0 > vllm.log 2>&1 & # Serve model in the background
uv run python simulate.py --policy_model gpt --num_agents 100 --episode_length 240
```

## Script for Running on HPC cluster
You can use the following command to run the simulation on TACC or other HPC cluster.
```bash
sbatch run-vllm-serve.sh
```
