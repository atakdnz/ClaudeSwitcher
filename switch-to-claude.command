#!/bin/bash
# Switch Claude Code back to official Claude models (including Haiku)

SETTINGS_FILE="$HOME/.claude/settings.json"
BACKUP_FILE="$HOME/.claude/settings.backup.json"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Switching back to official Claude models...${NC}"

# Create .claude directory if it doesn't exist
mkdir -p "$HOME/.claude"

# Backup existing settings with timestamp
if [ -f "$SETTINGS_FILE" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    TIMESTAMPED_BACKUP="$HOME/.claude/settings.backup.$TIMESTAMP.json"
    cp "$SETTINGS_FILE" "$TIMESTAMPED_BACKUP"
    echo -e "${GREEN}✓ Backed up current settings to $TIMESTAMPED_BACKUP${NC}"

    # Keep only the 5 most recent backups (excluding the main settings.backup.json)
    ls -t ~/.claude/settings.backup.*.json 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null
fi

    # Remove Z.AI specific settings using python/json parsing
    # This preserves other settings while removing GLM config
    if command -v python3 &> /dev/null; then
        python3 - <<PYTHON_SCRIPT
import json
import os

settings_file = "$SETTINGS_FILE"

try:
    with open(settings_file, 'r') as f:
        data = json.load(f)

    # Remove Z.AI specific environment variables
    if 'env' in data:
        env = data['env']
        keys_to_remove = ['ANTHROPIC_AUTH_TOKEN', 'ANTHROPIC_BASE_URL',
                          'ANTHROPIC_DEFAULT_HAIKU_MODEL',
                          'ANTHROPIC_DEFAULT_SONNET_MODEL',
                          'ANTHROPIC_DEFAULT_OPUS_MODEL']
        for key in keys_to_remove:
            env.pop(key, None)

        # If env is empty, remove it
        if not env:
            del data['env']

    # Write back the cleaned settings
    with open(settings_file, 'w') as f:
        json.dump(data, f, indent=2)

    print("✓ Removed Z.AI configuration")
except Exception as e:
    print(f"Warning: {e}")
PYTHON_SCRIPT
    else
        echo -e "${YELLOW}⚠ Python3 not found, resetting to default settings${NC}"
        # Remove all Z.AI specific lines using sed
        sed -i.tmp '/ANTHROPIC_AUTH_TOKEN/d; /ANTHROPIC_BASE_URL/d; /ANTHROPIC_DEFAULT_HAIKU_MODEL/d; /ANTHROPIC_DEFAULT_SONNET_MODEL/d; /ANTHROPIC_DEFAULT_OPUS_MODEL/d' "$SETTINGS_FILE"
        rm -f "${SETTINGS_FILE}.tmp"
    fi
else
    # No existing settings, create empty config
    echo "{}" > "$SETTINGS_FILE"
fi

echo -e "${GREEN}✓ Successfully restored official Claude models!${NC}"
echo -e "${GREEN}  - Haiku tasks → Claude 3.5 Haiku${NC}"
echo -e "${GREEN}  - Sonnet tasks → Claude Sonnet 4.5${NC}"
echo -e "${GREEN}  - Opus tasks → Claude Opus 4.5${NC}"
echo ""
echo -e "${YELLOW}Note: Restart any running Claude Code sessions for changes to take effect.${NC}"
