# Agent Behavior Models

This document explains how agents make decisions in the EconAgent framework.

## Overview

The framework supports multiple agent decision-making models ranging from LLM-based reasoning to traditional economic models. Each model represents a different approach to simulating economic behavior.

## GPT-Based Agent Model

### Model Architecture

GPT-based agents use large language models to generate economic decisions based on economic context. They simulate agents receiving economic information as natural language and providing decisions.

### Decision Process

Each decision cycle involves:

1. Observation Collection: Gather current economic state
2. Context Formation: Create natural language narrative of situation
3. LLM Query: Send to OpenAI API with formatted prompt
4. Decision Extraction: Parse JSON response for work and consumption decisions
5. Validation: Check decisions are within valid ranges

### Information Provided to Agent

The agent prompt includes:

Agent Identity Information:
- Name, age, location
- Current employment status and job title
- Job offer (if unemployed)

Economic Context:
- Previous income and employment history
- Current wealth and savings
- Consumption history

Market Information:
- Current prices and price history (inflation/deflation)
- Wage inflation or deflation
- Interest rates

Tax Information:
- Tax brackets and rates
- Recent tax paid
- Redistribution received (lump sum)

Historical Context:
- Comparison to previous period
- Economic trends

### Decision Format

Agents respond with JSON containing two key decisions:

```json
{
  "work": 0.5,
  "consumption": 0.75
}
```

Where:
- work: Binary or continuous value (0 or 1) indicating work decision
- consumption: Value 0-1 in 0.02 increments indicating consumption fraction

### Prompt Engineering

Key aspects of the prompt:

Contextualization: Agents understand they are individuals in a realistic economy

Formatting Instructions: Clear JSON format requirements

Decision Framing: Decisions presented as realistic economic choices

Economic Reasoning: Agents consider factors like costs, future needs, economic trends

Example Prompt Structure:

```
You're Michael Johnson, a 38-year-old [job title] living in [city].

Tax System Context: Your income is taxed using tax brackets...

Employment: [Employment offer or current job details]

Financial Status: Current savings $X, consumption $Y, interest rate Z%

Market Conditions: [Price changes, wage changes]

Tax Information: Tax paid $X, redistribution received $Y

Decision Request: How is your willingness to work? How will you plan consumption?

Format: Provide response as JSON with 'work' and 'consumption' keys.
```

### Reflection Feature

Every 3 timesteps, agents provide quarterly reflections:

Question: "Given the previous quarter's economic environment, reflect on labor, consumption, and financial markets."

Purpose: Allows agents to develop economic understanding and detect patterns

Output: Natural language reflection (under 200 words)

Stored: In extended dialog history for analysis

### Multi-Turn Conversation

Agents maintain conversation history:

Benefit: Agents remember previous interactions and reasoning

Window: Recent 3 turns in main dialog, 7 turns in reflection dialog

Context Building: Agents can refine understanding over time

### Error Handling

When LLM response is invalid:

Default Action: [work=1, consumption=0.5]

Error Tracking: Increments gpt_error counter

Investigation: Check error patterns in logs

Adjustment: May indicate need for prompt redesign

## Complex Agent Model

### Model Philosophy

Complex agents use traditional economic theory and heuristic decision rules rather than LLMs. This provides a baseline for comparison and faster execution.

### Decision Models

#### Consumption Decision Models

Consumption Length Model:

- Formula: c = (price / (wealth + income)) ^ beta
- Intuition: Higher prices relative to resources reduces consumption
- Parameter beta: Price sensitivity coefficient
- Default: beta=0.1 (weak price effect)

Consumption Cats Model (Habit Formation):

- Based on buffer-stock savings theory
- Considers income growth and wealth cushions
- Incorporates habit formation effects
- More sophisticated than simple model

#### Work Decision Model

Work Income-Wealth Model:

- Probability of working based on income-wealth ratio
- Formula: P(work) = (income / (wealth * (1+interest_rate))) ^ gamma
- Parameter gamma: Income elasticity of labor supply
- Default: gamma=0.1 (inelastic)

