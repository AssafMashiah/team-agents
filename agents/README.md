# Agent Configurations

This directory stores agent persona and behavior configs.
Each agent is a specialised version of OpenClaw tuned for a specific role or workflow.

## Structure

```
agents/
├── research-agent/
│   └── agent.md       ← Persona, goals, behavior, channels
├── code-agent/
│   └── agent.md
└── README.md          ← This file
```

## Creating an Agent

1. Create `agents/my-agent/agent.md`
2. Define:
   - Role and persona (what this agent does and how it communicates)
   - Which channels/integrations it listens on (Discord channel IDs, Signal number)
   - Which skills it should use
   - Any specific constraints or behaviors
3. Reference the agent config in your OpenClaw gateway settings

## Current Agents

_(Add entries as you create agents)_
