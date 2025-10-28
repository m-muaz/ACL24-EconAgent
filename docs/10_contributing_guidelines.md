# Contributing Guidelines

This document provides guidelines for contributing to the EconAgent project.

## Project Structure Overview

```
ACL24-EconAgent/
├── ai_economist/              # Main framework code
│   └── foundation/            # Core framework
│       ├── agents/            # Agent implementations
│       ├── base/              # Base classes
│       ├── components/        # Economic components
│       ├── entities/          # Entities (resources, landmarks, agents)
│       └── scenarios/         # Scenario implementations
├── data/                      # Input data
├── docs/                      # Documentation
├── simulate.py                # Main simulation script
├── simulate_utils.py          # Utility functions
├── config.yaml                # Configuration file
└── README.md                  # Main README
```

## Getting Started for Contributors

### Setting Up Development Environment

1. Clone the repository

```bash
git clone https://github.com/tsinghua-fib-lab/ACL24-EconAgent.git
cd ACL24-EconAgent
```

2. Create a virtual environment

```bash
python -m venv venv
source venv/bin/activate
```

3. Install dependencies

```bash
pip install -r requirements.txt
pip install -e .  # Install in development mode
```

4. Set up pre-commit hooks (optional)

```bash
pip install pre-commit
pre-commit install
```

### Understanding the Codebase

Key files to understand:

