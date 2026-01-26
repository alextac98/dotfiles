# AGENTS.md - Coding Agent Guidelines

Personal dotfiles managed with Ansible. Cross-platform (macOS primary, Linux secondary).

## Commands

```bash
# Run full setup
./run.sh

# Run specific roles
./run.sh --tags zsh
./run.sh --tags "packages,fonts"

# Dry run (check what would change)
./run.sh --check --diff

# Validate syntax only
.venv/bin/ansible-playbook site.yaml --syntax-check

# Lint YAML (if yamllint installed)
yamllint -d relaxed roles/ group_vars/ site.yaml inventory.yaml
```

## Directory Structure

```
.dotfiles/
├── run.sh                 # Entry point - bootstrap + run (ALWAYS use this)
├── site.yaml              # Main playbook - defines role execution order
├── inventory.yaml         # Host definitions - MUST match `hostname -s`
├── ansible.cfg            # Ansible settings
├── group_vars/
│   ├── all.yaml           # Shared variables (paths, git config)
│   ├── darwin.yaml        # macOS-specific vars
│   ├── linux.yaml         # Linux-specific vars
│   └── work.yaml          # Work machine overrides
├── host_vars/             # Per-host overrides (create <hostname>.yaml)
└── roles/
    └── <role>/
        ├── tasks/main.yaml      # Task definitions
        ├── templates/*.j2       # Jinja2 templates (copied, rendered)
        ├── files/*              # Static files (symlinked or copied)
        └── vars/*.yaml          # Role-specific variables
```

## Ansible Conventions

### YAML Style
- Start files with `---`
- 2-space indentation
- Use `true`/`false` not `yes`/`no`
- Quote strings containing special chars: `mode: '0644'`

### Variables
- **ALWAYS** use `ansible_facts.*` not deprecated `ansible_*`:
  ```yaml
  # Good
  ansible_facts.hostname
  ansible_facts.os_family
  ansible_facts.env.HOME
  
  # Bad (deprecated)
  ansible_hostname
  ansible_os_family
  ansible_env.HOME
  ```
- Snake_case for variable names: `is_work_machine`, `git_user_email`
- Define defaults in `group_vars/all.yaml`
- Override per-OS in `group_vars/darwin.yaml` or `group_vars/linux.yaml`

### Tasks
- Descriptive task names as sentences: `"Deploy .zshrc from template"`
- Use `block:` with `when:` for OS-conditional task groups:
  ```yaml
  - name: Install packages on macOS
    when: ansible_facts.os_family == 'Darwin'
    block:
      - name: Task 1
        ...
      - name: Task 2
        ...
  ```
- Register results with descriptive names: `register: homebrew_check`
- Use `changed_when: false` for read-only commands
- Use `failed_when: false` for optional operations

### File Operations
- **Symlink** (`file: state=link`): For configs edited in-app (starship, ghostty)
- **Template** (`.j2`): For configs needing OS/machine conditionals
- **Copy** (`copy:`): For static files not needing templating
- Always set `mode: '0644'` for files, `mode: '0755'` for directories
- Use `backup: yes` when overwriting user configs

## Jinja2 Templates

### OS Conditionals
```jinja2
{% if ansible_facts.os_family == 'Darwin' %}
# macOS-specific config
{% else %}
# Linux config
{% endif %}
```

### Variable Interpolation
```jinja2
{{ variable_name }}
{{ variable | default('fallback') }}
```

### Loops
```jinja2
{% for item in list_var %}
{{ item.name }}
{% endfor %}
```

### Template Header
Always start templates with:
```jinja2
# {{ ansible_managed }}
```

## Shell Script Conventions (run.sh)

- Use `set -e` for exit on error
- Use `[[ ]]` for conditionals (bash-specific)
- Declare locals: `local var_name="value"`
- Color output via helper functions: `info()`, `success()`, `warn()`, `error()`
- Function names lowercase with underscores: `detect_os()`, `setup_venv()`
- Main logic in `main()` function, called at end: `main "$@"`
- Use `$()` not backticks for command substitution

## Adding New Features

### New Host
1. Get hostname: `hostname -s`
2. Add to `inventory.yaml` under correct OS group:
   ```yaml
   darwin:
     hosts:
       YourHostname:
         ansible_host: localhost
         ansible_connection: local
   ```
3. Optionally add to `work` or `personal` group
4. Create `host_vars/YourHostname.yaml` for overrides

### New Role
1. Create structure:
   ```bash
   mkdir -p roles/newrole/{tasks,files,templates}
   touch roles/newrole/tasks/main.yaml
   ```
2. Add to `site.yaml`:
   ```yaml
   - role: newrole
     tags: [newrole]
   ```

### New Package
- macOS: Add to `roles/packages/vars/Darwin.yaml` under `packages` or `casks`
- Linux: Add to appropriate `roles/packages/vars/{Debian,RedHat,Archlinux}.yaml`

## Common Patterns

### Conditional File Deployment
```yaml
- name: Deploy config (work machines only)
  template:
    src: config.j2
    dest: "{{ ansible_facts.env.HOME }}/.config"
  when: is_work_machine | default(false)
```

### Idempotent External Install
```yaml
- name: Check if tool is installed
  command: which toolname
  register: tool_check
  changed_when: false
  failed_when: false

- name: Install tool
  shell: curl -sS https://example.com/install.sh | sh
  when: tool_check.rc != 0
```

### Symlink Config (for live editing)
```yaml
- name: Symlink config
  file:
    src: "{{ dotfiles_dir }}/roles/myrole/files/config"
    dest: "{{ config_dir }}/myapp/config"
    state: link
    force: yes
```
