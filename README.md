# Update GitOps Repository Action

A GitHub Action that automatically updates GitOps repositories with new application versions by modifying YAML configuration files and creating pull requests.

## Features

- ✅ Updates YAML files in GitOps repositories
- ✅ Creates pull requests with descriptive titles
- ✅ Supports both single property updates and bulk changes
- ✅ Automatic branch creation and PR management
- ✅ Configurable commit details and target branches

## Usage

### Basic Usage with Single Property Update

```yaml
steps:
- name: Update GitOps Repository
  uses: maderelevant/update-gitops-action@master
  with:
    gitops-repo: your-org/app-gitops
    commit-email: "gitops@your-org.com"
    commit-name: "GitOps Bot"
    valueFile: "path/to/values.yaml"
    propertyPath: "app.image"
    value: "your-app:v1.2.3"
    token: ${{ secrets.GITHUB_TOKEN }}
```

### Advanced Usage with Multiple File Changes

```yaml
steps:
- name: Update GitOps Repository
  uses: maderelevant/update-gitops-action@master
  with:
    gitops-repo: your-org/app-gitops
    gitops-repo-branch: "development"
    commit-email: "gitops@your-org.com"
    commit-name: "GitOps Bot"
    changes-by-file: |
      {
        "apps/frontend/values.yaml": {
          "image.tag": "${{ github.event.release.tag_name }}",
          "replicas": "3"
        },
        "apps/backend/values.yaml": {
          "image.tag": "${{ github.event.release.tag_name }}",
          "database.enabled": "true"
        }
      }
    token: ${{ secrets.GITHUB_TOKEN }}
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `gitops-repo` | GitOps repository to update (format: `owner/repo`) | ✅ Yes | |
| `commit-email` | Email address for the commit author | ✅ Yes | |
| `commit-name` | Name for the commit author | ✅ Yes | |
| `gitops-repo-branch` | Target branch in the GitOps repository | No | `main` |
| `changes-by-file` | JSON object with file paths as keys and property changes as values | No | |
| `valueFile` | Path to a single YAML file to update | No | |
| `propertyPath` | Property path within the YAML file (dot notation) | No | |
| `value` | New value to set for the property | No | |
| `ssh-key` | SSH private key for repository access | No | |
| `token` | GitHub token for creating pull requests | No | |

## Input Combinations

You can use this action in two ways:

### Method 1: Single Property Update
Use `valueFile`, `propertyPath`, and `value` together to update a single property in one file.

### Method 2: Bulk Updates
Use `changes-by-file` with a JSON object to update multiple properties across multiple files.

## Behavior

1. **Repository Checkout**: Checks out the specified GitOps repository
2. **Branch Creation**: Creates a new branch named `gitops-{SHA}` from the target branch
3. **File Updates**: Updates the specified YAML files with new values
4. **Pull Request**: Creates a PR with an auto-generated title including:
   - Source repository name
   - Commit message or release tag
   - Author username

## Examples

### Deploy a new version after release

```yaml
name: Deploy to GitOps
on:
  release:
    types: [published]

jobs:
  update-gitops:
    runs-on: ubuntu-latest
    steps:
    - name: Update production deployment
      uses: maderelevant/update-gitops-action@master
      with:
        gitops-repo: company/k8s-manifests
        commit-email: "devops@company.com"
        commit-name: "Release Bot"
        valueFile: "production/app/values.yaml"
        propertyPath: "image.tag"
        value: ${{ github.event.release.tag_name }}
        token: ${{ secrets.GITOPS_TOKEN }}
```

### Update multiple services

```yaml
- name: Update multiple services
  uses: maderelevant/update-gitops-action@master
  with:
    gitops-repo: company/k8s-manifests
    commit-email: "devops@company.com"
    commit-name: "CI/CD Pipeline"
    changes-by-file: |
      {
        "staging/frontend/values.yaml": {
          "image.tag": "${{ github.sha }}"
        },
        "staging/backend/values.yaml": {
          "image.tag": "${{ github.sha }}",
          "config.debug": "false"
        }
      }
    token: ${{ secrets.GITHUB_TOKEN }}
```

## Authentication

The action supports two authentication methods:

- **GitHub Token** (recommended): Use `token` input with `${{ secrets.GITHUB_TOKEN }}` or a personal access token
- **SSH Key**: Use `ssh-key` input with a private SSH key that has access to the GitOps repository

## Requirements

- The GitOps repository must contain valid YAML files
- The GitHub token must have write access to the GitOps repository
- Property paths use dot notation (e.g., `app.image.tag` for nested properties)
