import React, { useState, useEffect, useRef } from 'react'
import { Stage, Circle, Layer, Rect, Image as KonvaImage, Line, Circle as KonvaCircle, Transformer } from 'react-konva'
import useImage from 'use-image'
import { createRoot } from 'react-dom/client'
import PropTypes from 'prop-types'
import useSWR from 'swr'

const fetcher = (...args) => fetch(...args).then(res => {
  if (!res.ok) {
    throw new Error(`HTTP error! status: ${res.status}`)
  }
  return res.json()
})

// Figure type badge colors
const figureTypeColors = {
  Grave: 'figure-type-grave',
  Arrow: 'figure-type-arrow',
  Ceramic: 'figure-type-ceramic',
  StoneTool: 'figure-type-stonetool',
  Skeleton: 'figure-type-skeleton',
  Kurgan: 'figure-type-kurgan',
  Oxcal: 'figure-type-oxcal',
  Bone: 'figure-type-bone',
  default: 'figure-type-default'
}

export default function SelectCeramic (params = {}) {
  const [imageError, setImageError] = useState(null)
  const [dimensions, setDimensions] = useState({ width: 0, height: 0 })
  const [stageScale, setStageScale] = useState(1)
  const [container, setContainer] = useState(null)

  // Selection state
  const [selectedFigureId, setSelectedFigureId] = useState(null)
  const [selectedContours, setSelectedContours] = useState([])
  const [hoveredFigureId, setHoveredFigureId] = useState(null)

  // Loading state
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  // Fetch figures from kiosk config API
  const { data: figuresData, error: figuresError, isLoading: figuresLoading } = useSWR(
    '/kiosk_configs/kiosk_config.json',
    fetcher
  )

  // Load a demo image or use the first page's image
  const [image, status] = useImage(
    '/demo.jpg' // Default demo image
  )

  // Calculate display dimensions
  useEffect(() => {
    if (container && status === 'loaded' && image) {
      try {
        const width = container.offsetWidth
        const height = (width / image.width) * image.height

        setDimensions({ width, height })
        setStageScale(width / image.width)
      } catch (err) {
        console.error('Error calculating dimensions:', err)
      }
    }
  }, [status, container, image])

  // Extract figures from pages data
  const figures = figuresData?.figures || []

  // Handle figure selection
  const handleFigureSelect = (figureId) => {
    setSelectedFigureId(figureId)
    setSelectedContours([]) // Clear previous selections
  }

  // Handle contour click
  const handleContourClick = (figureId, contour) => {
    if (selectedFigureId !== figureId) {
      // First click on a new figure
      setSelectedFigureId(figureId)
      setSelectedContours([contour])
    } else {
      // Toggle contour selection
      setSelectedContours(prev => {
        if (prev.includes(contour)) {
          return prev.filter(c => c !== contour)
        } else {
          return [...prev, contour]
        }
      })
    }
  }

  // Handle mouse enter for hover effect
  const handleMouseEnter = (figureId) => {
    setHoveredFigureId(figureId)
  }

  // Handle mouse leave for hover effect
  const handleMouseLeave = (figureId) => {
    if (selectedFigureId === figureId) {
      setHoveredFigureId(figureId)
    } else {
      setHoveredFigureId(null)
    }
  }

  // Get contour points with offset
  const getContourPoints = (figure) => {
    let contour = figure.contour
    if (contour[0][0].constructor === Array) {
      contour = contour[0]
    }

    return contour.map(point => [point[0] + figure.x1, point[1] + figure.y1])
  }

  // Get selected contours for a figure
  const getSelectedContours = (figure) => {
    if (selectedFigureId !== figure.id) return []
    return selectedContours.filter(c => c === figure.contour)
  }

  return (
    <div className='container-fluid'>
      {/* Header */}
      <div className='row mb-4'>
        <div className='col-12'>
          <div className='card'>
            <div className='card-header bg-primary text-white'>
              <h5 className='mb-0'>
                <i className='bi bi-cube me-2' />
                Select Ceramic Contours
              </h5>
            </div>
            <div className='card-body'>
              <p className='text-muted'>
                Click on a contour to select it. Selected contours will be highlighted in blue.
                You can select multiple contours from the same figure.
              </p>
              <div className='alert alert-info'>
                <strong>Usage Hints:</strong>
                <ul className='mb-0 mt-2'>
                  <li>
                    <strong>Single Select:</strong> Click a contour to select it (it becomes blue)
                  </li>
                  <li>
                    <strong>Multi-Select:</strong> Click multiple contours from the same figure
                  </li>
                  <li>
                    <strong>Change Figure:</strong> Click a different figure to switch selection
                  </li>
                  <li>
                    <strong>Clear Selection:</strong> Click the "Clear Selection" button
                  </li>
                  <li>
                    <strong>Figure Info:</strong> Hover over a figure to see its details
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className='row'>
        {/* Canvas Area */}
        <div className='col-lg-8'>
          <div className='card' ref={setContainer}>
            <div className='card-header d-flex justify-content-between align-items-center'>
              <span>
                <i className='bi bi-image me-2' />
                {loading ? 'Loading...' : 'Contour Viewer'}
              </span>
              {selectedFigureId && (
                <span className='badge bg-secondary'>
                  Figure: {selectedFigureId}
                </span>
              )}
            </div>
            <div className='card-body p-0'>
              {figuresLoading ? (
                <div className='text-center p-5'>
                  <div className='spinner-border text-primary' role='status'>
                    <span className='visually-hidden'>Loading figures...</span>
                  </div>
                  <p className='mt-2'>Loading figures from API...</p>
                </div>
              ) : figuresError ? (
                <div className='alert alert-danger m-3'>
                  <strong>Error:</strong> {figuresError.message}
                  <button
                    className='btn btn-sm btn-link mt-2'
                    onClick={() => window.location.reload()}
                  >
                    Retry
                  </button>
                </div>
              ) : (
                figures.length > 0 && image && (
                  <Stage
                    width={dimensions.width}
                    height={dimensions.height}
                    scaleX={stageScale}
                    scaleY={stageScale}
                    style={{ border: '1px solid #ddd' }}
                  >
                    <Layer>
                      {/* Background image */}
                      {image && (
                        <KonvaImage
                          image={image}
                          width={image.width}
                          height={image.height}
                          x={0}
                          y={0}
                        />
                      )}

                      {/* Draw contours */}
                      {figures.map((figure) => {
                        const isSelected = selectedFigureId === figure.id
                        const isHovered = hoveredFigureId === figure.id
                        const selectedContourIndices = getSelectedContours(figure)
                        const contourPoints = getContourPoints(figure)

                        return (
                          <React.Fragment key={figure.id}>
                            <Line
                              points={contourPoints.flat()}
                              closed
                              onTap={() => console.log(`clicked ${figure.id}`)}
                              onClick={() => console.log(`clicked ${figure.id}`)}
                              stroke={isSelected ? (selectedContourIndices.length > 0 ? '#2563eb' : '#4f46e5') : (isHovered ? '#4f46e5' : '#000000')}
                              strokeWidth={isSelected ? (selectedContourIndices.length > 0 ? 3 : 2) : 1}
                              fill={isSelected ? 'rgba(79, 70, 229, 0.5)' : 'rgba(0, 0, 0, 0.2)'}
                              perfectDrawEnabled={false}
                            />
                          </React.Fragment>
                        )
                      })}
                    </Layer>
                  </Stage>
                )
              )}
            </div>
          </div>
        </div>

        {/* Sidebar */}
        <div className='col-lg-4'>
          {/* Selected Figure Info */}
          {selectedFigureId && (
            <div className='card mb-4'>
              <div className='card-header bg-info text-white'>
                <i className='bi bi-info-circle me-2' />
                Selected Figure
              </div>
              <div className='card-body'>
                {figures.find(f => f.id === selectedFigureId) && (
                  <div>
                    <h6 className='mb-3'>Figure Details</h6>
                    <div className='mb-2'>
                      <strong>Type:</strong>
                      <span className={`ms-2 figure-type-badge figure-type-${selectedFigureId.type?.toLowerCase()}`}>
                        {selectedFigureId.type || 'Unknown'}
                      </span>
                    </div>
                    <div className='mb-2'>
                      <strong>Identifier:</strong>
                      <span className='ms-2 text-muted'>{selectedFigureId.identifier || selectedFigureId.text || 'N/A'}</span>
                    </div>
                    <div className='mb-2'>
                      <strong>Probability:</strong>
                      <span className='ms-2 text-muted'>
                        {(selectedFigureId.probability * 100).toFixed(1)}%
                      </span>
                    </div>
                    <div className='mb-2'>
                      <strong>Coordinates:</strong>
                      <div className='ms-2 small text-muted'>
                        X1: {selectedFigureId.x1}, Y1: {selectedFigureId.y1}<br />
                        X2: {selectedFigureId.x2}, Y2: {selectedFigureId.y2}
                      </div>
                    </div>
                    <div className='mb-2'>
                      <strong>Contour Points:</strong>
                      <span className='ms-2 text-muted'>{selectedFigureId.contour?.length || 0} points</span>
                    </div>
                    <div className='mb-2'>
                      <strong>Selected Contours:</strong>
                      <span className='ms-2 text-muted'>
                        {getSelectedContours(figures.find(f => f.id === selectedFigureId)).length} / {selectedFigureId.contour?.length || 0}
                      </span>
                    </div>
                  </div>
                )}

                {/* Action Buttons */}
                <div className='mt-4'>
                  <button
                    className='btn btn-danger w-100 mb-2'
                    onClick={() => {
                      setSelectedFigureId(null)
                      setSelectedContours([])
                    }}
                  >
                    <i className='bi bi-x-circle me-2' />
                    Clear Selection
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* Figures List */}
          <div className='card'>
            <div className='card-header d-flex justify-content-between align-items-center'>
              <span>
                <i className='bi bi-list me-2' />
                Figures ({figures.length})
              </span>
            </div>
            <div className='card-body p-0'>
              <div className='list-group list-group-flush' style={{ maxHeight: '400px', overflowY: 'auto' }}>
                {figures.length === 0
                  ? (
                    <div className='text-center p-3 text-muted'>
                      No figures available
                    </div>
                    )
                  : (
                      figures.map((figure) => {
                        const isSelected = selectedFigureId === figure.id
                        return (
                          <button
                            key={figure.id}
                            className={`list-group-item list-group-item-action ${isSelected ? 'active' : ''}`}
                            onClick={() => handleFigureSelect(figure.id)}
                            onMouseEnter={() => handleMouseEnter(figure.id)}
                            onMouseLeave={() => handleMouseLeave(figure.id)}
                          >
                            <div className='d-flex justify-content-between align-items-center'>
                              <div>
                                <strong className={isSelected ? 'text-white' : ''}>
                                  {figure.identifier || figure.text || `Figure ${figure.id}`}
                                </strong>
                                <span className={`figure-type-badge figure-type-${figure.type?.toLowerCase()} ms-2`}>
                                  {figure.type || 'Unknown'}
                                </span>
                              </div>
                              {isSelected && (
                                <i className='bi bi-check-circle-fill text-primary' />
                              )}
                            </div>
                            <div className='small text-muted'>
                              Prob: {(figure.probability * 100).toFixed(1)}% • {figure.contour?.length || 0} pts
                            </div>
                          </button>
                        )
                      })
                    )}
              </div>
            </div>
          </div>

          {/* Help Section */}
          <div className='card mt-4'>
            <div className='card-header bg-warning text-dark'>
              <i className='bi bi-question-circle me-2' />
              How to Use
            </div>
            <div className='card-body'>
              <ol className='mb-0'>
                <li>Scroll through the figures list to see all available ceramics</li>
                <li>Click on any figure to select it</li>
                <li>Click on contours in the image to select specific ones</li>
                <li>Selected contours appear in blue with vertex circles</li>
                <li>View figure details in the sidebar</li>
                <li>Click "Clear Selection" to start over</li>
              </ol>
            </div>
          </div>

          {/* Tips */}
          <div className='card mt-4'>
            <div className='card-header bg-success text-white'>
              <i className='bi bi-lightbulb me-2' />
              Tips
            </div>
            <div className='card-body'>
              <ul className='mb-0 small'>
                <li>Multi-click to select multiple contours from the same figure</li>
                <li>Use the scrollbar to browse through many figures</li>
                <li>Hover over contours to see figure boundaries</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
