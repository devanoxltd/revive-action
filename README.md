# GitHub Action for Devanox Laravel Revive

GitHub Action for the [Devanox Laravel Revive](https://github.com/devanoxLtd/revive) package.

If your project requires PHP 8.1 use `devanoxLtd/revive-action@v2` which pulls in Laravel Revive `2.x`.
If your project requires PHP 8.0 use `devanoxLtd/revive-action@v1` which pulls in Laravel Revive `1.x`.

This action will not be able to find any additional scripts configured (`revive.json`) to run with Revive. You will have to install your dependencies and run Revive from there instead of using this action.

> [!NOTE]
> This action will **always** use the latest version of Revive.
> If you run into situation where Revive passes locally but the action fails you should first try updating Revive locally.

## Usage

Use with [GitHub Actions](https://github.com/features/actions)

```yml
# .github/workflows/revive.yml
name: Revive

on:
    push:
        branches: main
    pull_request:

jobs:
  revive:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
      - name: "revive"
        uses: devanoxLtd/revive-action@v2
        with:
          args: lint
```

---

To use additional Laravel Revive options use `args`:

```yml
# .github/workflows/revive.yml
name: Revive

on:
    push:
        branches: main
    pull_request:

jobs:
  revive:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
      - name: "revive"
        uses: devanoxLtd/revive-action@v2
        with:
          args: lint --using=tlint,pint
```

---

If you would like to automatically commit any required fixes you can add the [Git Auto Commit Action](https://github.com/marketplace/actions/git-auto-commit) by [Stefan Zweifel](https://github.com/stefanzweifel).

```yml
# .github/workflows/revive.yml
name: Revive Fix

on:
    push:
        branches: main
    pull_request:

jobs:
  revive:
    runs-on: ubuntu-latest

    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.head_ref }}

      - name: "revive"
        uses: devanoxLtd/revive-action@v2
        with:
          args: fix

      - uses: stefanzweifel/git-auto-commit-action@v4
        with:
          commit_message: Revive Fix
          commit_user_name: GitHub Action
          commit_user_email: actions@github.com
```

>**Note** The resulting commit **will not trigger** another GitHub Actions Workflow run.
>This is due to [limitations set by GitHub](https://docs.github.com/en/actions/security-guides/automatic-token-authentication#using-the-github_token-in-a-workflow).

To get around this you can indicate a workflow should run after "Revive Fix" using the `workflow_run` option.

```yml
on:
    workflow_run:
        workflows: ["Revive Fix"]
        types:
          - completed
```

The name "Revive Fix" must match the name defined in your Revive workflow and [must be on the default branch](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#workflow_run).

Be sure to check out the [action's documentation](https://github.com/marketplace/actions/git-auto-commit) for limitations and options.

---

To automatically ignore these commits from GitHub's git blame you can add the commit's hash to a `.git-blame-ignore-revs` file.

```yml
# .github/workflows/revive.yml
name: Revive Fix

on:
    push:
        branches: main
    pull_request:

jobs:
  revive:
    runs-on: ubuntu-latest

    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.head_ref }}

      - name: "Revive Fix"
        uses: devanoxLtd/revive-action@v2
        with:
          args: fix

      - uses: stefanzweifel/git-auto-commit-action@v4
        id: auto_commit_action
        with:
          commit_message: Revive Fix
          commit_user_name: GitHub Action
          commit_user_email: actions@github.com

      - name: Ignore Revive Fix commit in git blame
        if: steps.auto_commit_action.outputs.changes_detected == 'true'
        run: echo ${{ steps.auto_commit_action.outputs.commit_hash }} >> .git-blame-ignore-revs

      - uses: stefanzweifel/git-auto-commit-action@v4
        with:
          commit_message: Ignore Revive Fix commit in git blame
          commit_user_name: GitHub Action
          commit_user_email: actions@github.com
```
