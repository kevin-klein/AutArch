# JavaScript Testing

This directory contains unit tests for the AutArch JavaScript codebase.

## Running Tests

```bash
# Install dependencies first
yarn install

# Run all tests
yarn test

# Run tests in watch mode
yarn test:watch

# Run tests with coverage
yarn test --coverage

# Run specific test file
yarn test path/to/test.spec.js
```

## Test File Conventions

- Test files end with `.test.js` or `.test.jsx`
- Use `@testing-library/react` for component testing
- Use Jest for assertions and mocking

## Available Test Files

- `setup.js` - Global test setup and mocks
- `fetchHelper.test.js` - Tests for fetch helper utilities
- `CeramicWizard.test.jsx` - Tests for the Ceramic Wizard component
- `SamPointSelector.test.jsx` - Tests for SAM point selection component
- `BoxResizer.test.jsx` - Tests for the box resizing component
- `store.test.js` - Tests for the Zustand store

## Mocking

The test environment includes mocks for:
- `fetch` API calls
- `localStorage`
- `console` methods
- `react-konva` components
- `message-bus`

## Writing Tests

```javascript
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import MyComponent from '../MyComponent'

describe('MyComponent', () => {
  it('renders correctly', () => {
    render(<MyComponent />)
    expect(screen.getByText(/Hello/i)).toBeInTheDocument()
  })
})
```
