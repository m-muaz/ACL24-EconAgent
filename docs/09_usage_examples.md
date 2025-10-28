# Usage Examples

This document provides practical examples for using the EconAgent framework.

## Basic Setup

### Installation

```bash
cd ACL24-EconAgent
pip install -r requirements.txt
```

Configure your OpenAI API key in `simulate_utils.py`:

```python
openai.api_key = 'your-api-key-here'
```

### Running Your First Simulation

Simple simulation with 10 agents for 12 months:

```bash
python simulate.py --policy_model complex --num_agents 10 --episode_length 12
```

This runs quickly without requiring API access.

Output saved to: `data/complex-0.1-0.1-1-0.1-0.05-10agents-12months/`

## Example 1: GPT-Based Economic Simulation

Run agents with LLM-based decision making:

```bash
python simulate.py \
    --policy_model gpt \
    --num_agents 50 \
    --episode_length 120 \
    --dialog_len 3
```

Parameters:

- `policy_model gpt`: Use GPT-3.5 or GPT-4o-mini for decisions
- `num_agents 50`: Simulate 50 individual agents
- `episode_length 120`: Run for 120 months (10 years)
- `dialog_len 3`: Keep last 3 turns in dialog history

Expected output:

```
step 3 done, cost 2.3s
#errors: 0, cost $1.23 so far
step 6 done, cost 2.4s
#errors: 0, cost $3.45 so far
...
#gpt errors: 0
```

Results contain:

- Individual agent dialogs in `dialogs/` folder
- Action decisions at each timestep
- Environment states
- Dense logs with full trajectory

### Analyzing GPT Agent Decisions

Read agent conversation logs:

```bash
cat data/gpt-3-noperception-reflection-1-50agents-120months/dialogs/"Michael Johnson"
```

Output shows decision reasoning:

```
>>>>>>>>>user: You're Michael Johnson, a 38-year-old...
>>>>>>>>>assistant: {"work": 1, "consumption": 0.5}
```

Track API costs:

```python
# In simulate.py after simulation completes
print(f'Total API cost: ${total_cost:.2f}')
print(f'Errors: {gpt_error}')
```

## Example 2: Complex Agent Baseline

Run with traditional economic models (fast):

```bash
python simulate.py \
    --policy_model complex \
    --num_agents 100 \
    --episode_length 240 \
    --beta 0.2 \
    --gamma 0.15
```

Parameters:

- `beta 0.2`: Agents are 2x more price-sensitive
- `gamma 0.15`: Agents more income-elastic

Advantages:

- No API calls (free and fast)
- Reproducible results
- Good for testing configurations

## Example 3: Taxation Policy Experiment

Study impact of different tax systems:

### Scenario A: Progressive Taxation (Default)

Uses default US federal tax brackets.

```bash
python simulate.py --policy_model complex --num_agents 100 --episode_length 240
```

### Scenario B: Flat Tax

Modify `config.yaml`:

```yaml
env:
  components:
    - PeriodicBracketTax:
        tax_model: flat-rate
        flat_rate: 0.15
```

### Scenario C: No Redistribution

```yaml
    - PeriodicBracketTax:
        disable_taxes: true
```

Compare outcomes:

```python
# Load results from each scenario
import pickle as pkl

scenarios = ['progressive', 'flat', 'no_tax']
results = {}

for scenario in scenarios:
    with open(f'data/{scenario}/dense_log.pkl', 'rb') as f:
        results[scenario] = pkl.load(f)

# Analyze Gini coefficient
for scenario, log in results.items():
    gini = calculate_gini(log)
    print(f"{scenario}: Gini = {gini:.3f}")
```

## Example 4: Scaling Analysis

Study how results change with population size:

```bash
for agents in 10 50 100 200 500; do
    python simulate.py \
        --policy_model complex \
        --num_agents $agents \
        --episode_length 60
done
```

Compare results across population sizes:

```python
import os
import pickle as pkl

for agents in [10, 50, 100, 200, 500]:
    folder = f'data/complex-0.1-0.1-1-0.1-0.05-{agents}agents-60months'
    with open(f'{folder}/dense_log.pkl', 'rb') as f:
        log = pkl.load(f)
    
    final_wealth = get_final_wealth(log)
    inequality = calculate_gini(final_wealth)
    print(f"N={agents}: Gini={inequality:.3f}")
```

## Example 5: Market Volatility Study

Test how economic volatility affects behavior:

```bash
# Low volatility scenario
python simulate.py \
    --policy_model complex \
    --num_agents 100 \
    --episode_length 240 \
    --max_price_inflation 0.02 \
    --max_wage_inflation 0.01

# High volatility scenario
python simulate.py \
    --policy_model complex \
    --num_agents 100 \
    --episode_length 240 \
    --max_price_inflation 0.2 \
    --max_wage_inflation 0.15
```

Compare outcomes:

- Do agents work more or less?
- How does consumption change?
- What happens to wealth distribution?

## Example 6: Custom Data Analysis

### Loading Results

```python
import pickle as pkl
import numpy as np

# Load simulation data
with open('data/myrun/dense_log.pkl', 'rb') as f:
    dense_log = pkl.load(f)

observations = dense_log['obs']        # List of obs per timestep
actions = dense_log['actions']         # List of actions per timestep
```

### Extracting Metrics

```python
def extract_agent_outcomes(env, dense_log, agent_id):
    """Extract economic outcomes for an agent"""
    
    agent_actions = [
        actions[agent_id] for actions in dense_log['actions']
    ]
    
    work_decisions = [a[0] for a in agent_actions]
    consumption_decisions = [a[1] * 0.02 for a in agent_actions]
    
    return {
        'total_work': sum(work_decisions),
        'work_rate': np.mean(work_decisions),
        'avg_consumption': np.mean(consumption_decisions),
        'consumption_std': np.std(consumption_decisions),
    }

# Analyze each agent
for agent_id in ['p0', 'p1', 'p2']:
    metrics = extract_agent_outcomes(env, dense_log, agent_id)
    print(f"Agent {agent_id}: {metrics}")
```

