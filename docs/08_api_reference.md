# API Reference

Complete reference for the main APIs in the EconAgent framework.

## Environment Creation

### make_env_instance()

Creates an environment instance from configuration parameters.

**Location**: `ai_economist/foundation/__init__.py`

**Signature**:

```python
def make_env_instance(scenario_name, **kwargs) -> BaseEnvironment
```

**Parameters**:

- `scenario_name` (str): Name of the scenario ('one-step-economy', 'simple-wood-and-stone')
- `**kwargs`: Environment configuration parameters from config.yaml

**Returns**: Instance of BaseEnvironment subclass

**Example**:

```python
import ai_economist.foundation as foundation

env_config = {
    'n_agents': 100,
    'episode_length': 240,
    'scenario_name': 'one-step-economy',
    'components': [...]
}

env = foundation.make_env_instance(**env_config)
```

## BaseEnvironment Methods

Main simulation interface.

### reset()

Initializes the environment for a new episode.

**Signature**:

```python
def reset() -> dict
```

**Returns**: Initial observations dictionary

**Side effects**: Resets all agents, components, and world state

**Example**:

```python
obs = env.reset()
agent_0_obs = obs['p0']
```

### step(actions)

Executes one timestep of the simulation.

**Signature**:

```python
def step(actions: dict) -> tuple[dict, dict, dict, dict]
```

**Parameters**:

- `actions` (dict): Actions for each agent, keyed by agent ID

**Returns**: Tuple of (observations, rewards, dones, info)

- `observations` (dict): Next state observations
- `rewards` (dict): Rewards for each agent
- `dones` (dict): Whether each agent is done
- `info` (dict): Additional information

**Example**:

```python
actions = {'p': [0], 'p0': [1, 25], 'p1': [0, 30]}
obs, rew, done, info = env.step(actions)
```

### seed(seed)

Sets random seeds for reproducibility.

**Signature**:

```python
def seed(seed: int) -> None
```

**Parameters**:

- `seed` (int): Random seed value

**Example**:

```python
env.seed(42)
```

### get_agent(agent_id)

Retrieves a specific agent object.

**Signature**:

```python
def get_agent(agent_id: str) -> BaseAgent
```

**Parameters**:

- `agent_id` (str): Agent identifier (e.g., '0', 'p')

**Returns**: Agent object

**Example**:

```python
agent = env.get_agent('p0')
name = agent.endogenous['name']
wealth = agent.inventory['Coin']
```

## BaseAgent Methods

Individual agent interface.

### Getting Agent State

**Attributes**:

```python
agent._idx                      # Agent ID
agent.state                     # State dictionary
agent.inventory                 # Inventory dictionary
agent.endogenous               # Endogenous attributes
agent.income                   # Income tracking
agent.consumption              # Consumption tracking
```

**Example**:

```python
agent = env.get_agent('p0')
print(agent.endogenous['name'])        # "Michael Johnson"
print(agent.state['skill'])            # 5.2
print(agent.inventory['Coin'])         # 1000.5
```

## Component Interface

### BaseComponent Methods

All components implement this interface.

**Key methods**:

```python
def reset(env: BaseEnvironment) -> None
    # Initialize component for new episode

def get_obs(env: BaseEnvironment) -> dict
    # Return observations for all agents

def step(env: BaseEnvironment, action: dict) -> None
    # Process actions and update state
```

**Example usage** (within components):

```python
class MyComponent(BaseComponent):
    def get_obs(self, env):
        obs = {}
        for agent_idx in env.agents:
            agent = env.get_agent(agent_idx)
            obs[f'p{agent_idx}'] = {
                'MyComponent-value': agent.state['value']
            }
        return obs
    
    def step(self, env, action):
        for agent_id, agent_action in action.items():
            # Process action
            pass
```

## Simulation Functions (simulate.py)

### main()

Main simulation entry point.

**Signature**:

```python
def main(
    policy_model='gpt',
    num_agents=100,
    episode_length=240,
    dialog_len=3,
    beta=0.1,
    gamma=0.1,
    h=1,
    max_price_inflation=0.1,
    max_wage_inflation=0.05
) -> None
```

**Parameters**:

- `policy_model` (str): 'gpt' or 'complex'
- `num_agents` (int): Number of agents
- `episode_length` (int): Episode duration in months
- `dialog_len` (int): GPT dialog history length
- `beta` (float): Price sensitivity for complex agents
- `gamma` (float): Income elasticity for complex agents
- `h` (float): Habit parameter
- `max_price_inflation` (float): Maximum price change
- `max_wage_inflation` (float): Maximum wage change

**Example**:

```bash
python simulate.py --policy_model gpt --num_agents 100 --episode_length 240
python simulate.py --policy_model complex --num_agents 50 --episode_length 120 --beta 0.2 --gamma 0.15
```

### gpt_actions()

Generates actions using GPT-based decision making.

**Signature**:

```python
def gpt_actions(
    env: BaseEnvironment,
    obs: dict,
    dialog_queue: list,
    dialog4ref_queue: list,
    gpt_path: str,
    gpt_error: int,
    total_cost: float
) -> tuple[dict, int, float]
```

