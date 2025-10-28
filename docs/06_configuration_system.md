# Configuration System

This document explains how to configure the EconAgent simulation framework.

## Configuration File Structure

The main configuration file is `config.yaml`. It contains all parameters needed to define the simulation environment, agents, components, and training setup.

## Top-Level Sections

The configuration is organized into five main sections:

1. **agent_policy**: Controls individual agent decision-making (for RL-based approaches)
2. **env**: Environment and component configuration
3. **general**: Global settings like training episodes
4. **planner_policy**: Central planner configuration (for RL-based approaches)
5. **trainer**: Ray trainer configuration (for distributed RL training)

## Environment Configuration (env)

### Basic Parameters

```yaml
env:
  n_agents: 100              # Number of individual agents
  episode_length: 240        # Number of months to simulate
  period: 12                 # Months per year (affects tax calculation)
  world_size: [1, 1]         # Spatial dimensions (typically 1x1 for one-step economy)
```

### Agent Reward Type

```yaml
  agent_reward_type: isoelastic_coin_minus_labor
```

Options:
- `coin`: Reward based on consumption
- `isoelastic_coin_minus_labor`: Emphasizes equality while penalizing work
- `inv_income_weighted_utility`: Inverse income weighting

### Planner Reward Type

```yaml
  planner_reward_type: inv_income_weighted_utility
```

The planner (government) reward function. Different from agent rewards.

### Dynamic Features

```yaml
  enable_skill_change: true      # Agents' skills change over time
  enable_price_change: true      # Market prices fluctuate
  skill_change: 0.02             # Skill volatility (2% per period)
  price_change: 0.02             # Price volatility (2% per period)
  skill_change_smoothing: 5      # Smoothing parameter for skill evolution
```

### Economic Parameters

```yaml
  isoelastic_etas: [0.5, 0.5]    # Inequality aversion coefficients
  labor_exponent: 2               # Labor cost exponent
  labor_cost: 1                   # Base labor cost
  mixing_weight_gini_vs_coin: 0   # Weight between equality and consumption
```

### Masks and Observations

```yaml
  flatten_masks: true             # Flatten action masks to vectors
  flatten_observations: true      # Flatten observations to vectors
```

When false, observations/actions are structured dictionaries (needed for GPT).

### Logging

```yaml
  dense_log_frequency: 1          # Log every N timesteps
```

## Components Configuration

Components are specified as a list with their parameters:

```yaml
env:
  components:
    - ComponentName:
        parameter1: value1
        parameter2: value2
```

### SimpleLabor Component

```yaml
    - SimpleLabor:
        mask_first_step: false
        pareto_param: 8
        payment_max_skill_multiplier: 950
        labor_step: 168
        num_labor_hours: 168
        scale_obs: true
```

Parameters:
- `pareto_param`: Shape parameter for Pareto skill distribution (higher = less inequality)
- `payment_max_skill_multiplier`: Maximum wage relative to minimum
- `labor_step`: Duration of labor period in timesteps
- `num_labor_hours`: Maximum work hours per period
- `scale_obs`: Whether to scale observations to [-1, 1]

### PeriodicBracketTax Component

```yaml
    - PeriodicBracketTax:
        bracket_spacing: us-federal
        disable_taxes: false
        period: 1
        tax_model: us-federal-single-filer-2018-scaled
        usd_scaling: 12
        scale_obs: true
```

Parameters:
- `bracket_spacing`: Tax bracket configuration
  - `us-federal`: Standard US brackets
- `tax_model`: Tax formula
  - `us-federal-single-filer-2018-scaled`: Standard 2018 brackets scaled
  - `saez`: Saez optimal tax theory
- `period`: How often tax is recalculated (1 = every month)
- `usd_scaling`: Scaling factor (12 = annualized amounts converted to monthly)
- `disable_taxes`: Set to true to disable taxation

### SimpleConsumption Component

```yaml
    - SimpleConsumption:
        mask_first_step: false
        consumption_rate_step: 0.02
        max_price_inflation: 0.1
        max_wage_inflation: 0.05
```

Parameters:
- `consumption_rate_step`: Granularity of consumption choices (0.02 = 2% steps, 0-1)
- `max_price_inflation`: Maximum monthly price change (0.1 = 10%)
- `max_wage_inflation`: Maximum monthly wage change (0.05 = 5%)

### SimpleSaving Component

```yaml
    - SimpleSaving:
        mask_first_step: false
        scale_obs: true
        saving_rate: 0.00
```

Parameters:
- `saving_rate`: Interest rate on savings (0.0 = no interest)

## Scenario Configuration

```yaml
env:
  scenario_name: one-step-economy
```

