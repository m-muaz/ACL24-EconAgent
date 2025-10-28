# EconAgent Documentation Index

A comprehensive documentation suite for the EconAgent framework.

## Quick Navigation

### For New Users

1. **Start here**: [Project Overview](./01_project_overview.md)
   - Understand what EconAgent is and why it matters
   - Learn about key innovations and research applications

2. **Next step**: [Usage Examples](./09_usage_examples.md)
   - Run your first simulation
   - Understand command-line parameters
   - See practical examples

3. **Reference**: [API Reference](./08_api_reference.md)
   - Look up specific functions and classes
   - Understand function signatures
   - Find examples of common operations

### For Developers

1. **Architecture**: [Architecture Guide](./02_architecture_guide.md)
   - Understand system design
   - Learn component interaction model
   - Review data flow

2. **Components**: [Core Components](./03_core_components.md)
   - Deep dive into each economic component
   - Learn how to create custom components
   - Understand component interaction order

3. **Configuration**: [Configuration System](./06_configuration_system.md)
   - Configure simulations via YAML
   - Modify components and scenarios
   - Set up experiments

4. **Contributing**: [Contributing Guidelines](./10_contributing_guidelines.md)
   - Set up development environment
   - Contribute new features
   - Follow code style guidelines

### For Researchers

1. **Behavior Models**: [Agent Behavior Models](./05_agent_behavior_models.md)
   - Understand how agents make decisions
   - Compare different agent models
   - Implement custom models

2. **Simulation Engine**: [Simulation Engine](./04_simulation_engine.md)
   - Learn the timestep execution flow
   - Understand data collection
   - Track performance metrics

3. **Data Structures**: [Data Structures](./07_data_structures.md)
   - Explore simulation data structures
   - Understand observations and actions
   - Learn about state representation

4. **Usage Examples**: [Usage Examples](./09_usage_examples.md)
   - Run experiments
   - Analyze results
   - Visualize outcomes

## Documentation Files

### 01_project_overview.md (Introduction)

**For**: Everyone  
**Time**: 10 minutes  
**Topics**:
- Project goals and innovations
- Research applications
- Economic and technical innovations
- Expected outcomes and impact

**Key Sections**:
- Introduction
- Key Innovations (LLM-powered agents, realistic economy, comparative analysis)
- Research Applications (policy analysis, behavioral economics, AI intersection)
- Impact and Applications

### 02_architecture_guide.md (System Design)

**For**: Developers, maintainers  
**Time**: 20 minutes  
**Topics**:
- System architecture layers
- Component interaction model
- Data flow diagrams
- Extension points
- Performance considerations

**Key Sections**:
- Architecture Layers (Environment, Agent, Component, Scenario, Decision-Making, Integration)
- Data Flow Diagram
- Component Interaction Model
- Extension Points (custom components, scenarios, agents)

### 03_core_components.md (Economic Mechanisms)

**For**: Researchers, component developers  
**Time**: 30 minutes  
**Topics**:
- SimpleLabor component
- PeriodicBracketTax component
- SimpleConsumption component
- SimpleSaving component
- Custom component development

**Key Sections**:
- Component descriptions and parameters
- Component interaction order
- Custom component addition
- Component configuration
- Scenario building

### 04_simulation_engine.md (Runtime Behavior)

**For**: Researchers, simulation operators  
**Time**: 25 minutes  
**Topics**:
- Main simulation loop
- Timestep execution
- Data collection
- GPT agent decision making
- Complex agent models
- Performance metrics

**Key Sections**:
- Timestep Execution
- Data Collection
- GPT Actions (prompt generation, response parsing, dialog management)
- Complex Actions (consumption and work models)
- Configuration Parameters
- Performance Metrics

### 05_agent_behavior_models.md (Decision Making)

**For**: Researchers, model developers  
**Time**: 25 minutes  
**Topics**:
- GPT-based agent model
- Complex agent model
- Behavioral differences
- Agent initialization
- Learning and adaptation
- Comparison framework

