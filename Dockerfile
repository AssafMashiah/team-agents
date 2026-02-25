# =============================================================================
# Custom OpenClaw Image — AssafMashiah/team-agents
# =============================================================================
# Extends phioranex/openclaw-docker (the community pre-built OpenClaw image).
#
# Skills and agents are BAKED INTO the image at build time — making this image
# fully self-contained for Cloudflare or any container registry deployment.
#
# In local dev (docker-compose.yml), skills/ and agents/ are ALSO bind-mounted
# so you can edit them live without rebuilding.
# =============================================================================

FROM ghcr.io/phioranex/openclaw-docker:latest

LABEL org.opencontainers.image.source="https://github.com/AssafMashiah/team-agents"
LABEL org.opencontainers.image.description="OpenClaw with team agents and custom skills"
LABEL org.opencontainers.image.licenses="MIT"

USER root

# Extra CLI tools useful for agent workflows
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    ripgrep \
    fd-find \
    tree \
    && rm -rf /var/lib/apt/lists/*

# Ensure skills and agents directories exist with correct ownership
RUN mkdir -p /home/node/.openclaw/skills \
              /home/node/.openclaw/agents \
    && chown -R node:node /home/node/.openclaw/skills \
                          /home/node/.openclaw/agents

# Copy skills and agents into image (used by deployed/Cloudflare builds)
# In local dev these are overridden by the volume mounts in docker-compose.yml
COPY --chown=node:node skills/  /home/node/.openclaw/skills/
COPY --chown=node:node agents/  /home/node/.openclaw/agents/

USER node
WORKDIR /home/node