**Parameters**:

- `env`: Simulation environment
- `obs`: Current observations
- `dialog_queue`: Dialog history for each agent
- `dialog4ref_queue`: Extended dialog for reflection
- `gpt_path`: Path to save dialog logs
- `gpt_error`: Error counter
- `total_cost`: Accumulated API cost

**Returns**: (actions, updated_gpt_error, updated_total_cost)

**Internal functions**:

```python
def action_check(actions):
    # Validate action format
    return len(actions) == 2 and 0 <= actions[0] <= 1 and 0 <= actions[1] <= 1
```

### complex_actions()

Generates actions using economic models.

**Signature**:

```python
def complex_actions(
    env: BaseEnvironment,
    obs: dict,
    beta=0.1,
    gamma=0.1,
    h=1
) -> dict
```

**Returns**: Actions dictionary

**Internal functions**:

```python
def consumption_len(price, wealth, curr_income, last_income, interest_rate):
    # Price-based consumption model

def consumption_cats(price, wealth, curr_income, last_income, interest_rate):
    # Habit-based consumption model

def work_income_wealth(price, wealth, curr_income, last_income, expected_income, interest_rate):
    # Income-wealth work decision model
```

## Utility Functions (simulate_utils.py)

### get_completion()

Fetches a single LLM completion.

**Signature**:

```python
def get_completion(
    dialogs: list,
    temperature: int = 0,
    max_tokens: int = 100
) -> tuple[str, float]
```

**Parameters**:

- `dialogs` (list): Message history for API
- `temperature` (int): Randomness (0 = deterministic)
- `max_tokens` (int): Maximum output length

**Returns**: (response_text, api_cost)

**Example**:

```python
dialogs = [
    {'role': 'user', 'content': 'What is 2+2?'},
]
response, cost = get_completion(dialogs)
print(f"Cost: ${cost:.4f}")
```

### get_multiple_completion()

Fetches completions for multiple dialogs in parallel.

**Signature**:

```python
def get_multiple_completion(
    dialogs: list,
    num_cpus: int = 15,
    temperature: int = 0,
    max_tokens: int = 100
) -> tuple[list, float]
```

**Returns**: (responses, total_cost)

**Example**:

```python
all_dialogs = [dialog_queue[i] for i in range(num_agents)]
responses, cost = get_multiple_completion(all_dialogs)
```

### format_numbers()

Formats numbers for prompts.

**Signature**:

```python
def format_numbers(numbers: list) -> str
```

**Example**:

```python
brackets = [0, 100, 200]
formatted = format_numbers(brackets)  # "[0.00, 100.00, 200.00]"
```

### format_percentages()

Formats percentages for prompts.

**Signature**:

```python
def format_percentages(numbers: list) -> str
```

**Example**:

```python
rates = [0.12, 0.22, 0.24]
formatted = format_percentages(rates)  # "[12.00%, 22.00%, 24.00%]"
```

### prettify_document()

Removes excess whitespace from text.

**Signature**:

```python
def prettify_document(document: str) -> str
```

**Example**:

```python
text = "This  is   a    test"
clean = prettify_document(text)  # "This is a test"
```

## Registry Access

Registries contain available components, agents, scenarios, etc.

**Location**: `ai_economist/foundation/base/registrar.py`

**Available registries**:

```python
from ai_economist.foundation.components import component_registry
from ai_economist.foundation.agents import agent_registry
from ai_economist.foundation.scenarios import scenario_registry

# List available items
all_components = component_registry.list()
all_agents = agent_registry.list()

# Get specific item
labor_component = component_registry.get('SimpleLabor')
```

## Error Handling

### API Errors

GPT API errors are handled with retries:

```python
max_retries = 20
for i in range(max_retries):
    try:
        response = openai.ChatCompletion.create(...)
        # Success
        break
    except Exception as e:
        if i < max_retries - 1:
            time.sleep(6)  # Wait before retry
        else:
            print(f"Error: {type(e).__name__}: {e}")
            return "Error"
```

### Action Validation

Invalid actions default to [1, 0.5]:

```python
if not action_check(extracted_actions):
    extracted_actions = [1, 0.5]
    gpt_error += 1
```

### File I/O

Ensures directories exist before writing:

```python
if not os.path.exists(path):
    os.makedirs(path)
```

## Configuration Loading

### Load Configuration

```python
import yaml

with open('config.yaml', 'r') as f:
    run_configuration = yaml.safe_load(f)

env_config = run_configuration.get('env')
```

## State Persistence

### Save Checkpoint

```python
import pickle as pkl

with open(f'checkpoint_{step}.pkl', 'wb') as f:
    pkl.dump({
        'env': env,
        'obs': obs,
        'actions': actions,
        'dense_log': env.dense_log,
    }, f)
```

### Load Checkpoint

```python
with open(f'checkpoint_{step}.pkl', 'rb') as f:
    checkpoint = pkl.load(f)
    env = checkpoint['env']
```

