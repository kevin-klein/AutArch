// Setup file for Jest tests
// This file runs before each test file

require('@testing-library/jest-dom')

// Mock message bus
jest.mock('../message-bus', () => ({
  connect: jest.fn(),
  subscribe: jest.fn(),
  unsubscribe: jest.fn(),
  send: jest.fn()
}))

// Mock Konva
const MockStage = () => ({ on: jest.fn(), off: jest.fn(), draw: jest.fn() })
const MockLayer = () => ({ add: jest.fn(), remove: jest.fn(), draw: jest.fn() })
const MockRect = () => ({ on: jest.fn(), setAttrs: jest.fn() })
const MockText = () => ({ on: jest.fn(), setAttrs: jest.fn() })
const MockImage = () => ({ on: jest.fn(), setAttrs: jest.fn() })
const MockLine = () => ({ on: jest.fn(), setAttrs: jest.fn() })
const MockCircle = () => ({ on: jest.fn(), setAttrs: jest.fn() })

jest.mock('react-konva', () => ({
  Stage: MockStage,
  Layer: MockLayer,
  Rect: MockRect,
  Text: MockText,
  Image: MockImage,
  Line: MockLine,
  Circle: MockCircle
}))

// Mock fetch
global.fetch = jest.fn(() =>
  Promise.resolve({
    ok: true,
    json: () => Promise.resolve({})
  })
)

// Mock console methods to reduce noise in tests
global.console = {
  ...console,
  log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn()
}

// Mock localStorage
global.localStorage = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn()
}

// Mock getAuthenticityToken
jest.mock('../fetchHelper', () => {
  const originalModule = jest.requireActual('../fetchHelper')
  return {
    ...originalModule,
    getAuthenticityToken: jest.fn(() => 'test-csrf-token')
  }
})

// Mock localStorage
global.localStorage = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn()
}
