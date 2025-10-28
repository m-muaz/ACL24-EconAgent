# Simulation Engine

## Overview

The simulation engine is the core runtime that orchestrates the economic simulation. It manages the flow of information between agents, components, and the environment.

## Main Simulation Loop

Located in: `simulate.py`

The main function contains the simulation loop that executes for each episode:

```python
for epi in range(env.episode_length):
    # Get actions from agents
    if policy_model == 'gpt':
        actions, gpt_error, total_cost = gpt_actions(
            env, obs, dialog_queue, dialog4ref_queue,
            gpt_path, gpt_error, total_cost
        )
    elif policy_model == 'complex':
        actions = complex_actions(env, obs, beta=beta, gamma=gamma, h=h)
    
    # Execute one timestep
    obs, rew, done, info = env.step(actions)
    
    # Periodic logging
    if (epi+1) % 6 == 0 or epi+1 == env.episode_length:
        # Save checkpoints
```

## Timestep Execution

Each `env.step(actions)` call performs:

1. **Action Processing**: Each component processes relevant actions
2. **State Update**: Agent states and world state updated
3. **Observation Generation**: New observations generated for next step
4. **Reward Calculation**: Rewards computed for all agents
5. **Logging**: State and transitions logged

## Data Collection

The simulator collects comprehensive data at each timestep:

### Observations (obs)

Stored in: `env.dense_log['obs']`

Contains full observation history for all agents across all timesteps.

### Actions (actions)

Stored in: `env.dense_log['actions']`

Tracks what each agent decided at each timestep.

### States (states)

Stored in: `env.dense_log['states']`

Maintains historical state snapshots.

### Checkpoints

Saved periodically to disk:

- `actions_{timestep}.pkl`: Action snapshots
- `obs_{timestep}.pkl`: Observation snapshots  
- `env_{timestep}.pkl`: Full environment state
- `dialog_{timestep}.pkl`: Dialog history (GPT only)
- `dense_log_{timestep}.pkl`: Logging data

## GPT Agent Decision Making

Function: `gpt_actions()`

### Process

1. **Observation Compilation**: For each agent, gather current economic state

2. **Prompt Generation**: Create natural language prompt containing:
   - Agent identity (name, age, city, job)
   - Employment status and income
   - Consumption history
   - Tax information and brackets
   - Price information
   - Interest rates
   - Current savings

3. **Prompt Example**:

```
You're Michael Johnson, a 38-year-old individual living in New York.
As with all Americans, a portion of your monthly income is taxed...

In the previous month, you worked as an Engineer. If you continue working
this month, your expected income will be $5,040.00...

Your current savings account balance is $12,345.67.
Interest rates stand at 2.5%.

How is your willingness to work this month? How would you plan your 
expenditures on essential goods?

Please share your decisions in a JSON format with 'work' and 'consumption' keys.
```

4. **LLM Call**: Send to OpenAI API (GPT-3.5-turbo or GPT-4o-mini)

5. **Response Parsing**: Extract JSON actions from response

6. **Validation**: Check if actions are in valid ranges:
   - work: 0 or 1 (binary decision)
   - consumption: 0-50 (represents 0-1.0 in 0.02 increments)

7. **Error Handling**: If parsing fails, default to [1, 0.5]
   - Work = 1 (work)
   - Consumption = 0.5 (spend 50% of wealth)

### Dialog Management

Maintains conversation history for each agent:

- `dialog_queue`: Current dialog with length limit (default 3 turns)
- `dialog4ref_queue`: Extended dialog for reflection (length 7 turns)

At every 3rd timestep, agents provide quarterly reflection on market conditions.

### Cost Tracking

Tracks API costs:
- `prompt_cost_1k = 0.001` (per 1k tokens)
- `completion_cost_1k = 0.002` (per 1k tokens)

Total cost accumulated and reported.

### Error Tracking

`gpt_error` counter tracks:
- Failed JSON parsing
- Invalid action ranges
- API errors

High error rate indicates need to adjust prompts.

## Complex Agent Decision Making

Function: `complex_actions()`

### Purpose

Provides a baseline behavioral model using traditional economic theory.

### Decision Models

#### Consumption Decision

