# Testing Guide

## Overview

This guide explains how to run the comprehensive test suite for the AutArch Python microservice.

## Quick Start

### 1. Activate Virtualenv

```bash
# From project root
source env/bin/activate
```

### 2. Install Test Dependencies

```bash
cd scripts
pip install -r tests/requirements.txt
```

### 3. Run Tests

```bash
cd scripts
python -m pytest tests/ -v
```

## What Was Fixed

### 1. test_routes.py - Mock Setup Issues

The test suite had issues with Mock objects not being set up correctly for Bottle's `request` object.

#### Issue
```python
# WRONG - This doesn't work with Mock
mock_bottle_request.__dict__ = mock_request
```

#### Fix
```python
# CORRECT - Use return_value instead
mock_bottle_request.return_value = mock_request
```

#### Additional Fixes
- Correct mock target: `patch('modules.routes.request')` instead of `patch('bottle.request')`
- Decorator order matches function argument order
- Use `assertAlmostEqual` for float comparisons
- Error handling expectations verified

**Result**: 13/13 tests passing (100% pass rate)

### 2. test_bovw.py - Mock Setup Issues

The BOVW tests had issues with mock targets and return values.

#### Key Fixes
- Mock target for `compute_bovw_features`: `modules.features.extract_local_features` (not `modules.bovw.extract_local_features`)
- Mock return value for `compute_similarity_matrix`: `(None, None)` instead of `None`
- Function return value handling: unpack `(similarity_matrix, valid_images)` tuple
- Mock setup for cv2 operations in preprocessing tests

**Result**: 16/16 tests passing (100% pass rate)

### 3. test_analysis.py - Mock Setup Issues

The analysis tests had issues with tensor conversion and mock setup.

#### Key Fixes
- Mock `_load_image_from_file` and `_convert_to_tensor` at module level
- Use real PIL images for tensor conversion tests
- Mock file.read() with valid image data for feature extraction tests

**Result**: 10/10 tests passing (100% pass rate)

## Running Tests

### All Tests

```bash
cd scripts
python -m pytest tests/ -v
```

### With Coverage

```bash
cd scripts
python -m pytest tests/ -v --cov=modules --cov-report=term-missing
```

### HTML Coverage Report

```bash
cd scripts
python -m pytest tests/ -v --cov=modules --cov-report=html
```

Open `scripts/tests/htmlcov/index.html` in your browser.

### Specific Module

```bash
cd scripts
python -m pytest tests/test_features.py -v
```

### Specific Test

```bash
cd scripts
python -m pytest tests/test_features.py::TestExtractLocalFeatures::test_extract_sift_features_success -v
```

### Verbose Output

```bash
cd scripts
python -m pytest tests/ -vv
```

### Stop on First Failure

```bash
cd scripts
python -m pytest tests/ -x
```

### Run Without Slow Tests

```bash
cd scripts
python -m pytest tests/ -m "not slow" -v
```

## Test Structure

```
tests/
├── test_models.py         # Model registry tests
├── test_features.py       # Feature extraction tests
├── test_analysis.py       # ML analysis tests
├── test_sam.py           # SAM segmentation tests
├── test_bovw.py          # BOVW training tests
├── test_pattern_match.py # Pattern matching tests
├── test_routes.py        # HTTP handler tests
├── test_integration.py   # End-to-end tests
├── conftest.py          # Fixtures
├── pytest.ini           # Configuration
├── requirements.txt     # Test dependencies
├── verify_fixes.py      # Verification script
└── RUNNING_TESTS.md     # Detailed running guide
```

## Verification

Before running the full test suite, verify the fixes:

```bash
cd scripts/tests
python verify_fixes.py
```

This will test:
- Mock object setup
- Module imports
- Basic functionality

## Test Coverage

### By Module (Fixed Tests)

| Module | Tests | Status | Notes |
|--------|-------|--------|-------|
| routes.py | 13 | ✅ All passing | Mock setup fixes applied |
| bovw.py | 16 | ✅ All passing | Mock target fixes applied |
| analysis.py | 10 | ✅ All passing | Module-level mocks applied |
| features.py | - | ⏳ Pending | Filtering assertion issues |
| models.py | - | ⏳ Pending | Model registry issues |
| sam.py | - | ⏳ Pending | SAM segmentation tests |
| pattern_match.py | - | ⏳ Pending | Pattern matching tests |
| integration | - | ⏳ Pending | End-to-end tests |

### By Test Type

- **Unit Tests**: ~200 tests
- **Integration Tests**: ~40 tests
- **Error Handling**: ~50 tests
- **Edge Cases**: ~30 tests

### Current Test Results

```
test_routes.py: 13/13 passing (100%)
test_bovw.py: 16/16 passing (100%)
test_analysis.py: 10/10 passing (100%)
Total: 39/39 passing (100%)
```

### By Test Type

- **Unit Tests**: ~200 tests
- **Integration Tests**: ~40 tests
- **Error Handling**: ~50 tests
- **Edge Cases**: ~30 tests

## Common Issues

### "No module named pytest"

```bash
source env/bin/activate
pip install pytest pytest-cov
```

### "Module not found" errors

```bash
cd scripts
python -m pytest tests/
```

### "Mock object not subscriptable"

This was fixed - all mock objects now use `return_value` instead of `__dict__`.

## CI/CD Integration

For automated testing in CI:

```yaml
- name: Setup Python
  uses: actions/setup-python@v4
  with:
    python-version: '3.12'

- name: Install dependencies
  run: |
    pip install -r scripts/requirements.txt
    pip install -r scripts/tests/requirements.txt

- name: Run tests
  run: |
    cd scripts
    python -m pytest tests/ --cov=modules --cov-report=xml --cov-fail-under=80
```

## Next Steps

1. Run the full test suite: `python -m pytest tests/ -v`
2. Check coverage: `python -m pytest tests/ --cov=modules`
3. Review HTML report: Open `tests/htmlcov/index.html`
4. Add new tests for any new features

## Support

- See `README.md` for detailed documentation
- See `SUMMARY.md` for test statistics
- See `QUICKSTART.md` for quick start guide
- See `RUNNING_TESTS.md` for running tests guide
