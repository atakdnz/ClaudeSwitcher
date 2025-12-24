# ClaudeSwitcher

Switch Claude Code's Haiku model between official Claude Haiku 4.5 and GLM 4.7 (via Z.AI).

## Scripts

### `switch-to-glm.command`
Routes Haiku tasks through GLM 4.7 (Z.AI) while keeping Sonnet/Opus on official Claude models.

**Configuration:**
- Haiku → GLM 4.7
- Sonnet → Claude Sonnet 4.5
- Opus → Claude Opus 4.5

### `switch-to-claude.command`
Restores all models to official Claude endpoints.

**Configuration:**
- Haiku → Claude Haiku 4.5
- Sonnet → Claude Sonnet 4.5
- Opus → Claude Opus 4.5

## Usage

Double-click the `.command` files or run:
```bash
./switch-to-glm.command
./switch-to-claude.command
```

**Note:** Restart Claude Code after switching.

## Files

- `~/.claude/settings.json` - Configuration
- `~/.claude/zai_api_key` - Z.AI API key
- `~/.claude/settings.backup.*.json` - Automatic backups
