# Data Structures

This document describes the key data structures used throughout the EconAgent framework.

## World Object

The World object maintains global simulation state and is accessed through `env.world`.

Attributes:

- `timestep`: Current simulation timestep (integer, increments each step)
- `price`: List of prices across timesteps for consumption goods
- `interest_rate`: List of interest rates across timesteps
- `wage_multiplier`: Current wage inflation factor
- `world_size`: Dimensions of the world (usually [1, 1])

Access patterns:

```python
current_price = env.world.price[-1]              # Latest price
all_prices = env.world.price                     # Full history
current_rate = env.world.interest_rate[-1]       # Latest interest rate
timestep = env.world.timestep                    # Current step
```

## Agent State Dictionary

Each agent stores state as a nested dictionary in `agent.state`.

Structure:

```python
{
    'skill': float,              # Productivity level (1-10)
    'expected_skill': float,     # Expected future skill
}
```

Agent attributes:

```python
agent._idx                           # Unique identifier (string or int)
agent.inventory: dict                # What agent owns
agent.income: dict                   # Income by source
agent.endogenous: dict               # Permanent characteristics
agent.consumption: dict              # Consumption by category
```

Inventory example:

```python
agent.inventory = {
    'Coin': 1000.50,             # Money/currency
    'Good': 0,                   # Other resources
}
```

Endogenous attributes (person-specific):

```python
agent.endogenous = {
    'name': 'Michael Johnson',
    'age': 38,
    'city': 'New York',
    'job': 'Engineer',           # Current job title
    'offer': 'Manager',          # Job offer if unemployed
    'consumption_fun_idx': 0,    # For complex agents
    'work_fun_idx': 0,           # For complex agents
}
```

Income tracking:

```python
agent.income = {
    'Coin': 1000.00,             # Wage income
}
```

Consumption tracking:

```python
agent.consumption = {
    'Coin': 150.00,              # Consumption spending
}
```

## Observation Dictionary

Observations are returned as nested dictionaries mapping agents to their observations.

Structure:

```python
obs = {
    'p': {                                    # Planner (government) obs
        'PeriodicBracketTax-curr_rates': [...],
        'PeriodicBracketTax-brackets': [...],
    },
    'p0': {                                   # Agent 0 observations
        'SimpleLabor-wage_rate': 6.0,
        'SimpleLabor-hours_available': 168,
        'PeriodicBracketTax-tax_paid': 150.0,
        'PeriodicBracketTax-lump_sum': 100.0,
        'PeriodicBracketTax-curr_rates': [...],
        'SimpleConsumption-price': 1.5,
        'SimpleSaving-interest_rate': 0.025,
    },
    'p1': {                                   # Agent 1 observations
        # Same structure as p0
    },
}
```

Key structure:

- Top level: Maps agent IDs to their observations
- Agent observations: Maps component_name-parameter to value
- Format enables easy identification of observation source

Accessing observations:

```python
agent_0_obs = obs['p0']
wage_rate = obs['p0']['SimpleLabor-wage_rate']
current_tax_rates = obs['p']['PeriodicBracketTax-curr_rates']
```

## Action Dictionary

Actions specify what each agent decides at each timestep.

Structure:

```python
actions = {
    'p': [0],                  # Planner action (usually 0, no-op)
    'p0': [1, 25],             # Agent 0 actions
    'p1': [0, 30],             # Agent 1 actions
}
```

Action format:

- Each agent has list of action values
- Order depends on registered action subspaces
- For current setup: [work_decision, consumption_decision]

Typical values:

```python
actions['p0'] = [
    1,                         # work: 1 = work, 0 = don't work
    25,                        # consumption: 0-50 (0-1.0 in 0.02 steps)
]
```

For consumption conversion:

```python
consumption_fraction = consumption_action * 0.02  # 25 * 0.02 = 0.50
```

## Reward Dictionary

Rewards returned from env.step() is a dictionary mapping agents to scalar rewards.

Structure:

```python
rewards = {
    'p': 0.5,
    'p0': 1.2,
    'p1': 0.8,
}
```

Reward computation:

- Individual agent rewards: Based on consumption minus labor cost
- Planner rewards: Based on equality and productivity
- Higher rewards encourage desirable behaviors

Reward types configured in config.yaml:

```yaml
agent_reward_type: isoelastic_coin_minus_labor
planner_reward_type: inv_income_weighted_utility
```