Intuition: Agents work more when income needs exceed wealth buffer

### Agent Heterogeneity

Each complex agent has:

Consumption Function: Randomly assigned at initialization
- Type 1: consumption_len (price-sensitive)
- Type 2: consumption_cats (habit-based)

Work Function: Currently only one type
- Randomly assigned threshold

Stored Preferences: Maintained in agent.endogenous dictionary

Consistency: Same functions used throughout simulation

### Parameters

Global parameters affect all agents:

beta: Price sensitivity parameter (default 0.1)
gamma: Income elasticity parameter (default 0.1)
h: Habit reference level parameter (default 1)
max_price_inflation: Maximum monthly price change (default 0.1)
max_wage_inflation: Maximum monthly wage change (default 0.05)

### Advantages and Disadvantages

Advantages:
- Fast execution (no API calls)
- Deterministic (reproducible results)
- Interpretable (clear economic logic)
- No API costs
- No rate limits

Disadvantages:
- Less realistic behavior
- Simpler decision patterns
- No emergent reasoning
- Potentially unrealistic preferences

## Behavioral Differences

### Work Decision

LLM Agent: Considers narrative economic arguments, job satisfaction, future prospects

Complex Agent: Binary decision based on mathematical income-wealth ratio

### Consumption Decision

LLM Agent: Evaluates prices against future needs, personal preferences

Complex Agent: Mathematical formula based on parameters

### Response to Policy Changes

LLM Agent: Can understand and reason about policy implications

Complex Agent: Mechanically responds to changed parameters

### Error Recovery

LLM Agent: May recover from errors through conversation

Complex Agent: Always follows same logic

## Agent Initialization

### Agent Attributes

Each agent receives endogenous attributes:

```python
agent.endogenous = {
    'name': str,           # Name from profiles
    'age': int,            # Age from profiles
    'city': str,           # Location
    'job': str,            # Current job title
    'offer': str,          # Job offer (if unemployed)
    'consumption_fun_idx': int,  # For complex agents
    'work_fun_idx': int          # For complex agents
}
```

### Initial State

Skills initialized from Pareto distribution

Wealth initialized to reasonable starting values

Names and demographics loaded from data/profiles.json

Employment assigned based on skill level

### State Evolution

State changes based on:

Work decisions (income earned)
Consumption decisions (wealth depleted)
Tax payments and redistribution
Interest on savings
Skill changes based on employment

## Decision Validation

### Action Constraints

Work: Binary (0 or 1) or continuous (0-1)
Converted to binary by: int(random() < value)

Consumption: 0-50 (represents 0-1.0 in 0.02 steps)
Valid range checked before processing

### Default Fallback

If action invalid: Use [work=1, consumption=0.5]

Ensures simulation continues even with errors

## Learning and Adaptation

### LLM Adaptation

Agents can learn through:
- Conversation history (remember past discussions)
- Reflection prompts (quarterly economic analysis)
- Observation changes (see outcomes of decisions)

Mechanism: Information carries forward in dialog history

### Complex Agent Adaptation

Limited adaptation:
- Skill changes based on employment
- Preferences fixed at initialization
- No learning from experience

## Comparison Framework

### Experimental Setup

Run identical scenarios with:

Same random seed for reproducibility
Same agent profiles (demographics)
Same component configuration
Different decision models only

### Metrics for Comparison

Economic outcomes:
- Income distribution
- Wealth distribution
- Consumption patterns
- Work participation

Aggregate metrics:
- Gini coefficient
- Total productivity
- Total consumption
- Average utility

Behavior patterns:
- Volatility of decisions
- Response to policy changes
- Error rates

### Validation Questions

Does GPT agent model realistic behavior?
How do agent models compare to theory?
Which model predicts real-world outcomes better?
Are agent models robust to parameter changes?

## Custom Agent Models

To implement a custom decision model:

1. Create decision function(s) similar to gpt_actions or complex_actions
2. Takes env, obs, and parameters
3. Returns actions dictionary
4. Integrate into main simulation loop
5. Add command-line parameters for experimentation

This enables testing various economic theories and AI models.

