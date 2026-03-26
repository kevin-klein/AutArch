/**
 * Tests for SamPointSelector component
 */

import React from 'react'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import SamPointSelector from '../components/SamPointSelector'

describe('SamPointSelector', () => {
  const mockFigure = {
    id: 123,
    type: 'Ceramic',
    x1: 100,
    y1: 100,
    x2: 200,
    y2: 200,
    contour: [[10, 10], [90, 10], [90, 90], [10, 90]]
  }

  const mockImage = {
    width: 800,
    height: 600,
    url: '/test-image.jpg'
  }

  const mockUrl = '/test/url'

  beforeEach(() => {
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve({ contour: [[1, 1], [2, 2]] })
      })
    )
  })

  it('renders the component', () => {
    render(<SamPointSelector figure={mockFigure} image={mockImage} url={mockUrl} />)
    expect(screen.getByText(/Ceramic 123/i)).toBeInTheDocument()
    expect(screen.getByText(/Update SAM Contours/i)).toBeInTheDocument()
  })

  it('renders polyline from contour', () => {
    render(<SamPointSelector figure={mockFigure} image={mockImage} url={mockUrl} />)
    // The polyline should be rendered with points
    expect(document.querySelector('polyline')).not.toBeNull()
  })

  it('adds point on SVG click', async () => {
    render(<SamPointSelector figure={mockFigure} image={mockImage} url={mockUrl} />)

    const svg = document.querySelector('svg')
    expect(svg).not.toBeNull()

    // Simulate a click on the SVG
    const clickEvent = new MouseEvent('click', {
      clientX: 150,
      clientY: 150,
      bubbles: true
    })

    if (svg) {
      svg.dispatchEvent(clickEvent)
    }

    // Should have a circle for the added point
    await waitFor(() => {
      expect(document.querySelector('circle')).not.toBeNull()
    })
  })

  it('handles point removal', async () => {
    render(<SamPointSelector figure={mockFigure} image={mockImage} url={mockUrl} />)

    // Add a point
    const svg = document.querySelector('svg')
    const clickEvent = new MouseEvent('click', {
      clientX: 150,
      clientY: 150,
      bubbles: true
    })

    if (svg) {
      svg.dispatchEvent(clickEvent)
    }

    await waitFor(() => {
      expect(document.querySelectorAll('circle')).toHaveLength(1)
    })

    // Click the circle to remove it
    const circle = document.querySelector('circle')
    if (circle) {
      circle.dispatchEvent(new MouseEvent('click', { bubbles: true }))
    }

    await waitFor(() => {
      expect(document.querySelectorAll('circle')).toHaveLength(0)
    })
  })

  it('calls updatePoints API on button click', async () => {
    render(<SamPointSelector figure={mockFigure} image={mockImage} url={mockUrl} />)

    // Add a point first
    const svg = document.querySelector('svg')
    const clickEvent = new MouseEvent('click', {
      clientX: 150,
      clientY: 150,
      bubbles: true
    })

    if (svg) {
      svg.dispatchEvent(clickEvent)
    }

    // Click the update button
    const updateButton = screen.getByText(/Update SAM Contours/i)
    fireEvent.click(updateButton)

    await waitFor(() => {
      expect(fetch).toHaveBeenCalledWith(
        expect.stringContaining('points=' + encodeURIComponent(JSON.stringify([[50, 50]]))),
        expect.anything()
      )
    })
  })

  it('shows loading dialog while updating', async () => {
    global.fetch = jest.fn(() => new Promise(resolve => {
      setTimeout(() => resolve({
        ok: true,
        json: () => Promise.resolve({ contour: [[1, 1]] })
      }), 100)
    }))

    render(<SamPointSelector figure={mockFigure} image={mockImage} url={mockUrl} />)

    const updateButton = screen.getByText(/Update SAM Contours/i)
    fireEvent.click(updateButton)

    await waitFor(() => {
      expect(screen.getByText(/Please wait while the contours are being processed/i)).toBeInTheDocument()
    })
  })
})