1. **simulate.py**: Main simulation loop and agent decision functions
2. **ai_economist/foundation/base/base_env.py**: Core environment class
3. **ai_economist/foundation/base/base_agent.py**: Agent base class
4. **ai_economist/foundation/components/**: Economic components
5. **simulate_utils.py**: Utility and API functions

## Contributing Types

### 1. Adding New Economic Components

Components define economic mechanisms like labor, consumption, taxation.

#### Steps

1. Create component file in `ai_economist/foundation/components/`

2. Implement BaseComponent interface

```python
from ai_economist.foundation.base import BaseComponent

class MyNewComponent(BaseComponent):
    """Description of what this component does"""
    
    name = "MyNewComponent"
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.parameter1 = kwargs.get('parameter1', default_value)
    
    def reset(self, env):
        """Initialize component for new episode"""
        pass
    
    def get_obs(self, env):
        """Return observations for each agent"""
        obs = {}
        for agent_id in env.agents:
            obs[agent_id] = {
                f'{self.name}-param': value,
            }
        return obs
    
    def step(self, env, action):
        """Process actions and update state"""
        for agent_id, agent_action in action.items():
            # Update agent state based on action
            pass
```

3. Register component in `__init__.py`

```python
component_registry.register(MyNewComponent)
```

4. Add configuration to `config.yaml`

```yaml
components:
  - MyNewComponent:
      parameter1: value1
      parameter2: value2
```

5. Write tests

6. Update documentation

### 2. Adding New Agent Behavior Models

Create new decision-making models for agents.

#### Steps

1. Create decision function in `simulate.py`

```python
def my_agent_decisions(env, obs, **kwargs):
    """Generate actions using custom model"""
    actions = {}
    
    for agent_id in range(env.num_agents):
        # Generate action for this agent
        action = compute_action(obs[f'p{agent_id}'], **kwargs)
        actions[agent_id] = action
    
    actions['p'] = [0]  # Planner no-op
    return actions
```

2. Integrate into main loop

```python
if policy_model == 'my_model':
    actions = my_agent_decisions(env, obs, **params)
```

3. Add command-line parameters

```python
def main(..., my_model_param1=0.5, my_model_param2=0.1):
    ...
```

4. Test and document

### 3. Improving LLM Prompts

Enhance how GPT agents understand economic situations.

#### Guidelines for Prompt Engineering

- **Clarity**: Use clear, unambiguous language
- **Context**: Provide sufficient economic context
- **Format**: Specify exact JSON format required
- **Examples**: Consider adding examples if complex
- **Conciseness**: Keep prompts reasonably short to reduce API costs

#### Modifying gpt_actions()

The prompt is constructed around line 60-120 in `simulate.py`. Key sections:

1. **Identity**: Name, age, location, job
2. **Employment Context**: Job offer or current employment
3. **Consumption Context**: Previous consumption level
4. **Tax Information**: Tax paid, redistribution, brackets
5. **Market Conditions**: Prices, wages, interest rates
6. **Decision Request**: Clear question about work and consumption
7. **Format Instructions**: JSON format specification

To modify:

```python
obs_prompt = f'''
    Updated context here...
    Your current prompt continues...
'''
```

#### Testing Prompts

1. Test with small num_agents and episode_length
2. Check gpt_error count
3. Review dialog logs to see if reasoning is sound
4. Iterate on prompt based on results

### 4. Extending Scenarios

Create new economic simulation scenarios.

#### Steps

1. Create scenario directory

```bash
mkdir ai_economist/foundation/scenarios/my_scenario
```

2. Implement scenario class

```python
from ai_economist.foundation.base import BaseEnvironment

class MyScenario(BaseEnvironment):
    """My custom economic scenario"""
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
    
    def reset_starting_layout(self):
        """Initialize layout"""
        pass
    
    def reset_agent_states(self):
        """Initialize agent states"""
        pass
    
    def scenario_step(self):
        """Scenario-specific dynamics"""
        pass
    
    def generate_observations(self):
        """Generate observations"""
        pass
    
    def compute_reward(self):
        """Compute rewards"""
        pass
```

3. Register in scenario registry

4. Add to configuration system

5. Document scenario details

### 5. Fixing Bugs

When fixing bugs:

1. Create issue describing the bug
2. Create branch: `git checkout -b fix/bug-description`
3. Add test case that reproduces bug
4. Fix the bug
5. Verify test passes
6. Create pull request

### 6. Improving Documentation

Documentation contributions are valuable!

- Fix typos and errors
- Add examples and clarifications
- Document unclear code sections
- Create tutorials for common tasks
- Update outdated information

## Code Style Guidelines

### Python Style

- Follow PEP 8
- Use meaningful variable names
- Add docstrings to functions and classes
- Keep functions focused and single-purpose

```python
def calculate_tax(income, brackets, rates):
    """
    Calculate tax based on income and brackets.
    
    Args:
        income: Annual income amount
        brackets: List of bracket thresholds
        rates: List of tax rates per bracket
    
    Returns:
        float: Total tax owed
    """
    tax = 0.0
    for i in range(len(brackets) - 1):
        bracket_income = min(income, brackets[i + 1]) - brackets[i]
        tax += bracket_income * rates[i]
    return tax
```

### Component Implementation

- Clearly document parameters
- Handle edge cases
- Validate inputs
- Provide meaningful observation names
- Test component isolation

### Comments and Documentation

```python
# Good: Explains why, not what
# Limit consumption based on price and wealth to model budget constraints
consumption_fraction = income / (price * wealth + epsilon)

# Avoid: Obvious from code
# Set x to 1
x = 1
```

## Testing Guidelines

### Writing Tests

1. Create test file: `test_my_component.py`

2. Write unit tests

```python
import unittest
from ai_economist.foundation.components import MyNewComponent

class TestMyNewComponent(unittest.TestCase):
    
    def setUp(self):
        self.component = MyNewComponent(parameter1=value)
    
    def test_initialization(self):
        """Test component initializes correctly"""
        self.assertIsNotNone(self.component)
    
    def test_obs_structure(self):
        """Test observation output format"""
        obs = self.component.get_obs(mock_env)
        self.assertIn('agent_id', obs)
        self.assertIn('parameter', obs['agent_id'])
```

3. Run tests

```bash
python -m pytest test_my_component.py -v
```

### Testing Simulations

1. Create minimal test scenario

```python
def test_simulation_runs():
    """Test that simulation completes without error"""
    env = foundation.make_env_instance(
        scenario_name='one-step-economy',
        n_agents=5,
        episode_length=3
    )
    
    obs = env.reset()
    
    for _ in range(env.episode_length):
        actions = get_test_actions(env)
        obs, rew, done, info = env.step(actions)
    
    assert done['__all__']
```

2. Test with complex agents (no API calls)

3. Verify results make sense

## Pull Request Process

1. Update code with your changes
2. Write or update tests
3. Update documentation
4. Run tests locally: `pytest`
5. Commit with clear message

```bash
git add .
git commit -m "Add MyNewComponent for simulating markets"
```

6. Push to your fork

```bash
git push origin fix/bug-description
```

7. Create pull request with:
   - Clear title
   - Description of changes
   - Reference to related issues
   - Note any breaking changes

8. Address review comments

## Debugging Tips

### Print Debugging

```python
print(f"Agent {agent_id} observations: {obs[agent_id]}")
print(f"Actions: {actions}")
print(f"Rewards: {rewards}")
```

### Setting Breakpoints

```python
import pdb
pdb.set_trace()

# Or in Python 3.7+:
breakpoint()
```

### Checking Shapes and Types

```python
print(f"Observations type: {type(obs)}")
print(f"Action shape: {np.array(actions['p0']).shape}")
```

### Loading Checkpoints for Debugging

```python
import pickle as pkl

with open('data/myrun/env_60.pkl', 'rb') as f:
    env = pkl.load(f)

# Inspect environment state
print(env.world.timestep)
print(env.get_agent('p0').inventory)
```

## Performance Optimization

When optimizing code:

1. Profile first: `python -m cProfile -s cumtime simulate.py`
2. Identify bottlenecks
3. Optimize wisely (clarity often more important than micro-optimizations)
4. Benchmark before/after
5. Document optimization rationale

## Communication

- Use GitHub issues for bugs and feature requests
- Discuss major changes before implementing
- Update team in pull request comments
- Be respectful and constructive

## Resources

- [Salesforce AI Economist](https://github.com/salesforce/ai-economist)
- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Python Best Practices](https://pep8.org/)
- [Git Workflow Guide](https://git-scm.com/book/en/v2)

## Getting Help

- Check existing documentation in `docs/`
- Review similar implementations in codebase
- Ask in GitHub issues
- Check original paper and references

Thank you for contributing to EconAgent!

