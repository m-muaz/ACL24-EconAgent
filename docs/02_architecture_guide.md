# Architecture Guide

## System Overview

EconAgent follows a layered architecture that separates concerns and enables extensibility. The framework is built on top of the Salesforce AI Economist Foundation, with enhancements for LLM integration.

## Architecture Layers

### 1. Environment Layer (Base Environment)
Located in: `ai_economist/foundation/base/base_env.py`

The BaseEnvironment class provides the core simulation engine:

- **World Management**: Manages the simulation world, time progression, and global state
- **Agent Management**: Creates and manages all agents in the simulation
- **Component Orchestration**: Coordinates all components and their interactions
- **State Management**: Handles observation generation and state tracking
- **Reward Computation**: Calculates rewards for agents and the planner

Key methods:
- `reset()`: Initializes the environment and returns initial observations
- `step(actions)`: Processes agent actions and returns observations, rewards, done flags, and info
- `seed(seed)`: Sets random seeds for reproducibility

### 2. Agent Layer (Base Agent)
Located in: `ai_economist/foundation/base/base_agent.py`

BaseAgent provides the foundation for all agents in the simulation:

- **State Management**: Stores agent-specific state (inventory, skills, etc.)
- **Action Handling**: Manages different action spaces for different components
- **Identity**: Each agent has a unique index and endogenous characteristics
- **Multi-action Support**: Allows agents to take multiple actions per timestep

Key attributes:
- `inventory`: Stores what the agent owns (e.g., Coin, resources)
- `state`: Stores agent properties (e.g., skill level)
- `endogenous`: Stores permanent agent characteristics (name, age, city, job)
- `income`: Tracks income from different sources

### 3. Component Layer (Base Component)
Located in: `ai_economist/foundation/base/base_component.py`

Components are pluggable modules that define specific economic mechanisms:

- **Labor Component**: Manages work and wage generation
- **Consumption Component**: Handles consumption of goods and services
- **Taxation Component**: Implements tax systems and redistribution
- **Saving Component**: Manages savings and interest
- **Market Components**: Implements auction and trading mechanisms

Each component:
- Defines action spaces
- Processes actions at each timestep
- Updates agent state
- Generates observations
- Provides rewards

### 4. Scenario Layer (Scenarios)
Located in: `ai_economist/foundation/scenarios/`

Scenarios combine components and create complete economic environments:

- **One-Step Economy**: Main scenario used in this research
- **Simple Wood and Stone**: Alternative scenario with resource-based economy

Scenarios implement:
- Initial layout generation
- Agent state initialization
- Scenario-specific dynamics
- Observation generation
- Reward computation

### 5. Decision-Making Layer (Agents)
Located in: `ai_economist/foundation/agents/`

Two types of agents:
- **Mobile Agents**: Individual economic participants
- **Planner Agent**: Central authority (government)

### 6. Integration Layer (API Layer)
Located in: `ai_economist/foundation/__init__.py`

The public API that connects all layers:

```python
def make_env_instance(scenario_name, **kwargs):
    # Creates an environment instance from configuration
```

## Data Flow Diagram

```
┌─────────────────────┐
│  Configuration      │
│  (config.yaml)      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  make_env_instance  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────────────────────┐
│       BaseEnvironment               │
│  ┌─────────────────────────────────┐│
│  │  World (time, state)            ││
│  │  Agents (N mobile + 1 planner)  ││
│  │  Components (Labor, Tax, etc.)  ││
│  └─────────────────────────────────┘│
└──────────┬──────────────────────────┘
           │
    ┌──────┴──────┐
    │             │
    ▼             ▼
┌──────────┐  ┌──────────┐
│reset()   │  │ step()   │
└────┬─────┘  └────┬─────┘
     │             │
     ▼             ▼
┌────────────────────────────┐
│  Observations, Rewards     │
│  Agent States              │
└────────────────────────────┘
```

## Component Interaction Model

### Per-Timestep Execution Flow

1. **Observation Generation**
   - Each component generates its observations
   - Observations are collected per agent
   - Global observations collected for planner

2. **Action Collection**
   - For GPT-based agents: LLM generates actions based on observations
   - For complex agents: Deterministic economic models generate actions

3. **Action Processing**
   - Components process actions in sequence
   - State updates cascade through components
   - Market dynamics simulated

4. **Reward Computation**
   - Agent rewards calculated based on consumption and labor
   - Planner reward based on equality and productivity
   - Rewards returned to agents

### Component Dependency Graph

```
SimpleLabor
    ├─ Updates: agent.state['skill'], agent.income
    └─ Generates: labor observations

PeriodicBracketTax
    ├─ Depends on: labor income
    ├─ Updates: tax_paid, lump_sum redistribution
    └─ Generates: tax observations

SimpleConsumption
    ├─ Depends on: agent wealth, prices
    ├─ Updates: agent consumption, inventory
    └─ Generates: consumption observations

SimpleSaving
    ├─ Depends on: agent income, savings
    ├─ Updates: agent wealth with interest
    └─ Generates: savings observations
```

## Extension Points

### Adding New Components

To add a new economic mechanism:

1. Create a new class extending `BaseComponent`
2. Implement required methods:
   - `reset()`: Initialize component
   - `get_obs()`: Return observations
   - `step()`: Process actions and update state
3. Register in the component registry
4. Add to scenario configuration

### Adding New Scenarios

To create a new scenario:

1. Create a new directory in `scenarios/`
2. Create a scenario class extending `BaseEnvironment`
3. Implement abstract methods
4. Register the scenario

### Adding New Agent Types

To implement custom agent behavior:

1. Extend the agent decision-making logic
2. Modify `gpt_actions()` or `complex_actions()` functions in `simulate.py`
3. Implement your custom decision model

## Data Structures

### World Object

Maintains global simulation state:

```python
world.timestep          # Current simulation step
world.price             # Price history (list)
world.interest_rate     # Interest rate history (list)
world.wage_multiplier   # Wage inflation factor
```

### Agent State Dictionary

```python
agent.state = {
    'skill': float,           # Agent's productivity
    'expected_skill': float   # Projected future skill
}
```

### Observations Dictionary

```python
obs = {
    'p': {                    # Planner observations
        'PeriodicBracketTax-curr_rates': [...],
        ...
    },
    'p0', 'p1', ...: {        # Agent observations
        'SimpleLabor-...': value,
        'PeriodicBracketTax-...': value,
        ...
    }
}
```

## Configuration System

The YAML configuration file specifies:

- Environment parameters (number of agents, episode length)
- Component configurations (labor hours, tax brackets, etc.)
- Agent policy configuration (model architecture, learning rates)
- Planner policy configuration
- Trainer configuration (for RL-based policies)

See `config.yaml` in the root directory for detailed configuration structure.

## Performance Considerations

### Scalability

- **Agent Count**: Linear scaling with number of agents
- **Episode Length**: Linear scaling with simulation duration
- **Component Count**: Computational cost increases with each component

### Memory Usage

- Agents store state and historical data
- Observations stored for each agent
- Consider periodic cleanup for long simulations

### Optimization

- Use configuration to disable unnecessary components
- Batch process agent decisions (already implemented for LLM calls)
- Use multiprocessing for parallel completion fetching
