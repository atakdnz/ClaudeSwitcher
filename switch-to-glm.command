#!/bin/bash
# Switch Claude Code to use GLM 4.7 for Haiku tasks (keeping Claude for Sonnet/Opus)

SETTINGS_FILE="$HOME/.claude/settings.json"
BACKUP_FILE="$HOME/.claude/settings.backup.json"
API_KEY_FILE="$HOME/.claude/zai_api_key"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Switching Haiku model to GLM 4.7...${NC}"

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

# Load API key from file if it exists, otherwise prompt
if [ -f "$API_KEY_FILE" ]; then
    ZAI_API_KEY=$(cat "$API_KEY_FILE")
    echo -e "${GREEN}✓ Using saved Z.AI API key${NC}"
elif [ -z "$ZAI_API_KEY" ]; then
    echo -e "${YELLOW}Please enter your Z.AI API key (will be saved for future use):${NC}"
    read -r ZAI_API_KEY
    # Save the API key for future use
    echo "$ZAI_API_KEY" > "$API_KEY_FILE"
    chmod 600 "$API_KEY_FILE"
    echo -e "${GREEN}✓ API key saved to $API_KEY_FILE${NC}"
fi

# Create settings.json with GLM for Haiku only
cat > "$SETTINGS_FILE" <<EOF
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "$ZAI_API_KEY",
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.7"
  }
}
EOF

echo -e "${GREEN}✓ Successfully configured Claude Code!${NC}"
echo -e "${GREEN}  - Haiku tasks → GLM 4.7 (via Z.AI)${NC}"
echo -e "${GREEN}  - Sonnet tasks → Claude Sonnet 4.5 (official)${NC}"
echo -e "${GREEN}  - Opus tasks → Claude Opus 4.5 (official)${NC}"
echo ""
echo -e "${YELLOW}Note: Restart any running Claude Code sessions for changes to take effect.${NC}"
