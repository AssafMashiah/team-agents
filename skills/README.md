# Custom Skills

This directory holds custom OpenClaw skills for your team agents.
Each skill lives in its own subfolder and tells the agent how to handle a specific category of task.

## Structure

```
skills/
├── example-skill/
│   ├── SKILL.md       ← Instructions the agent reads at runtime
│   └── index.ts       ← Optional: custom tool implementation
└── README.md          ← This file
```

## How They Work

When a user request matches a skill's description, OpenClaw reads the `SKILL.md` and follows its instructions. Skills are plain Markdown — no code required for simple workflows.

## Creating a New Skill

1. Create `skills/my-skill/SKILL.md`
2. Write clear instructions: when to use the skill, step-by-step what to do, any templates
3. Save and commit — in local dev the skill is live immediately (directory is bind-mounted)
4. For Cloudflare deployments, rebuild the image: `docker compose build && docker push`

## Tips

- Keep SKILL.md focused and concise — the agent reads it at runtime
- Skills are live-editable in local dev (no rebuild needed)
- For deployed environments, skills are baked into the Docker image at build time
