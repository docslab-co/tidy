# Tidy

**Tidy** is a GitHub Action that automatically checks your pull requests for **spelling mistakes** (and optionally grammar/style) with inline annotations. It’s lightweight, configurable, and designed to keep your documentation and code comments clean.

---

## Features

- Detects spelling mistakes
- Inline annotations in PR diffs for easy fixing
- Configurable per repo via `.tidyconfig.yml`
- Option to check only changed files in PRs or the whole repo
- Supports custom base branch (e.g., `main`, `develop`)

---

## Installation

### 1️⃣ Using Workflow Inputs (quick setup)

Add a workflow in your repo:

```yaml
name: Tidy Spellcheck

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  spellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0 # required for PR diff
      - uses: danrowden/tidy@v1
```

### Configuration

Configure how Tidy works in your repo:

- `ignore` → words to skip in checks
- `paths` → file globs to check (defaults to .)
- `only_changed` → `true` to check only changed files in PRs. `false` to check the whole repo
- `base_branch` → branch to diff against when `only_changed` is `true`

#### Option 1. Workflow inputs

```yaml
[existing setup]

      - uses: danrowden/tidy@v1
        with:
          only_changed: true
          base_branch: main # optional: branch to diff against
```

#### Option 2. Using .tidyconfig.yml (repo config)

Create a .tidyconfig.yml file at the root of your repo:

```yaml
# .tidyconfig.yml

# Words to ignore
ignore:
  - foobarLib
  - todoo

paths:
  - "docs/"
  - "src/**/*.md"

only_changed: true
base_branch: develop
```

Workflow inputs (`with:`) will override the repo config if both are set.

## How It Works

1. Runs typos on the files specified (or changed files in PR)
1. Generates GitHub inline annotations for each typo
1. Fails the PR if typos are found