## Done Flags

The done flag indicates episode termination.

Structure:

```python
done = {
    '__all__': False,  # Overall episode done
    'p': False,
    'p0': False,
    'p1': False,
}
```

When `done['__all__']` becomes True, the episode ends and env.reset() should be called.

## Info Dictionary

Additional information returned with each step.

Structure:

```python
info = {
    'episode': {
        'r': 1250.5,          # Episode reward
        'l': 240,             # Episode length
    },
    'agent_metrics': {
        'p0': {
            'income': 2400.0,
            'consumption': 1800.0,
            'wealth': 5000.0,
        },
    },
}
```

Contains useful debugging and analysis information.

## Dialog History (GPT Agents)

Stored in `dialog_queue` during GPT simulations.

Structure:

```python
dialog_queue = [
    [                                  # Agent 0 dialog
        {
            'role': 'user',
            'content': 'observation prompt...'
        },
        {
            'role': 'assistant',
            'content': '{"work": 1, "consumption": 0.5}'
        },
    ],
    # ... more agents
]
```

Format:

- List of dialogs, one per agent
- Each dialog is a list of message dictionaries
- Messages have 'role' (user/assistant) and 'content'
- Follows OpenAI API format
- Limited to recent N turns (default 3)

Extended dialog for reflection:

```python
dialog4ref_queue[agent_id]  # Length 7 for quarterly reflection
```

## Dense Log

The environment maintains a dense log of all interactions.

Stored in: `env.dense_log`

Structure:

```python
env.dense_log = {
    'obs': [obs_t0, obs_t1, ...],      # Observations at each timestep
    'actions': [actions_t0, ...],      # Actions at each timestep
    'states': [states_t0, ...],        # Agent states at each timestep
    'rewards': [rewards_t0, ...],      # Rewards at each timestep
    'dones': [dones_t0, ...],          # Done flags
}
```

Access patterns:

```python
all_observations = env.dense_log['obs']
action_at_step_5 = env.dense_log['actions'][5]
state_history = env.dense_log['states']
```

## Tax Brackets

Tax brackets stored as lists of income thresholds and rates.

Structure:

```python
brackets = [
    0.00,           # Start of bracket 1
    812.50,         # Start of bracket 2
    3289.25,        # Start of bracket 3
    # ...
]

rates = [
    0.00,           # Rate for bracket 1
    0.12,           # Rate for bracket 2
    0.22,           # Rate for bracket 3
    # ...
]
```

Tax calculation:

```python
income = 5000
tax = 0
for i in range(len(brackets)-1):
    bracket_income = min(income, brackets[i+1]) - brackets[i]
    tax += bracket_income * rates[i]
```

## Component Configuration

Components stored in dictionaries with their parameters.

Structure:

```python
component_config = {
    'SimpleLabor': {
        'num_labor_hours': 168,
        'pareto_param': 8,
        'payment_max_skill_multiplier': 950,
    },
    'PeriodicBracketTax': {
        'tax_model': 'us-federal-single-filer-2018-scaled',
        'period': 1,
    },
}
```

Accessed in code:

```python
labor_component = env._components_dict['SimpleLabor']
num_hours = labor_component.num_labor_hours
```

## Agent Profiles

Agent demographics loaded from data/profiles.json.

Structure:

```json
{
    "Name": ["Michael Johnson", "Emily Smith", ...],
    "Age": [38, 22, ...],
    "City": ["New York", "LA", ...],
    "0-2454": [
        "Intern",
        "Student Assistant",
        ...
    ]
}
```

Loaded and assigned to agents at initialization.

## Policy Model Parameters

Parameters specific to different policy models.

GPT parameters:

```python
policy_model = 'gpt'
dialog_len = 3              # Dialog history length
temperature = 0             # Deterministic output
max_tokens = 100            # Max response length
```

Complex model parameters:

```python
policy_model = 'complex'
beta = 0.1                  # Price sensitivity
gamma = 0.1                 # Income elasticity
h = 1                       # Habit parameter
```

## Serialization Formats

All data structures serializable to pickle for checkpointing:

```python
import pickle
with open('checkpoint.pkl', 'wb') as f:
    pickle.dump({
        'obs': obs,
        'actions': actions,
        'env': env,
    }, f)
```

This allows resuming simulations from checkpoints.