Available scenarios:
- `one-step-economy`: Main scenario with labor, tax, consumption, saving
- `simple-wood-and-stone`: Alternative resource-based scenario

## General Configuration

```yaml
general:
  ckpt_frequency_steps: 500000    # Save checkpoint every N training steps
  cpus: 25                         # Number of CPU cores available
  episodes: 100000                 # Number of training episodes
  gpus: 4                          # Number of GPUs available
  train_planner: false             # Whether to train planner (false = use random policy)
```

## Agent Policy Configuration (RL-based)

```yaml
agent_policy:
  clip_param: 0.3                  # PPO clip parameter
  entropy_coeff: 0.2               # Entropy bonus coefficient
  gamma: 1.0                       # Discount factor
  lr: 0.0001                       # Learning rate
  model:
    custom_model: keras_linear     # Neural network architecture
    custom_options:
      logit_hiddens: [256, 256]   # Hidden layers for policy
      value_hiddens: [256, 128, 64] # Hidden layers for value function
```

These are used only for RL-based training, not for GPT or complex agent simulations.

## Planner Policy Configuration

Similar to agent_policy but for the central planner:

```yaml
planner_policy:
  clip_param: 0.3
  entropy_coeff: 0.025
  gamma: 0.998                     # Slightly lower discount
  lr: 0.0003
```

## Trainer Configuration

```yaml
trainer:
  num_workers: 20                  # Number of parallel workers
  num_envs_per_worker: 10          # Environments per worker
  batch_mode: truncate_episodes    # How to batch episodes
  train_batch_size: 10000          # Total training batch size
```

These are advanced parameters for distributed RL training.

## Modifying Configuration for Experiments

### Experiment 1: Test Policy Sensitivity

Change tax brackets/rates while keeping everything else fixed:

```yaml
  - PeriodicBracketTax:
      tax_model: us-federal-single-filer-2018-scaled  # Change rates
```

### Experiment 2: Vary Agent Population

Change number of agents:

```yaml
env:
  n_agents: 50  # or 200, 500, etc.
```

### Experiment 3: Adjust Economic Volatility

Change skill and price dynamics:

```yaml
  skill_change: 0.05      # More volatility
  price_change: 0.05
```

### Experiment 4: Test Interest Rates

Change saving rates to simulate monetary policy:

```yaml
    - SimpleSaving:
        saving_rate: 0.05   # 5% interest
```

### Experiment 5: Disable Redistribution

Set tax model to no redistribution:

```yaml
    - PeriodicBracketTax:
        disable_taxes: true
```

## Configuration for GPT Simulation

When running GPT-based simulations with `simulate.py`:

Essential settings:
- `flatten_masks: false`
- `flatten_observations: false`
- Component `scale_obs: false`

These preserve the structured format needed for GPT processing.

Example configuration section:

```yaml
env:
  flatten_masks: false
  flatten_observations: false
  components:
    - SimpleLabor:
        scale_obs: false
    - PeriodicBracketTax:
        scale_obs: false
    - SimpleConsumption:
        ...
    - SimpleSaving:
        scale_obs: false
```

## Configuration for Complex Agent Simulation

Complex agents can work with flattened observations:

Can use either:
- Structured format (slower, more readable)
- Flattened format (faster, for traditional RL)

## Command-Line Parameter Override

The `simulate.py` script accepts parameters that override config.yaml:

```bash
python simulate.py \
    --policy_model gpt \
    --num_agents 100 \
    --episode_length 240
```

These override corresponding config.yaml values for convenience.

## Configuration Validation

When creating custom configurations:

1. Ensure all required fields are present
2. Check parameter ranges are sensible
3. Verify component order (may affect results)
4. Test with small episode_length first
5. Monitor for runtime errors

## Performance Tuning

To optimize simulation performance:

1. Reduce `dense_log_frequency` for faster runs (logs every N steps instead of 1)
2. Reduce `num_agents` for testing
3. Reduce `episode_length` for quick experiments
4. Set `scale_obs: true` for RL training (faster)
5. Disable unused components

## Distributed Training Configuration

For Ray-based distributed training:

```yaml
general:
  cpus: 48
  gpus: 8

trainer:
  num_workers: 40
  num_envs_per_worker: 1
```

Adjust based on your hardware resources.

## Example: Minimal Configuration

Smallest working configuration for testing:

```yaml
env:
  n_agents: 10
  episode_length: 12
  scenario_name: one-step-economy
  components:
    - SimpleLabor:
        num_labor_hours: 168
    - PeriodicBracketTax:
        tax_model: us-federal-single-filer-2018-scaled
    - SimpleConsumption:
        consumption_rate_step: 0.02
    - SimpleSaving:
        saving_rate: 0.0

general:
  episodes: 1
```

This runs a simple 12-month simulation with 10 agents.