**Key Sections**:
- GPT Model Architecture (decision process, prompt engineering, reflection)
- Complex Model Philosophy (consumption models, work decisions, heterogeneity)
- Behavioral Differences
- Decision Validation
- Comparison Framework

### 06_configuration_system.md (Setup and Tuning)

**For**: Researchers, simulation operators  
**Time**: 30 minutes  
**Topics**:
- YAML configuration structure
- Component configuration
- Scenario configuration
- Parameter modification
- Performance tuning

**Key Sections**:
- Configuration File Structure
- Environment Configuration (parameters, components)
- Component Details (SimpleLabor, Tax, Consumption, Saving)
- Scenario Configuration
- Experiment Setup
- GPT vs Complex Agent Configuration

### 07_data_structures.md (Data Reference)

**For**: Developers, data analysts  
**Time**: 20 minutes  
**Topics**:
- World object
- Agent state
- Observations
- Actions
- Rewards
- Dialog history
- Dense logs

**Key Sections**:
- All major data structures used in simulation
- Structure definitions and access patterns
- Examples of data formats
- Serialization information

### 08_api_reference.md (Function Reference)

**For**: Developers, API users  
**Time**: 20 minutes  
**Topics**:
- Environment creation API
- Environment methods (reset, step)
- Agent methods
- Component interface
- Simulation functions
- Utility functions

**Key Sections**:
- Function signatures
- Parameter descriptions
- Return values
- Usage examples
- Error handling
- Configuration loading

### 09_usage_examples.md (Practical Tutorials)

**For**: Everyone  
**Time**: 40 minutes  
**Topics**:
- Setup and installation
- Running simulations
- Data analysis
- Experiment design
- Result visualization
- Batch experiments

**Key Sections**:
- Basic Setup
- 10 Complete Examples (GPT simulation, complex agents, policy experiments, scaling analysis, etc.)
- Tips and Best Practices

### 10_contributing_guidelines.md (Developer Guide)

**For**: Contributors  
**Time**: 30 minutes  
**Topics**:
- Development environment setup
- Code structure
- Contributing types (components, agents, prompts, scenarios)
- Code style
- Testing
- Pull request process

**Key Sections**:
- Project Structure
- Contributing Types (new components, agents, prompts, scenarios, bug fixes)
- Code Style Guidelines
- Testing Guidelines
- Pull Request Process
- Debugging Tips

## Learning Paths

### Path 1: Researcher (Using Existing Framework)

1. [01_project_overview.md](./01_project_overview.md) - Understand the project
2. [09_usage_examples.md](./09_usage_examples.md) - Run first simulation
3. [05_agent_behavior_models.md](./05_agent_behavior_models.md) - Compare agents
4. [04_simulation_engine.md](./04_simulation_engine.md) - Understand mechanics
5. [06_configuration_system.md](./06_configuration_system.md) - Design experiments
6. [07_data_structures.md](./07_data_structures.md) - Analyze results

**Time**: 2-3 hours

### Path 2: Developer (Extending Framework)

1. [01_project_overview.md](./01_project_overview.md) - Understand the project
2. [02_architecture_guide.md](./02_architecture_guide.md) - Learn architecture
3. [03_core_components.md](./03_core_components.md) - Understand components
4. [07_data_structures.md](./07_data_structures.md) - Learn data representations
5. [08_api_reference.md](./08_api_reference.md) - Study API
6. [10_contributing_guidelines.md](./10_contributing_guidelines.md) - Development workflow

**Time**: 3-4 hours

### Path 3: LLM Prompt Engineer

1. [01_project_overview.md](./01_project_overview.md) - Understand the project
2. [05_agent_behavior_models.md](./05_agent_behavior_models.md) - Learn GPT agent model
3. [04_simulation_engine.md](./04_simulation_engine.md) - Understand prompt generation
4. [09_usage_examples.md](./09_usage_examples.md) - Run simulations
5. [10_contributing_guidelines.md](./10_contributing_guidelines.md) - Contribute prompt improvements

