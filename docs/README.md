# EconAgent Documentation

This documentation provides a comprehensive overview of the EconAgent codebase, which implements Large Language Model-Empowered Agents for Simulating Macroeconomic Activities as described in the ACL 2024 paper.

## Table of Contents

1. [Project Overview](./01_project_overview.md)
2. [Architecture Guide](./02_architecture_guide.md)
3. [Core Components](./03_core_components.md)
4. [Simulation Engine](./04_simulation_engine.md)
5. [Agent Behavior Models](./05_agent_behavior_models.md)
6. [Configuration System](./06_configuration_system.md)
7. [Data Structures](./07_data_structures.md)
8. [API Reference](./08_api_reference.md)
9. [Usage Examples](./09_usage_examples.md)
10. [Contributing Guidelines](./10_contributing_guidelines.md)

## Quick Start

For a quick start guide, see [Usage Examples](./09_usage_examples.md).

## Key Features

- **Multi-Agent Economic Simulation**: Simulates complex economic interactions between multiple agents
- **LLM Integration**: Uses GPT models to generate realistic economic decision-making behavior
- **Flexible Policy Models**: Supports both LLM-based and traditional economic models
- **Tax Policy Simulation**: Implements various taxation systems including US federal tax brackets
- **Market Dynamics**: Simulates labor markets, consumption markets, and savings behavior
- **Configurable Environment**: Highly customizable through YAML configuration files

## Getting Started

1. Install dependencies (see requirements in the main README)
2. Configure your OpenAI API key in `simulate_utils.py`
3. Run a simulation: `python simulate.py --policy_model gpt --num_agents 100 --episode_length 240`
4. Explore the results in the generated data folders

For detailed instructions, see the individual documentation files.