### Computing Inequality

```python
def compute_gini(wealth_array):
    """Compute Gini coefficient"""
    sorted_wealth = np.sort(wealth_array)
    n = len(wealth_array)
    index = np.arange(1, n + 1)
    return (2 * np.sum(index * sorted_wealth)) / (n * np.sum(sorted_wealth)) - (n + 1) / n

# Get final wealth distribution
final_obs = dense_log['obs'][-1]
final_wealth = []
for agent_id in range(num_agents):
    wealth = final_obs[f'p{agent_id}'].get('wealth', 0)
    final_wealth.append(wealth)

gini = compute_gini(np.array(final_wealth))
print(f"Final Gini coefficient: {gini:.3f}")
```

## Example 7: Comparing Agent Models

Side-by-side comparison of GPT vs Complex agents:

```python
import subprocess
import pickle as pkl

# Run both simulations
subprocess.run([
    'python', 'simulate.py',
    '--policy_model', 'gpt',
    '--num_agents', '50',
    '--episode_length', '120'
])

subprocess.run([
    'python', 'simulate.py',
    '--policy_model', 'complex',
    '--num_agents', '50',
    '--episode_length', '120'
])

# Load results
with open('data/gpt-3-noperception-reflection-1-50agents-120months/dense_log.pkl', 'rb') as f:
    gpt_log = pkl.load(f)

with open('data/complex-0.1-0.1-1-0.1-0.05-50agents-120months/dense_log.pkl', 'rb') as f:
    complex_log = pkl.load(f)

# Compare work patterns
gpt_work = mean_work_rate(gpt_log)
complex_work = mean_work_rate(complex_log)

print(f"GPT average work rate: {gpt_work:.2%}")
print(f"Complex average work rate: {complex_work:.2%}")
```

## Example 8: Visualizing Results

### Plot Price Evolution

```python
import matplotlib.pyplot as plt

def plot_price_evolution(dense_log):
    """Plot price over time"""
    # Extract prices from observations
    prices = []
    for obs_t in dense_log['obs']:
        if 'p0' in obs_t and 'SimpleConsumption-price' in obs_t['p0']:
            prices.append(obs_t['p0']['SimpleConsumption-price'])
    
    plt.figure(figsize=(12, 6))
    plt.plot(prices)
    plt.xlabel('Month')
    plt.ylabel('Price')
    plt.title('Market Price Evolution')
    plt.grid(True)
    plt.savefig('price_evolution.png')
    plt.close()
```

### Plot Income Distribution

```python
def plot_income_distribution(env, dense_log):
    """Plot income distribution over time"""
    
    # Extract final incomes
    final_obs = dense_log['obs'][-1]
    incomes = []
    
    for agent_id in range(env.num_agents):
        # Calculate agent income from actions and environment
        wealth = env.get_agent(f'p{agent_id}').inventory['Coin']
        incomes.append(wealth)
    
    plt.figure(figsize=(10, 6))
    plt.hist(incomes, bins=20, edgecolor='black')
    plt.xlabel('Final Wealth')
    plt.ylabel('Number of Agents')
    plt.title('Wealth Distribution')
    plt.savefig('wealth_distribution.png')
    plt.close()
```

## Example 9: Running Batch Experiments

Run multiple configurations systematically:

```bash
#!/bin/bash

# Test different agent populations
for n_agents in 10 20 50 100 200; do
    # Test different policies
    for policy in gpt complex; do
        echo "Running: agents=$n_agents, policy=$policy"
        python simulate.py \
            --policy_model $policy \
            --num_agents $n_agents \
            --episode_length 240
    done
done
```

Analyze results:

```python
import os
import pickle as pkl

results = {}

for root, dirs, files in os.walk('data'):
    if 'dense_log.pkl' in files:
        with open(os.path.join(root, 'dense_log.pkl'), 'rb') as f:
            log = pkl.load(f)
        
        # Extract configuration from folder name
        config = parse_config_from_folder(root)
        results[tuple(config)] = log

# Analyze all results
for config, log in results.items():
    print(f"{config}: {analyze(log)}")
```

## Example 10: Debugging Agent Decisions

Trace a single agent's decisions through time:

```python
import pickle as pkl

with open('data/gpt-3-noperception-reflection-1-50agents-240months/dialog_240.pkl', 'rb') as f:
    dialog_queue = pkl.load(f)

# Look at agent 0's dialog history
agent_0_dialog = dialog_queue[0]

print(f"Agent 0 dialog has {len(agent_0_dialog)} turns")

for i, message in enumerate(agent_0_dialog):
    print(f"\n--- Turn {i} ---")
    print(f"Role: {message['role']}")
    print(f"Content: {message['content'][:200]}...")  # First 200 chars
```

## Tips and Best Practices

### Performance

- Start with `episode_length=12` for quick testing
- Use `policy_model=complex` for rapid development
- Scale up `num_agents` gradually
- Monitor `time.time()` to track simulation speed

### Cost Management (GPT)

- Use `dialog_len=3` (default) not higher
- Test prompts with small `num_agents` first
- Track `total_cost` to manage API spending
- Consider using GPT-4o-mini instead of GPT-3.5-turbo for cost savings

### Reproducibility

- Always set a random seed
- Save configuration with results
- Version control your code
- Document parameter choices

### Debugging

- Print `obs` to understand agent information
- Check `gpt_error` count for prompt issues
- Review individual agent dialogs
- Use small `episode_length` for testing

