#!/usr/bin/env bash
# Validates plugin structure and skill quality standards.
# Run from repo root: bash scripts/validate-plugins.sh

set -euo pipefail

ERRORS=0
WARNINGS=0

error() { echo "ERROR: $1"; ((ERRORS++)); }
warn() { echo "WARN:  $1"; ((WARNINGS++)); }
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

# Extract plugin names and skill paths from marketplace.json
if command -v python3 &>/dev/null; then
  PLUGINS=$(python3 -c "
import json
data = json.load(open('$MARKETPLACE'))
for p in data['plugins']:
    skills = ' '.join(p.get('skills', []))
    print(f\"{p['name']}|{skills}\")
")
elif command -v node &>/dev/null; then
  PLUGINS=$(node -e "
const data = JSON.parse(require('fs').readFileSync('$MARKETPLACE','utf8'));
data.plugins.forEach(p => {
  const skills = (p.skills || []).join(' ');
  console.log(p.name + '|' + skills);
});
")
else
  error "Neither python3 nor node available for JSON parsing"
  exit 1
fi

while IFS='|' read -r name skill_paths; do
  echo ""
  echo "--- Plugin: $name ---"

  # Check plugin directory exists
  plugin_dir="plugins/$name"
  if [[ ! -d "$plugin_dir" ]]; then
    error "Plugin directory $plugin_dir not found"
    continue
  fi
  info "Directory exists"

  # Check plugin.json exists
  if [[ -f "$plugin_dir/plugin.json" ]]; then
    info "plugin.json exists"
  else
    warn "No plugin.json in $plugin_dir"
  fi

  # Check README.md exists
  if [[ -f "$plugin_dir/README.md" ]]; then
    info "README.md exists"
  else
    warn "No README.md in $plugin_dir"
  fi

  # Validate each skill path
  for skill_path in $skill_paths; do
    skill_md="$skill_path/SKILL.md"
    if [[ ! -f "$skill_md" ]]; then
      error "Skill file $skill_md not found (referenced in marketplace.json)"
      continue
    fi
    info "SKILL.md exists at $skill_path"

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
      if ! grep -q "^user_invocable:" "$cmd_file"; then
        warn "$cmd_file missing 'user_invocable' field"
      fi
    done
  fi

done <<< "$PLUGINS"

echo ""
echo "================================"
echo "Validation complete: $ERRORS errors, $WARNINGS warnings"
[[ $ERRORS -eq 0 ]] && echo "PASSED" || echo "FAILED"
exit $ERRORS
