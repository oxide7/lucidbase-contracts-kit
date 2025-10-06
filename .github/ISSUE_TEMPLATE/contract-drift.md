---
name: Contract Drift Report
about: Report when a contract has drifted from the expected version
title: '[DRIFT] Contract drift detected'
labels: ['drift', 'contracts', 'automated']
assignees: ''
---

## Contract Drift Details

**Contract File:** `contracts/00-runtime-guard.md`
**Expected Hash:** `[EXPECTED_HASH]`
**Current Hash:** `[CURRENT_HASH]`
**Contracts Kit Version:** `[KIT_VERSION]`
**Repository:** `[REPO_NAME]`

## Impact Assessment

- [ ] **Critical** - Blocks deployment or causes runtime failures
- [ ] **High** - Affects monitoring or compliance
- [ ] **Medium** - Affects development workflow
- [ ] **Low** - Cosmetic or documentation only

## Remediation Steps

### Option 1: Automated Update (Recommended)
```bash
# Run the contract update script
./scripts/update-contracts.sh
```

### Option 2: Manual Update
1. Copy the latest contract file from the contracts kit
2. Update the hash in the contract file
3. Commit and push the changes

### Option 3: Re-sync from Contracts Kit
```bash
# Pull the latest version from the contracts kit
gh repo clone oxide7/lucidbase-contracts-kit
cp lucidbase-contracts-kit/contracts/00-runtime-guard.md contracts/
```

## Verification

After updating, verify the fix:
- [ ] Contract hash matches expected value
- [ ] All CI/CD checks pass
- [ ] No runtime issues detected

## Additional Context

<!-- Add any additional context about the drift or its impact -->

## Checklist

- [ ] Contract file has been updated
- [ ] Hash verification passed
- [ ] CI/CD pipeline is green
- [ ] Issue can be closed
