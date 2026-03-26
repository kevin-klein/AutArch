/**
 * Tests for CeramicWizard component
 */

import React from 'react'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import CeramicWizard from '../components/CeramicWizard'

// Mock the arrowheads components
jest.mock('../components/arrowheads/UploadStep', () => ({ onNext, autoSelect, fixedImage, demoImage, fixedObjectType }) => (
  <div data-testid="mock-upload-step">
    <button onClick={() => onNext(new File([], 'test.jpg'), 'Ceramics')}>Next</button>
  </div>
))

jest.mock('../components/SelectCeramic', () => ({ boxes, image, imageFile, label, onNext, onBack, isWizard, setBoxes }) => (
  <div data-testid="mock-select-ceramic">
    <span>Ceramic selector</span>
    <button onClick={() => onNext(boxes)}>Next</button>
    <button onClick={onBack}>Back</button>
  </div>
))

jest.mock('../components/arrowheads/SimilarityStep', () => ({ boxes, image, imageFile, wizardId, figureId, onNext, onBack }) => (
  <div data-testid="mock-similarity-step">
    <span>Similarity step</span>
    <button onClick={() onNext([])}>Complete</button>
    <button onClick={onBack}>Back</button>
  </div>
))

describe('CeramicWizard', () => {
  const mockPage = {
    id: 1,
    image: { data: 'test-image-data' }
  }

  beforeEach(() => {
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve({ id: 123 })
      })
    )
  })

  it('renders the wizard', () => {
    render(<CeramicWizard page={mockPage} />)
    expect(screen.getByText(/AutArch/i)).toBeInTheDocument()
    expect(screen.getByText(/Step 1 of 3/i)).toBeInTheDocument()
  })

  it('initializes wizard on mount', async () => {
    render(<CeramicWizard page={mockPage} />)

    await waitFor(() => {
      expect(fetch).toHaveBeenCalledWith('/analysis_wizards', expect.any(Object))
    })
  })

  it('handles step navigation', async () => {
    render(<CeramicWizard page={mockPage} />)

    // Should be on step 1 initially
    expect(screen.getByText(/Step 1 of 3/i)).toBeInTheDocument()

    // Click Next to go to step 2
    fireEvent.click(screen.getByText(/Next/i))
    expect(screen.getByText(/Step 2 of 3/i)).toBeInTheDocument()

    // Click Next to go to step 3
    fireEvent.click(screen.getByText(/Next/i))
    expect(screen.getByText(/Step 3 of 3/i)).toBeInTheDocument()
  })

  it('handles back navigation', async () => {
    render(<CeramicWizard page={mockPage} />)

    // Go to step 2
    fireEvent.click(screen.getByText(/Next/i))

    // Go to step 3
    fireEvent.click(screen.getByText(/Next/i))

    // Go back to step 2
    fireEvent.click(screen.getByText(/Back/i))
    expect(screen.getByText(/Step 2 of 3/i)).toBeInTheDocument()
  })

  it('shows loading state while initializing', () => {
    render(<CeramicWizard page={mockPage} />)
    expect(screen.getByText(/Initializing Wizard/i)).toBeInTheDocument()
  })
})
