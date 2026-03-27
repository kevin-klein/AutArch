import React, { useState, useEffect, useRef } from 'react'
import { Stage, Circle, Layer, Rect, Image as KonvaImage, Line, Circle as KonvaCircle, Transformer } from 'react-konva'
import useImage from 'use-image'
import { createRoot } from 'react-dom/client'
import PropTypes from 'prop-types'
import useSWR from 'swr'
import LocationMap from './LocationMap'
import SharedButton from './SharedButton'
import { t } from '../utils/i18n'

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

export default function SelectCeramic ({ figuresData, onNext, onBack, boxes = [], image: propImage, imageFile, label = 'Ceramic', isWizard = false, setBoxes }) {
  const [dimensions, setDimensions] = useState({ width: 0, height: 0 })
  const [stageScale, setStageScale] = useState(1)
  const [container, setContainer] = useState(null)

  // Selection state
  const [selectedFigureId, setSelectedFigureId] = useState(null)
  const [selectedContours, setSelectedContours] = useState([])

  // map state
  const [showMap, setShowMap] = useState(false)
  const [highlightSite, setHighlightSite] = useState(null)

  // Loading state
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  const [image, status] = useImage(
    figuresData?.image
  )

  const selectedFigure = figuresData?.figures?.find(f => f.id === selectedFigureId)

  // Get recommended figure from kiosk config
  const recommendedFigure = figuresData?.figure
  const recommendedFigureId = recommendedFigure?.id

  // Handle Next button click
  const handleNext = () => {
    if (!selectedFigureId) {
      alert(t('pleaseSelectFigure'))
      return
    }

    // Format the selected figure as a box with contour
    const figure = figuresData?.figures?.find(f => f.id === selectedFigureId)
    if (!figure) {
      alert(t('figureNotFound'))
      return
    }

    // Call onNext with the updated boxes array
    if (onNext) {
      onNext(figure)
    }
  }

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
      <LocationMap
        highlightLocation={highlightSite}
        locations={figuresData?.sites}
        isOpen={showMap}
        onClose={() => setShowMap(false)}
      />
      <div className='row mb-4'>
        <div className='col-12'>
          <div className='card'>
            <div className='card-header bg-primary text-white'>
              <h5 className='mb-0'>
                <i className='bi bi-cube me-2' />
                {t('selectCeramicContours')}
              </h5>
            </div>
            <div className='card-body'>
              <p className='text-white'>
                {t('clickContour')}
              </p>
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
                {loading ? t('loading') : t('contourViewer')}
              </span>
              <div>
                {recommendedFigureId && (
                  <span className='badge bg-warning text-dark me-2'>
                    <i className='bi bi-star me-1' />
                    {t('recommended')}: {recommendedFigure?.identifier || recommendedFigureId}
                  </span>
                )}
                {selectedFigureId && (
                  <span className='badge bg-secondary'>
                    {t('selectedFigure')}: {selectedFigureId}
                  </span>
                )}
              </div>
            </div>
            <div className='card-body p-0'>
              {(
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
                        const isRecommended = recommendedFigureId === figure.id
                        const selectedContourIndices = getSelectedContours(figure)
                        const contourPoints = getContourPoints(figure)

                        // Determine stroke color based on state
                        let strokeColor = '#ffffff'
                        let strokeWidth = 4

                        if (isSelected) {
                          strokeColor = '#1E88E5'
                          strokeWidth = 6
                        } else if (isRecommended) {
                          strokeColor = '#ff6600' // Bright orange for recommended
                          strokeWidth = 5
                        }

                        // Determine fill color
                        let fillColor = '#FFEE5866'
                        if (isSelected) {
                          fillColor = '#1E88E599'
                        } else if (isRecommended) {
                          fillColor = 'rgba(255, 102, 0, 0.3)' // Light orange
                        }

                        return (
                          <React.Fragment key={figure.id}>
                            <Line
                              points={contourPoints.flat()}
                              closed
                              onTap={() => setSelectedFigureId(figure.id)}
                              onClick={() => setSelectedFigureId(figure.id)}
                              stroke={strokeColor}
                              strokeWidth={strokeWidth}
                              fill={fillColor}
                              perfectDrawEnabled={false}
                              shadowColor={isRecommended ? '#f59e0b' : ''}
                              shadowBlur={isRecommended ? 8 : 0}
                              shadowOpacity={isRecommended ? 0.6 : 0}
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
                {t('selectedFigure')}
              </div>
              <div className='card-body'>
                {figures.find(f => f.id === selectedFigureId) && (
                  <div>
                    <h6 className='mb-3'>{t('figureDetails')}</h6>
                    <div className='mb-2'>
                      <strong>{t('type')}:</strong>
                      <span className={`ms-2 figure-type-badge figure-type-${selectedFigure.type}`}>
                        {t('ceramics')}
                      </span>
                    </div>
                    <div className='mb-2'>
                      <strong>{t('identifier')}:</strong>
                      <span className='ms-2 text-muted'>Vessel-{selectedFigure.identifier}</span>
                    </div>
                    <div className='mb-2'>
                      <strong>{t('site')}:</strong>
                      <span className='ms-2 text-muted'>
                        <button
                          onClick={() => {
                            setHighlightSite(selectedFigure.site)
                            setShowMap(true)
                          }}
                          className='btn btn-info'
                        >
                          {selectedFigure.site.name}
                        </button>
                      </span>
                    </div>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* Figures List */}
          <div className='card'>
            <div className='card-header d-flex justify-content-between align-items-center'>
              <span>
                <i className='bi bi-list me-2' />
                {t('figures')} ({figures.length})
              </span>
            </div>
            <div className='card-body p-0'>
              <div className='list-group list-group-flush' style={{ maxHeight: '400px', overflowY: 'auto' }}>
                {figures.length === 0
                  ? (
                    <div className='text-center p-3 text-muted'>
                      {t('noFigures')}
                    </div>
                    )
                  : (
                      figures.map((figure) => {
                        const isSelected = selectedFigureId === figure.id
                        const isRecommended = recommendedFigureId === figure.id

                        return (
                          <button
                            key={figure.id}
                            className={`list-group-item list-group-item-action ${isSelected ? 'active' : ''} ${isRecommended ? 'recommended-figure' : ''}`}
                            onClick={() => handleFigureSelect(figure.id)}
                          >
                            <div className='d-flex justify-content-between align-items-center'>
                              <div>
                                <span className={`figure-type-badge figure-type-${figure.type?.toLowerCase()}`}>
                                  {t('ceramics')}
                                </span>
                                <strong className={isSelected ? 'text-white ms-2' : 'ms-2'}>
                                  {figure.identifier || figure.text || `${t('figure')} ${figure.id}`}
                                </strong>
                                {isRecommended && (
                                  <span className='badge bg-warning text-dark ms-2'>
                                    <i className='bi bi-star me-1' />
                                    {t('recommended')}
                                  </span>
                                )}
                              </div>
                              {isSelected && (
                                <i className='bi bi-check-circle-fill text-primary' />
                              )}
                              {isRecommended && !isSelected && (
                                <i className='bi bi-star-fill text-warning' />
                              )}
                            </div>
                          </button>
                        )
                      })
                    )}
              </div>
            </div>
          </div>

          {/* Action Buttons */}
          {isWizard && (
            <div className='card mt-4'>
              <div className='card-body'>
                <div className='d-flex justify-content-between gap-2'>
                  {onBack && (
                    <SharedButton
                      onClick={onBack}
                      disabled={!selectedFigureId}
                      variant='secondary'
                    >
                      <i className='bi bi-arrow-left me-2' />
                      {t('back')}
                    </SharedButton>
                  )}
                  <SharedButton
                    onClick={handleNext}
                    disabled={!selectedFigureId || loading}
                    style={{ flex: 1 }}
                  >
                    {t('next')}
                  </SharedButton>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
