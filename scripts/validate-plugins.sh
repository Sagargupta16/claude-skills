#!/usr/bin/env bash
# Validates plugin structure and skill quality standards.
# Run from repo root: bash scripts/validate-plugins.sh

set -euo pipefail

ERRORS=0
WARNINGS=0

error() { echo "ERROR: $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo "WARN:  $1"; WARNINGS=$((WARNINGS + 1)); }
info() { echo "OK:    $1"; }

# Check marketplace.json exists and is valid JSON
MARKETPLACE=".claude-plugin/marketplace.json"
if [[ ! -f "$MARKETPLACE" ]]; then
  error "$MARKETPLACE not found"
  exit 1
fi

if ! python3 -c "import json; json.load(open('$MARKETPLACE'))" 2>/dev/null && \
   ! node -e "JSON.parse(require('fs').readFileSync('$MARKETPLACE','utf8'))" 2>/dev/null; then
  error "$MARKETPLACE is not valid JSON"
  exit 1
fi
info "$MARKETPLACE is valid JSON"

# Extract plugin names and pluginRoot from marketplace.json.
# Pipe through `tr -d '\r'` so the script works on Windows (Git Bash / MSYS)
# where python3/node may emit CRLF line endings.
if command -v python3 &>/dev/null; then
  PLUGIN_ROOT=$(python3 -c "
import json
data = json.load(open('$MARKETPLACE'))
print(data.get('metadata', {}).get('pluginRoot', '.'))
" | tr -d '\r')
  PLUGIN_NAMES=$(python3 -c "
import json
data = json.load(open('$MARKETPLACE'))
for p in data['plugins']:
    print(p['name'] + '|' + p.get('source', p['name']))
" | tr -d '\r')
elif command -v node &>/dev/null; then
  PLUGIN_ROOT=$(node -e "
const data = JSON.parse(require('fs').readFileSync('$MARKETPLACE','utf8'));
console.log((data.metadata || {}).pluginRoot || '.');
" | tr -d '\r')
  PLUGIN_NAMES=$(node -e "
const data = JSON.parse(require('fs').readFileSync('$MARKETPLACE','utf8'));
data.plugins.forEach(p => console.log(p.name + '|' + (p.source || p.name)));
" | tr -d '\r')
else
  error "Neither python3 nor node available for JSON parsing"
  exit 1
fi

# Normalize pluginRoot (strip leading ./)
PLUGIN_ROOT="${PLUGIN_ROOT#./}"

# The 33 hook events Claude Code dispatches, per
# https://code.claude.com/docs/en/hooks#hook-events. A manifest keyed on
# anything else (`PreToolCall`, say) is silently never dispatched.
HOOK_EVENTS="SessionStart Setup UserPromptSubmit UserPromptExpansion PreToolUse \
PermissionRequest PermissionDenied PostToolUse PostToolUseFailure PostToolBatch \
Notification MessageDisplay SubagentStart SubagentStop TaskCreated TaskCompleted \
Stop StopFailure TeammateIdle InstructionsLoaded ConfigChange CwdChanged \
DirectoryAdded FileChanged WorktreeCreate WorktreeRemove PreCompact PostCompact \
PreModelSwitch PostModelSwitch Elicitation ElicitationResult SessionEnd"

# Audits a hooks.json for unknown event names and for commands that reference a
# script which does not exist. Prints one finding per line; the caller counts
# them. Registration is only half the contract: a manifest can point at a ghost.
# Quoted heredocs below, so the shell substitutes nothing and the scripts get
# their arguments through argv.
audit_hooks_manifest() {
  local manifest="$1" plugin_dir="$2"
  if command -v python3 &>/dev/null; then
    python3 - "$manifest" "$plugin_dir" "$HOOK_EVENTS" <<'PY' | tr -d '\r'
import json, os, re, sys

manifest, plugin_dir, events = sys.argv[1], sys.argv[2], set(sys.argv[3].split())
ROOT = "${CLAUDE_PLUGIN_ROOT}"
data = json.load(open(manifest, encoding="utf-8"))

for event, matchers in (data.get("hooks") or {}).items():
    if event not in events:
        print("%s declares unknown event '%s' -- nothing dispatches it" % (manifest, event))
    for matcher in matchers or []:
        for entry in matcher.get("hooks") or []:
            for ref in re.findall(re.escape(ROOT) + r"[^\s\"']*", entry.get("command", "")):
                target = os.path.join(plugin_dir, ref[len(ROOT):].lstrip("/"))
                if not os.path.isfile(target):
                    print("%s references %s, which does not exist" % (manifest, ref))
PY
  else
    node - "$manifest" "$plugin_dir" "$HOOK_EVENTS" <<'JS' | tr -d '\r'
const fs = require("fs");
const path = require("path");

const [manifest, pluginDir, eventList] = process.argv.slice(2);
const events = new Set(eventList.split(/\s+/).filter(Boolean));
const ROOT = "${CLAUDE_PLUGIN_ROOT}";
const data = JSON.parse(fs.readFileSync(manifest, "utf8"));

for (const [event, matchers] of Object.entries(data.hooks || {})) {
  if (!events.has(event)) {
    console.log(`${manifest} declares unknown event '${event}' -- nothing dispatches it`);
  }
  for (const matcher of matchers || []) {
    for (const entry of matcher.hooks || []) {
      const refs = (entry.command || "").match(/\$\{CLAUDE_PLUGIN_ROOT\}[^\s"']*/g) || [];
      for (const ref of refs) {
        const target = path.join(pluginDir, ref.slice(ROOT.length).replace(/^\//, ""));
        if (!fs.existsSync(target) || !fs.statSync(target).isFile()) {
          console.log(`${manifest} references ${ref}, which does not exist`);
        }
      }
    }
  }
}
JS
  fi
}

while IFS='|' read -r name source; do
  echo ""
  echo "--- Plugin: $name ---"

  # Resolve plugin directory: if source is a path (contains /), use as-is;
  # otherwise treat as a name relative to pluginRoot (backwards compat).
  source="${source#./}"
  if [[ "$source" == */* ]]; then
    plugin_dir="$source"
  elif [[ "$PLUGIN_ROOT" == "." ]]; then
    plugin_dir="$source"
  else
    plugin_dir="$PLUGIN_ROOT/$source"
  fi

  if [[ ! -d "$plugin_dir" ]]; then
    error "Plugin directory $plugin_dir not found"
    continue
  fi
  info "Directory exists"

  # Check .claude-plugin/plugin.json exists (correct location per docs)
  if [[ -f "$plugin_dir/.claude-plugin/plugin.json" ]]; then
    info ".claude-plugin/plugin.json exists"
    # Validate it's valid JSON
    if ! python3 -c "import json; json.load(open('$plugin_dir/.claude-plugin/plugin.json'))" 2>/dev/null && \
       ! node -e "JSON.parse(require('fs').readFileSync('$plugin_dir/.claude-plugin/plugin.json','utf8'))" 2>/dev/null; then
      error "$plugin_dir/.claude-plugin/plugin.json is not valid JSON"
    fi
  else
    warn "No .claude-plugin/plugin.json in $plugin_dir"
  fi

  # Warn if plugin.json exists at wrong location (root instead of .claude-plugin/)
  if [[ -f "$plugin_dir/plugin.json" ]]; then
    warn "$plugin_dir/plugin.json found at root -- should be in .claude-plugin/"
  fi

  # Check README.md exists
  if [[ -f "$plugin_dir/README.md" ]]; then
    info "README.md exists"
  else
    warn "No README.md in $plugin_dir"
  fi

  # Auto-discover and validate skills (convention: skills/*/SKILL.md)
  if [[ -d "$plugin_dir/skills" ]]; then
    for skill_dir in "$plugin_dir/skills"/*/; do
      [[ -d "$skill_dir" ]] || continue
      skill_md="${skill_dir}SKILL.md"
      if [[ ! -f "$skill_md" ]]; then
        warn "Skill directory $skill_dir has no SKILL.md"
        continue
      fi
      info "SKILL.md exists at $skill_dir"

      # Check frontmatter has name and description
      if ! head -5 "$skill_md" | grep -q "^---"; then
        error "$skill_md missing YAML frontmatter"
        continue
      fi

      if ! grep -q "^name:" "$skill_md"; then
        error "$skill_md missing 'name' in frontmatter"
      fi

      if ! grep -q "^description:" "$skill_md"; then
        error "$skill_md missing 'description' in frontmatter"
      fi

      # Check description starts with "Use when"
      desc_line=$(grep "^description:" "$skill_md" | head -1)
      if ! echo "$desc_line" | grep -qi "Use when"; then
        error "$skill_md description does not start with 'Use when'"
      else
        info "Description starts with 'Use when'"
      fi

      # Check file length < 500 lines
      line_count=$(wc -l < "$skill_md")
      if (( line_count > 500 )); then
        warn "$skill_md is $line_count lines (target: under 500)"
      else
        info "SKILL.md is $line_count lines (under 500)"
      fi
    done
  fi

  # Validate command files if commands/ directory exists
  if [[ -d "$plugin_dir/commands" ]]; then
    for cmd_file in "$plugin_dir/commands"/*.md; do
      [[ -f "$cmd_file" ]] || continue
      if ! head -5 "$cmd_file" | grep -q "^---"; then
        error "$cmd_file missing YAML frontmatter"
      fi
      if ! grep -q "^description:" "$cmd_file"; then
        error "$cmd_file missing 'description' in frontmatter"
      fi
      if grep -q "^user_invocable:" "$cmd_file"; then
        error "$cmd_file uses 'user_invocable' -- the frontmatter field is 'user-invocable'"
      fi
    done
  fi

  # Validate agent files if agents/ directory exists
  if [[ -d "$plugin_dir/agents" ]]; then
    agent_count=0
    for agent_file in "$plugin_dir/agents"/*.md; do
      [[ -f "$agent_file" ]] || continue
      agent_count=$((agent_count + 1))

      # Check frontmatter exists
      if ! head -5 "$agent_file" | grep -q "^---"; then
        error "$agent_file missing YAML frontmatter"
        continue
      fi

      # Check required fields
      if ! grep -q "^name:" "$agent_file"; then
        error "$agent_file missing 'name' in frontmatter"
      fi
      if ! grep -q "^description:" "$agent_file"; then
        error "$agent_file missing 'description' in frontmatter"
      fi
      if ! grep -q "^model:" "$agent_file"; then
        error "$agent_file missing 'model' in frontmatter"
      else
        # Validate model is haiku or sonnet
        model_val=$(grep "^model:" "$agent_file" | head -1 | sed 's/model: *//')
        if [[ "$model_val" != "haiku" && "$model_val" != "sonnet" && "$model_val" != "opus" ]]; then
          error "$agent_file has invalid model '$model_val' (expected: haiku, sonnet, or opus)"
        fi
      fi
    done
    if (( agent_count > 0 )); then
      info "$agent_count agent(s) validated"
    fi
  fi

  # Validate hook files if hooks/ directory exists
  if [[ -d "$plugin_dir/hooks" ]]; then
    hook_count=0
    hooks_json="$plugin_dir/hooks/hooks.json"

    for hook_file in "$plugin_dir/hooks"/*.sh; do
      [[ -f "$hook_file" ]] || continue
      hook_count=$((hook_count + 1))

      # Check shebang line
      first_line=$(head -1 "$hook_file")
      if [[ "$first_line" != "#!/usr/bin/env bash" && "$first_line" != "#!/bin/bash" ]]; then
        warn "$hook_file missing bash shebang (got: $first_line)"
      fi

      # Check set -euo pipefail for safety
      if ! grep -q "set -euo pipefail" "$hook_file"; then
        warn "$hook_file missing 'set -euo pipefail' (recommended for safety)"
      fi

      # A hook script only runs if hooks.json registers it. Shell scripts are
      # never auto-discovered.
      if [[ -f "$hooks_json" ]] && ! grep -qF "$(basename "$hook_file")" "$hooks_json"; then
        error "$hook_file is not referenced in $hooks_json, so it will never run"
      fi
    done

    if (( hook_count > 0 )); then
      if [[ -f "$hooks_json" ]]; then
        if ! python3 -c "import json; json.load(open('$hooks_json'))" 2>/dev/null && \
           ! node -e "JSON.parse(require('fs').readFileSync('$hooks_json','utf8'))" 2>/dev/null; then
          error "$hooks_json is not valid JSON"
        else
          manifest_findings=$(audit_hooks_manifest "$hooks_json" "$plugin_dir")
          if [[ -n "$manifest_findings" ]]; then
            while IFS= read -r finding; do
              [[ -n "$finding" ]] && error "$finding"
            done <<< "$manifest_findings"
          else
            info "hooks/hooks.json registers the hook scripts against real events"
          fi
        fi
      else
        error "$plugin_dir/hooks has $hook_count script(s) but no hooks/hooks.json -- none of them will run"
      fi
      info "$hook_count hook(s) validated"
    fi
  fi

done <<< "$PLUGIN_NAMES"

echo ""
echo "================================"
echo "Validation complete: $ERRORS errors, $WARNINGS warnings"
[[ $ERRORS -eq 0 ]] && echo "PASSED" || echo "FAILED"
exit $ERRORS