Uses consumption function:

```python
def consumption_len(price, wealth, curr_income, last_income, interest_rate):
    c = (price / (1e-8 + wealth + curr_income)) ** beta
    c = min(max(c // 0.02, 0), 50)
    return c
```

Parameters:
- `beta`: Price sensitivity (default: 0.1)
- Agents who face high prices relative to wealth consume less

Alternative model:

```python
def consumption_cats(price, wealth, curr_income, last_income, interest_rate):
    h1 = h / (1 + interest_rate)
    g = curr_income / (last_income + 1e-8) - 1
    d = wealth / (last_income + 1e-8) - h1
    c = 1 + (d - h1*g) / (1 + g + 1e-8)
```

Based on habit formation and buffer stock models.

#### Work Decision

```python
def work_income_wealth(price, wealth, curr_income, last_income, expected_income, interest_rate):
    return int(np.random.uniform() < (curr_income / (wealth * (1 + interest_rate) + 1e-8)) ** gamma)
```

Parameters:
- `gamma`: Income elasticity (default: 0.1)
- Agents with low income relative to wealth more likely to work
- Stochastic decision (random element added)

### Agent Heterogeneity

Each agent randomly assigned:
- Consumption function type (consumption_len or consumption_cats)
- Work function type

Stored in agent endogenous attributes for consistency across episodes.

## Configuration Parameters

Key parameters in `config.yaml`:

```yaml
env:
  n_agents: 100                    # Number of agents
  episode_length: 240              # Months to simulate
  enable_skill_change: true        # Allow skill evolution
  enable_price_change: true        # Allow market price changes
  skill_change: 0.02               # Skill volatility
  price_change: 0.02               # Price volatility
  interest_rate: 0.025             # Base interest rate
```

## Performance Metrics

The simulator tracks:

### Individual Metrics

- **Gini Coefficient**: Income/wealth inequality
- **Agent Utility**: Individual consumption and work satisfaction
- **Income Distribution**: Distribution across agents

### Market Metrics

- **Price History**: Inflation/deflation over time
- **Wage Evolution**: Skill and wage changes
- **Tax Revenue**: Total taxes collected
- **Redistribution Amount**: Total lump sum transfers

### Macro Metrics

- **Total Productivity**: Sum of all work
- **Total Consumption**: Market consumption
- **Inequality**: Wealth distribution
- **Social Welfare**: Aggregate well-being

## Scaling Considerations

### Memory Usage

- Each agent stores: state, inventory, income, observations
- Scales linearly with agent count
- Storage grows with episode length

### Computation Time

- **Label Computation**: Linear with agent count and components
- **GPT API**: Depends on model, throttled by API rate limits
- **Complex Model**: Very fast, O(n) complexity

### Optimization Strategies

1. **Batch Processing**: Group GPT requests (already implemented)
2. **Multiprocessing**: Parallel API calls with multiprocessing pool
3. **Checkpointing**: Save intermediate states to manage memory
4. **Filtering**: Only compute needed observations

## Output Files Structure

```
data/
  {policy_model}-{params}-{num_agents}agents-{episode_length}months/
    dialogs/
      {agent_name}         # Agent conversation logs
    actions_{timestep}.pkl
    obs_{timestep}.pkl
    env_{timestep}.pkl
    dialog_{timestep}.pkl
    dense_log_{timestep}.pkl
    dense_log.pkl         # Final complete log
```

## Debugging and Monitoring

### Log Files

For GPT agents, individual dialogs saved to `dialogs/{agent_name}`:

```
>>>>>>>>>user: [observation prompt]
>>>>>>>>>assistant: {"work": 1, "consumption": 0.5}
```

Useful for debugging agent decisions.

### Error Monitoring

Track `gpt_error` counter and `total_cost`:

```python
if policy_model == 'gpt':
    print(f'#gpt errors: {gpt_error}')
```

High errors indicate:
- Need to adjust prompt format
- Model not following JSON instructions
- Invalid response format

### Performance Monitoring

Print timing information:

```python
if (epi+1) % 3 == 0:
    print(f'step {epi+1} done, cost {time()-t:.1f}s')
```

Helps identify bottlenecks and estimate completion time.

