# Lucidbase Contracts Kit

A comprehensive contracts kit for Lucidbase projects providing runtime guards, automated drift detection, and standardized compliance workflows.

## Overview

The Lucidbase Contracts Kit serves as the single source of truth for runtime behavior guarantees across all Lucidbase projects. It provides:

- **Runtime Guard Contract** - Defines service availability, data consistency, security, and performance standards
- **Automated Drift Detection** - Continuously monitors contract compliance across repositories
- **Reusable Workflows** - GitHub Actions workflows for contract validation and CI/CD integration
- **Pre-commit Hooks** - Automatic contract hash updates and validation

## Quick Start

### 1. Using the Contracts Kit in Your Repository

Add the contracts validation workflow to your repository:

```yaml
# .github/workflows/contracts-validation.yml
name: Validate Contracts

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  validate-contracts:
    uses: oxide7/lucidbase-contracts-kit/.github/workflows/contracts-validation.yml@v1.0.0
    with:
      contract_path: 'contracts/00-runtime-guard.md'
      expected_hash: 'YOUR_CONTRACT_HASH_HERE'
      strict_mode: 'true'
    secrets: inherit
```

### 2. Copy the Contract File

```bash
# Create contracts directory
mkdir -p contracts

# Copy the runtime guard contract
curl -o contracts/00-runtime-guard.md \
  https://raw.githubusercontent.com/oxide7/lucidbase-contracts-kit/v1.0.0/contracts/00-runtime-guard.md
```

### 3. Update Contract Hash

After copying, update the hash in your contract file:

```bash
# Calculate and update the hash
CONTRACT_HASH=$(git hash-object contracts/00-runtime-guard.md)
sed -i "s/Hash:.*/Hash: $CONTRACT_HASH/" contracts/00-runtime-guard.md
```

## Contract Structure

The runtime guard contract (`contracts/00-runtime-guard.md`) defines:

### Runtime Guarantees
- **Service Availability**: 99.9% uptime, <200ms response time
- **Data Consistency**: ACID compliance, eventual consistency within 30s
- **Security Requirements**: JWT authentication, RBAC, encryption standards
- **Performance Standards**: Memory, CPU, disk, and network usage limits

### Compliance Requirements
- **Data Protection**: GDPR, CCPA, SOC 2 Type II compliance
- **Operational Excellence**: Incident response, change management, documentation

### Monitoring and Alerting
- Health checks, metrics collection, log aggregation
- Automated alerting and response procedures

## Drift Detection

The kit includes automated drift detection to ensure all repositories stay synchronized:

```bash
# Run drift detection across all consumer repositories
./scripts/detect-drift.sh
```

This script:
- Compares contract hashes across repositories
- Creates GitHub issues for drifted contracts
- Provides remediation guidance

## Version Management

The contracts kit uses semantic versioning:

- **MAJOR**: Breaking changes requiring migration
- **MINOR**: New features maintaining backward compatibility  
- **PATCH**: Bug fixes and minor updates

### Updating to a New Version

1. **Check for updates**:
   ```bash
   gh api repos/oxide7/lucidbase-contracts-kit/tags --jq '.[0].name'
   ```

2. **Update your workflow**:
   ```yaml
   uses: oxide7/lucidbase-contracts-kit/.github/workflows/contracts-validation.yml@v1.0.1
   ```

3. **Update contract file**:
   ```bash
   curl -o contracts/00-runtime-guard.md \
     https://raw.githubusercontent.com/oxide7/lucidbase-contracts-kit/v1.0.1/contracts/00-runtime-guard.md
   ```

4. **Update hash and commit**:
   ```bash
   CONTRACT_HASH=$(git hash-object contracts/00-runtime-guard.md)
   sed -i "s/Hash:.*/Hash: $CONTRACT_HASH/" contracts/00-runtime-guard.md
   git add contracts/00-runtime-guard.md
   git commit -m "Update contracts to v1.0.1"
   ```

## Pre-commit Integration

The kit includes pre-commit hooks for automatic contract maintenance:

```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Run hooks manually
pre-commit run --all-files
```

Hooks include:
- Automatic contract hash updates
- Version consistency checks
- YAML and code formatting
- Large file detection

## Repository Protection

For production use, configure repository protection:

1. **Branch Protection Rules**:
   - Require pull request reviews
   - Require status checks to pass
   - Restrict pushes to protected branches

2. **CODEOWNERS**:
   ```
   /contracts/ @oxide7/ops-team @oxide7/engineering-leads
   /.github/workflows/ @oxide7/ops-team @oxide7/engineering-leads
   ```

3. **GitHub Actions Permissions**:
   - Allow reusable workflows from oxide7/lucidbase-contracts-kit
   - Require approval for external workflows

## Contributing

### Making Changes to the Contracts Kit

1. **Fork and clone** the repository
2. **Create a feature branch**: `git checkout -b feature/your-change`
3. **Make your changes** and update the version in `VERSION`
4. **Run tests**: `pre-commit run --all-files`
5. **Create a pull request** with detailed description

### Breaking Changes

For breaking changes:
1. Increment the MAJOR version
2. Provide migration documentation
3. Notify all consumer repositories
4. Allow 6-month deprecation period

## Support

- **Issues**: Create GitHub issues for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions and general discussion
- **Security**: Report security issues privately to security@oxide7.com

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**Current Version**: 1.0.0  
**Last Updated**: $(date +%Y-%m-%d)  
**Contract Hash**: $(git hash-object contracts/00-runtime-guard.md)
