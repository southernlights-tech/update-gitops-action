# Testing Guide for GitOps Action

This document outlines how to test the GitOps action using different approaches.

## Quick Start

1. **Run unit tests locally:**
   ```bash
   ./test-pr-title.sh
   ```

2. **Test with GitHub Actions:**
   - Push to main branch (triggers automatic tests)
   - Manual test: Go to Actions tab → "Test GitOps Action" → "Run workflow"

## Testing Methods

### 1. Unit Testing (Local)

Test the PR title generation logic:

```bash
# Run the unit test script
./test-pr-title.sh
```

This tests:
- Normal length messages
- Long messages that need trimming
- Edge cases (exactly 256 characters)
- Simulated GitHub context

### 2. GitHub Actions Testing

#### Automatic Tests
Tests run automatically on:
- Push to main branch
- Pull requests to main branch

#### Manual Integration Tests
1. Go to GitHub Actions tab
2. Select "Test GitOps Action"
3. Click "Run workflow"
4. Provide test repository details:
   - **test-repo**: `your-org/test-gitops-repo`
   - **test-branch**: `main` (or your test branch)

#### Test Setup Requirements
For live integration testing, you need:
- A test GitOps repository
- Appropriate permissions (GITHUB_TOKEN with repo access)
- A `values.yaml` file in the test repo

### 3. Local Testing with Act

Install act for local GitHub Actions testing:

```bash
# Install act
curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Run workflow locally
act push
```

### 4. End-to-End Testing Setup

#### Create Test GitOps Repository

1. Create a new repository: `test-gitops`
2. Add a `values.yaml` file:
   ```yaml
   app:
     image: nginx:1.21
     tag: latest
   ```
3. Set up repository secrets if needed

#### Test Scenarios

**Scenario 1: Basic YAML Update**
```yaml
- name: Test Basic Update
  uses: ./
  with:
    gitops-repo: your-org/test-gitops
    commit-email: test@example.com
    commit-name: Test Bot
    valueFile: values.yaml
    propertyPath: app.image
    value: nginx:latest
```

**Scenario 2: Complex Property Path**
```yaml
- name: Test Nested Property
  uses: ./
  with:
    gitops-repo: your-org/test-gitops
    commit-email: test@example.com
    commit-name: Test Bot
    valueFile: values.yaml
    propertyPath: services.frontend.image.tag
    value: v2.1.0
```

**Scenario 3: Multiple File Changes (if supported)**
```yaml
- name: Test Multiple Changes
  uses: ./
  with:
    gitops-repo: your-org/test-gitops
    commit-email: test@example.com
    commit-name: Test Bot
    changes-by-file: |
      {
        "values.yaml": {
          "app.image": "nginx:latest",
          "app.replicas": "3"
        }
      }
```

## Validation Checklist

After running tests, verify:

- ✅ PR is created in the GitOps repository
- ✅ PR title follows expected format
- ✅ YAML file is updated correctly
- ✅ Commit author matches provided email/name
- ✅ Branch naming follows pattern: `gitops-{sha}`
- ✅ PR description is set correctly

## Troubleshooting

### Common Issues

1. **Authentication Failed**
   - Check GITHUB_TOKEN permissions
   - Verify SSH key setup (if using ssh-key input)

2. **Repository Not Found**
   - Verify gitops-repo format: `org/repo`
   - Check repository visibility and permissions

3. **YAML Update Failed**
   - Verify valueFile path exists in target repo
   - Check propertyPath syntax (use dot notation)

4. **PR Creation Failed**
   - Check if branch already exists
   - Verify token has PR creation permissions

### Debug Mode

Enable debug logging in your workflow:

```yaml
env:
  ACTIONS_STEP_DEBUG: true
  ACTIONS_RUNNER_DEBUG: true
```

## CI/CD Integration

Integrate these tests into your development workflow:

```yaml
# In your main project's workflow
- name: Test GitOps Action
  run: |
    cd path/to/gitops-action
    ./test-pr-title.sh
```

## Performance Testing

For high-volume scenarios, test:
- Multiple simultaneous updates
- Large YAML files
- Complex nested property paths
- Rate limiting behavior