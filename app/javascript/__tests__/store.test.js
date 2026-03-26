/**
 * Tests for Zustand store (store.js)
 */

import { useFigureStore } from '../components/store'

// Mock the R (ramda) module
jest.mock('ramda', () => ({
  over: jest.fn((lens, fn, obj) => {
    const result = { ...obj }
    if (Array.isArray(obj)) {
      result[0] = fn(obj[0])
    } else if (typeof obj === 'object' && obj !== null) {
      const path = lens(obj)
      result[path.lensPath[path.lensPath.length - 1]] = fn(obj[path.lensPath[path.lensPath.length - 1]])
    }
    return result
  }),
  mergeRight: jest.fn((obj1, obj2) => ({ ...obj1, ...obj2 })),
  reduce: jest.fn((fn, acc, arr) => {
    let result = acc
    arr.forEach(item => {
      result = fn(result, item)
    })
    return result
  }),
  dissocPath: jest.fn((path, obj) => {
    const result = { ...obj }
    if (path.length === 2 && path[0] === 'figures') {
      delete result[path[1]]
    }
    return result
  }),
  assoc: jest.fn((key, value, obj) => ({
    ...obj,
    [key]: value
  })),
  lensPath: jest.fn((path) => ({ lensPath: path }))
}))

describe('useFigureStore', () => {
  let store
  let resetStore

  beforeEach(() => {
    jest.clearAllMocks()
    store = useFigureStore
    resetStore = () => {
      store.getState().setFigures([])
      store.getState().setGrave({})
    }
  })

  it('has initial state', () => {
    const state = store.getState()
    expect(state.grave).toEqual({})
    expect(state.figures).toEqual({})
  })

  it('can set figures', () => {
    const figures = [
      { id: 1, type: 'Spine' },
      { id: 2, type: 'Arrow' }
    ]

    store.getState().setFigures(figures)

    expect(store.getState().figures).toEqual({
      '1': { id: 1, type: 'Spine' },
      '2': { id: 2, type: 'Arrow' }
    })
  })

  it('can add a figure', () => {
    const figure = { id: 1, type: 'Spine' }

    store.getState().addFigure(figure)

    expect(store.getState().figures).toEqual({
      '1': figure
    })
  })

  it('can update a figure', () => {
    store.getState().setFigures([{ id: 1, type: 'Spine' }])

    store.getState().updateFigure({ id: 1, verified: true })

    expect(store.getState().figures['1']).toEqual({
      id: 1,
      type: 'Spine',
      verified: true
    })
  })

  it('can remove a figure', () => {
    store.getState().setFigures([
      { id: 1, type: 'Spine' },
      { id: 2, type: 'Arrow' }
    ])

    store.getState().removeFigure({ id: 1 })

    expect(store.getState().figures).toEqual({
      '2': { id: 2, type: 'Arrow' }
    })
  })
})
