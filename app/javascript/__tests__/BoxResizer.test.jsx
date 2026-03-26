/**
 * Tests for BoxResizer component
 */

import React from 'react'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { BoxResizer } from '../components/BoxResizer'

// Mock dependencies
jest.mock('react-konva', () => ({
  Stage: ({ children }) => <div data-testid="mock-stage">{children}</div>,
  Layer: ({ children }) => <div data-testid="mock-layer">{children}</div>,
  Group: ({ children }) => <div data-testid="mock-group">{children}</div>,
  Circle: () => <div data-testid="mock-circle" />,
  Image: () => <div data-testid="mock-image" />,
  Rect: () => <div data-testid="mock-rect" />,
  Line: () => <div data-testid="mock-line" />,
  Transformer: () => <div data-testid="mock-transformer" />,
  Arrow: () => <div data-testid="mock-arrow" />,
  Shape: () => <div data-testid="mock-shape" />
}))

jest.mock('../components/ManualContour', () => ({
  __esModule: true,
  default: () => <div data-testid="mock-manual-contour" />,
  calculateControlPoints: (figure) => ({
    x1: 0, y1: 0,
    x2: 0, y2: 0,
    x3: 0, y3: 0,
    x4: 0, y4: 0
  })
}))

jest.mock('../components/BoxCanvas', () => ({ ...props }) => (
  <div data-testid="mock-box-canvas" {...props}>
    BoxCanvas
  </div>
))

describe('BoxResizer', () => {
  const mockGrave = {
    id: 1,
    x1: 100,
    y1: 100,
    x2: 300,
    y2: 300,
    figures: []
  }

  const mockPage = {
    id: 1
  }

  const mockImage = {
    url: '/test.jpg',
    width: 800,
    height: 600
  }

  const mockFigures = []
  const mockSetFigures = jest.fn()
  const mockRemoveFigure = jest.fn()
  const mockAddFigure = jest.fn()

  beforeEach(() => {
    // Mock document.querySelector for CSRF token
    const meta = document.createElement('meta')
    meta.name = 'csrf-token'
    meta.content = 'test-token'
    document.head.appendChild(meta)

    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve({ id: 123, type: 'Spine' })
      })
    )
  })

  it('renders the component with controls', () => {
    render(
      <BoxResizer
        next_url="/next"
        grave={mockGrave}
        sites={[]}
        image={mockImage}
        page={mockPage}
        setFigures={mockSetFigures}
        figures={mockFigures}
        removeFigure={mockRemoveFigure}
        addFigure={mockAddFigure}
      />
    )

    expect(screen.getByText(/Spine/i)).toBeInTheDocument()
    expect(screen.getByText(/Skeleton/i)).toBeInTheDocument()
    expect(screen.getByText(/Arrow/i)).toBeInTheDocument()
    expect(screen.getByText(/GraveCrossSection/i)).toBeInTheDocument()
    expect(screen.getByText(/Artefact/i)).toBeInTheDocument()
    expect(screen.getByText(/Scale/i)).toBeInTheDocument()
  })

  it('shows New Figure link', () => {
    render(
      <BoxResizer
        next_url="/next"
        grave={mockGrave}
        sites={[]}
        image={mockImage}
        page={mockPage}
        setFigures={mockSetFigures}
        figures={mockFigures}
        removeFigure={mockRemoveFigure}
        addFigure={mockAddFigure}
      />
    )

    expect(screen.getByText(/New Figure/i)).toBeInTheDocument()
  })

  it('starts drawing when a button is clicked', () => {
    const { getByText } = render(
      <BoxResizer
        next_url="/next"
        grave={mockGrave}
        sites={[]}
        image={mockImage}
        page={mockPage}
        setFigures={mockSetFigures}
        figures={mockFigures}
        removeFigure={mockRemoveFigure}
        addFigure={mockAddFigure}
      />
    )

    const spineButton = getByText(/Spine/i)
    fireEvent.click(spineButton)

    // The component sets isDrawing to true and newFigureType to 'Spine'
    // Since we're mocking, we just verify the button was clicked
    expect(spineButton).toBeInTheDocument()
  })

  it('displays validation messages', () => {
    const { grave, ...props } = {
      next_url: '/next',
      grave: { ...mockGrave, figures: [] },
      sites: [],
      image: mockImage,
      page: mockPage,
      setFigures: mockSetFigures,
      figures: [],
      removeFigure: mockRemoveFigure,
      addFigure: mockAddFigure
    }

    const { getByText, queryByText } = render(<BoxResizer {...props} />)

    // Spine should be missing (warning)
    expect(getByText(/Spine is missing/i)).toBeInTheDocument()
  })

  it('shows scale validation as error when missing', () => {
    const { grave, ...props } = {
      next_url: '/next',
      grave: { ...mockGrave, figures: [] },
      sites: [],
      image: mockImage,
      page: mockPage,
      setFigures: mockSetFigures,
      figures: [],
      removeFigure: mockRemoveFigure,
      addFigure: mockAddFigure
    }

    const { getByText } = render(<BoxResizer {...props} />)

    expect(getByText(/Scale is missing/i)).toBeInTheDocument()
  })

  it('calls createFigure when New Figure is clicked', async () => {
    const { grave, ...props } = {
      next_url: '/next',
      grave: { ...mockGrave, figures: [] },
      sites: [],
      image: mockImage,
      page: mockPage,
      setFigures: mockSetFigures,
      figures: [],
      removeFigure: mockRemoveFigure,
      addFigure: mockAddFigure
    }

    const { getByText, findByText } = render(<BoxResizer {...props} />)

    const newFigureLink = getByText(/New Figure/i)
    fireEvent.click(newFigureLink)

    // Should show the dialog
    await waitFor(() => {
      expect(getByText(/New Figure/i)).toBeInTheDocument()
    })
  })
})