**Time**: 2 hours

### Path 4: Quick Start (Just Run It)

1. [01_project_overview.md](./01_project_overview.md) - 5 minute overview
2. [09_usage_examples.md](./09_usage_examples.md) - Example 1-3
3. Start experimenting!

**Time**: 30 minutes

## Key Concepts Glossary

**Agent**: An individual economic participant in the simulation

**Component**: A pluggable module that defines an economic mechanism (labor, tax, consumption, etc.)

**Observation**: Information provided to an agent about the current state (prices, wages, tax info, etc.)

**Action**: A decision made by an agent (work/not work, consumption amount)

**Reward**: Feedback signal to agents and planner based on outcomes

**Episode**: One complete simulation run (typically 240 months)

**Timestep**: One iteration of the simulation (one month)

**Planner**: Central government agent making tax policy decisions

**LLM**: Large Language Model (GPT) used for agent decision-making

**Gini Coefficient**: Measure of wealth inequality (0 = perfect equality, 1 = perfect inequality)

**Dense Log**: Complete record of all observations, actions, states, and rewards

## Common Tasks and Where to Find Help

### "How do I run a simulation?"
→ [09_usage_examples.md](./09_usage_examples.md) - Examples 1 and 2

### "How do I modify tax policy?"
→ [06_configuration_system.md](./06_configuration_system.md) - Experiment 1

### "How do I add a new economic component?"
→ [10_contributing_guidelines.md](./10_contributing_guidelines.md) - Adding New Components
→ [03_core_components.md](./03_core_components.md) - Understanding components

### "How do I understand agent decisions?"
→ [05_agent_behavior_models.md](./05_agent_behavior_models.md)
→ [09_usage_examples.md](./09_usage_examples.md) - Example 10

### "How do I analyze results?"
→ [09_usage_examples.md](./09_usage_examples.md) - Examples 6-8

### "How do I improve GPT prompts?"
→ [10_contributing_guidelines.md](./10_contributing_guidelines.md) - Improving LLM Prompts
→ [04_simulation_engine.md](./04_simulation_engine.md) - GPT Agent Decision Making section

### "What does this data structure contain?"
→ [07_data_structures.md](./07_data_structures.md)

### "What API functions are available?"
→ [08_api_reference.md](./08_api_reference.md)

### "How does the simulation work?"
→ [04_simulation_engine.md](./04_simulation_engine.md) - Timestep Execution
→ [02_architecture_guide.md](./02_architecture_guide.md) - Architecture Layers

## Documentation Statistics

- **Total Pages**: 10
- **Total Word Count**: ~25,000 words
- **Code Examples**: 100+
- **Diagrams**: 5+
- **API Functions Documented**: 20+
- **Components Documented**: 4
- **Usage Examples**: 10+

## Updating Documentation

When you:

- **Add a new component**: Update [03_core_components.md](./03_core_components.md)
- **Add a new scenario**: Update [06_configuration_system.md](./06_configuration_system.md)
- **Change API**: Update [08_api_reference.md](./08_api_reference.md)
- **Add example experiment**: Update [09_usage_examples.md](./09_usage_examples.md)
- **Modify data structure**: Update [07_data_structures.md](./07_data_structures.md)

## Documentation Quality

This documentation aims to provide:

- **Completeness**: Cover all major components and functionality
- **Clarity**: Use plain language with examples
- **Accessibility**: Organized for different user types
- **Practical**: Include runnable examples
- **Maintainability**: Update as code changes

## Getting Help

1. Check the relevant documentation file
2. Search for your question in the glossary
3. Look for examples in [09_usage_examples.md](./09_usage_examples.md)
4. Check the main [README.md](../README.md)
5. Open a GitHub issue if documentation is unclear

---

**Last Updated**: October 2025  
**Version**: 1.0  
**Maintained by**: EconAgent Team

