# Core Components Reference

This document details the main economic components that drive the simulation.

## SimpleLabor Component

**File**: `ai_economist/foundation/components/simple_labor.py`

### Purpose

Simulates the labor market where agents decide whether to work and receive income based on their skill level.

### Key Parameters

- `num_labor_hours`: Maximum hours available for work per period (default: 168 hours/month)
- `labor_step`: Duration of one labor period
- `pareto_param`: Parameter for skill distribution (Pareto distribution)
- `payment_max_skill_multiplier`: Maximum wage multiplier based on skill

### How It Works

1. Each agent has a skill level that determines wage rate
2. Agents decide how many labor hours to work (0 to max)
3. Income = hours_worked × skill_level × wage_rate
4. Skill evolves based on market conditions

### Agent Decision

Agents must decide: **Work effort** (0 to 1, represents willingness to work)

### Output

- Agent income in Coin (currency)
- Updated skill observations
- Wage rate information

## PeriodicBracketTax Component

**File**: `ai_economist/foundation/components/continuous_double_auction.py` (Taxation logic)

### Purpose

Implements a realistic tax system with progressive tax brackets, similar to the US federal income tax system.

### Key Parameters

- `bracket_spacing`: Tax bracket configuration (e.g., 'us-federal')
- `tax_model`: Tax model type ('us-federal-single-filer-2018-scaled' or 'saez')
- `period`: How often tax is reassessed (in months)
- `usd_scaling`: Scaling factor to adjust tax brackets for simulation

### How It Works

1. Income is divided into brackets
2. Each bracket taxed at its corresponding rate
3. Tax revenue collected
4. Revenue redistributed equally to all agents (lump sum)

### Tax Brackets Example

The default US federal tax brackets (scaled for simulation):

```
0% on income 0-$812.50
12% on income $812.50-$3,289.25
22% on income $3,289.25-$7,020.00
24% on income $7,020.00-$13,410.25
32% on income $13,410.25-$17,008.33
35% on income $17,008.33-$42,525.00
37% on income above $42,525.00
```

### Agent Experience

- Agents observe their tax brackets and rates
- They see tax paid and lump sum received
- Tax policy can change over time (for policy experiments)

## SimpleConsumption Component

**File**: `ai_economist/foundation/components/simple_consumption.py`

### Purpose

Models the consumption market where agents decide how much to spend on goods based on prices, wealth, and preferences.

### Key Parameters

- `consumption_rate_step`: Granularity of consumption choices (default: 0.02, i.e., 2% increments)
- `max_price_inflation`: Maximum monthly price increase (default: 10%)
- `max_wage_inflation`: Maximum monthly wage increase (default: 5%)

### How It Works

1. Market prices are determined by aggregate consumption demand and supply
2. Agents decide consumption fraction (0 to 1)
3. Amount spent = consumption_fraction × available_wealth
4. Price changes reflect market dynamics

### Market Dynamics

- **Price Increase**: When demand exceeds supply
- **Price Decrease**: When supply exceeds demand
- **Agent Response**: Prices affect consumption decisions

### Agent Decision

Agents must decide: **Consumption fraction** (0 to 1, represents portion of wealth to spend)

### Inflation/Deflation

- Prices automatically adjust based on market conditions
- Observed in agent prompts for informed decision-making

## SimpleSaving Component

**File**: `ai_economist/foundation/components/simple_saving.py`

### Purpose

Manages savings, interest rates, and the financial system.

### Key Parameters

- `saving_rate`: Interest rate earned on savings (default: 0.0%)

### How It Works

1. Money not spent is automatically saved
2. Savings earn interest at the current interest rate
3. Interest rates can change to implement monetary policy

### Agent Behavior

- Wealth carries forward to next period
- Savings earn returns
- Affects future consumption capacity

## Component Interaction Order

During each timestep, components process in this order:

1. **SimpleLabor**: Agents work, earn income
2. **PeriodicBracketTax**: Income is taxed, redistribution happens
3. **SimpleConsumption**: Agents consume goods at market prices
4. **SimpleSaving**: Remaining wealth is saved with interest

## Custom Component Addition

To add a new component:

### Step 1: Create Component Class

```
class MyComponent(BaseComponent):
    name = "MyComponent"
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # Initialize parameters
    
    def reset(self, env):
        # Initialize component for new episode
        pass
    
    def get_obs(self, env):
        # Return observations for each agent
        return observations_dict
    
    def step(self, env, action):
        # Process actions and update state
        pass
```

### Step 2: Register Component

Add to component registry in `ai_economist/foundation/components/__init__.py`

### Step 3: Add to Configuration

Include in `config.yaml` under `env.components`

## Component Configuration Example

```yaml
components:
  - SimpleLabor:
      mask_first_step: false
      pareto_param: 8
      payment_max_skill_multiplier: 950
      labor_step: 168
      num_labor_hours: 168
      scale_obs: true
  
  - PeriodicBracketTax:
      bracket_spacing: us-federal
      disable_taxes: false
      period: 1
      tax_model: us-federal-single-filer-2018-scaled
      usd_scaling: 12
      scale_obs: true
```

## Component Output Format

Each component provides observations in a structured format:

```python
observations[agent_id] = {
    'ComponentName-param1': value1,
    'ComponentName-param2': value2,
    ...
}
```

This allows agents to understand which component generated each observation.

## Observation Scaling

When `scale_obs: true`, observations are normalized to [-1, 1] range for easier agent processing.

## Building Custom Scenarios

Scenarios combine components in specific ways:

### One-Step Economy (Current)

- Focuses on individual economic decisions
- Combines: Labor, Tax, Consumption, Saving
- No spatial movement or resource collection
- Emphasis on financial decisions

### Simple Wood and Stone (Alternative)

- Resource-based economy
- Agents collect and trade resources
- Simpler than one-step economy
- Good for testing basic mechanisms

