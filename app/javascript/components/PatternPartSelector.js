import React from 'react'
import { useFigureStore } from './store'
import { Stage, Layer, Rect, Transformer, Group, Image, Line, Text } from 'react-konva'
import BoxCanvas from './BoxCanvas'
import useImage from 'use-image'

export default function PatternPartSelector ({ figure, image, nextUrl, onComplete }) {
  const [patternParts, setPatternParts] = React.useState(figure.pattern_parts || [])
  const [selectedPartId, setSelectedPartId] = React.useState(null)
  const [isDrawing, setIsDrawing] = React.useState(false)
  const [drawingRect, setDrawingRect] = React.useState(null)
  const [dragStart, setDragStart] = React.useState(null)
  const divRef = React.useRef(null)

  const [imageNode] = useImage(image.href)

  const [dimensions, setDimensions] = React.useState({
    width: 0,
    height: 0
  })
  const [stageScale, setStageScale] = React.useState(1)
  const [stageX, setStageX] = React.useState(0)
  const [stageY, setStageY] = React.useState(0)
  React.useEffect(() => {
    setDimensions({
      width: divRef.current.offsetWidth,
      height: (divRef.current.offsetWidth / image.width) * image.height
    })
    setStageScale(divRef.current.offsetWidth / image.width)
  }, [])

  const token = document.querySelector('[name=csrf-token]')?.content || ''

  // Load existing pattern parts
  React.useEffect(() => {
    if (figure.pattern_parts) {
      setPatternParts(figure.pattern_parts)
    }
  }, [figure.id])

  function getPointerPos (stage) {
    if (!stage) return null
    const pos = stage.getPointerPosition()
    if (!pos) return null // Pointer is not on stage
    const scale = stage.scaleX()
    const stagePos = stage.position()
    return {
      x: (pos.x - stagePos.x) / scale,
      y: (pos.y - stagePos.y) / scale
    }
  }

  function startDrawing (e) {
    const stage = e.target.getStage()
    const pointerPosition = getPointerPos(stage)
    setDragStart(pointerPosition)
    setDrawingRect({
      x: pointerPosition.x,
      y: pointerPosition.y,
      width: 0,
      height: 0
    })
    setIsDrawing(true)
  }

  function drawRect (e) {
    if (!isDrawing || !dragStart) return

    const stage = e.target.getStage()
    const pointerPosition = getPointerPos(stage)

    setDrawingRect({
      x: dragStart.x,
      y: dragStart.y,
      width: pointerPosition.x - dragStart.x,
      height: pointerPosition.y - dragStart.y
    })
  }

  function finishDrawing () {
    if (!isDrawing || !drawingRect) {
      setIsDrawing(false)
      setDrawingRect(null)
      setDragStart(null)
      return
    }

    // Normalize the rectangle (handle negative width/height)
    const normalizedRect = {
      x1: Math.min(drawingRect.x, drawingRect.x + drawingRect.width),
      y1: Math.min(drawingRect.y, drawingRect.y + drawingRect.height),
      x2: Math.max(drawingRect.x, drawingRect.x + drawingRect.width),
      y2: Math.max(drawingRect.y, drawingRect.y + drawingRect.height)
    }

    // Validate minimum size
    if (normalizedRect.x2 - normalizedRect.x1 < 20 || normalizedRect.y2 - normalizedRect.y1 < 20) {
      alert('Pattern part must be at least 20x20 pixels')
      setIsDrawing(false)
      setDrawingRect(null)
      setDragStart(null)
      return
    }

    // Add new pattern part
    const newPart = {
      id: `temp_${Date.now()}`,
      x1: normalizedRect.x1,
      y1: normalizedRect.y1,
      x2: normalizedRect.x2,
      y2: normalizedRect.y2,
      description: '',
      feature_type: 'texture',
      isNew: true
    }

    setPatternParts([...patternParts, newPart])
    setSelectedPartId(newPart.id)
    setIsDrawing(false)
    setDrawingRect(null)
    setDragStart(null)
  }

  function updatePartDescription (id, description) {
    setPatternParts(patternParts.map(part =>
      part.id === id ? { ...part, description } : part
    ))
  }

  function updatePartFeatureType (id, featureType) {
    setPatternParts(patternParts.map(part =>
      part.id === id ? { ...part, feature_type: featureType } : part
    ))
  }

  function deletePart (id) {
    setPatternParts(patternParts.filter(part => part.id !== id))
    if (selectedPartId === id) {
      setSelectedPartId(null)
    }
  }

  function getSelectedPart () {
    return patternParts.find(part => part.id === selectedPartId)
  }

  async function handleSubmit () {
    // Convert temp IDs to real IDs and prepare for submission
    const validParts = patternParts.filter(part => {
      const width = part.x2 - part.x1
      const height = part.y2 - part.y1
      return width >= 20 && height >= 20
    })

    // Submit to server
    const form = document.createElement('form')
    form.method = 'POST'
    form.action = nextUrl

    // Add CSRF token
    if (token) {
      const csrfInput = document.createElement('input')
      csrfInput.type = 'hidden'
      csrfInput.name = 'authenticity_token'
      csrfInput.value = token
      form.appendChild(csrfInput)
    }

    const methodInput = document.createElement('input')
    methodInput.type = 'hidden'
    methodInput.name = '_method'
    methodInput.value = 'patch'
    form.appendChild(methodInput)

    // Add hidden field for step
    const stepInput = document.createElement('input')
    stepInput.type = 'hidden'
    stepInput.name = 'step'
    stepInput.value = 'select_pattern_parts'
    form.appendChild(stepInput)

    // Add pattern parts
    validParts.forEach((part, index) => {
      const prefix = `pattern_parts[${index}]`
      const inputs = [
        ['x1', part.x1],
        ['y1', part.y1],
        ['x2', part.x2],
        ['y2', part.y2],
        ['description', part.description || ''],
        ['feature_type', part.feature_type || 'texture']
      ]

      inputs.forEach(([name, value]) => {
        const input = document.createElement('input')
        input.type = 'hidden'
        input.name = `${prefix}[${name}]`
        input.value = value
        form.appendChild(input)
      })
    })

    document.body.appendChild(form)
    form.submit()
  }

  const selectedPart = getSelectedPart()

  const getContourPoints = (figure) => {
    let contour = figure.contour
    if (contour[0][0].constructor === Array) {
      contour = contour[0]
    }

    return contour.map(point => [point[0] + figure.x1, point[1] + figure.y1])
  }

  const contourPoints = getContourPoints(figure)

  return (
    <div className='row'>
      <div className='col-md-8'>
        <div className='card'>
          <div className='card-header d-flex justify-content-between align-items-center'>
            <h5 className='mb-0'>Select Pattern Parts</h5>
            <span className='badge bg-primary'>{patternParts.length} parts selected</span>
          </div>
          <div className='card-body p-0' ref={divRef}>
            <Stage
              onMouseDown={startDrawing}
              onMouseMove={drawRect}
              onMouseUp={finishDrawing}
              style={{ cursor: isDrawing ? 'crosshair' : 'default' }}
              scaleX={stageScale}
              scaleY={stageScale}
              x={stageX}
              y={stageY}
              width={dimensions.width}
              height={dimensions.height}
            >
              <Layer>
                {/* Image */}
                <Image
                  width={image.width}
                  height={image.height}
                  image={imageNode}
                  x={0}
                  y={0}
                />

                <Line
                  points={contourPoints.flat()}
                  closed
                  stroke='#1E88E5'
                  strokeWidth={3}
                  fill='#1E88E599'
                  perfectDrawEnabled={false}
                />

                {/* Existing pattern parts */}
                {patternParts.map(part => (
                  <Group key={part.id}>
                    <Rect
                      x={part.x1}
                      y={part.y1}
                      width={part.x2 - part.x1}
                      height={part.y2 - part.y1}
                      fill={part.id === selectedPartId ? 'rgba(0, 123, 255, 0.3)' : 'rgba(255, 193, 7, 0.2)'}
                      stroke={part.id === selectedPartId ? '#007bff' : '#ffc107'}
                      strokeWidth={part.id === selectedPartId ? 3 : 2}
                      onClick={() => setSelectedPartId(part.id)}
                      onTap={() => setSelectedPartId(part.id)}
                    />
                    {part.id === selectedPartId && (
                      <Rect
                        x={part.x1}
                        y={part.y1 - 25}
                        width={part.x2 - part.x1}
                        height={25}
                        fill='#007bff'
                        opacity={0.9}
                      />
                    )}
                    {part.id === selectedPartId && (
                      <Text
                        x={part.x1 + 5}
                        y={part.y1 - 7}
                        fill='white'
                        fontSize={12}
                        text={part.description || 'Pattern Part'}
                      />
                    )}
                  </Group>
                ))}

                {/* Currently drawing rectangle */}
                {isDrawing && drawingRect && (
                  <Rect
                    x={drawingRect.x}
                    y={drawingRect.y}
                    width={drawingRect.width}
                    height={drawingRect.height}
                    fill='rgba(0, 123, 255, 0.3)'
                    stroke='#007bff'
                    strokeWidth={2}
                    dash={[5, 5]}
                  />
                )}
              </Layer>
            </Stage>
          </div>
          <div className='card-footer'>
            <p className='mb-0 text-muted'>
              <i className='bi bi-mouse' /> Click and drag to select a pattern region
            </p>
          </div>
        </div>
      </div>

      <div className='col-md-4'>
        <div className='card' style={{ position: 'sticky', top: 20 }}>
          <div className='card-header'>
            <h5 className='mb-0'>Pattern Parts</h5>
          </div>
          <div className='card-body' style={{ maxHeight: '400px', overflowY: 'auto' }}>
            {patternParts.length === 0
              ? (
                <p className='text-muted text-center'>No pattern parts selected yet</p>
                )
              : (
                <div className='list-group'>
                  {patternParts.map(part => (
                    <div
                      key={part.id}
                      className={`list-group-item list-group-item-action ${part.id === selectedPartId ? 'active' : ''}`}
                      onClick={() => setSelectedPartId(part.id)}
                    >
                      <div className='d-flex justify-content-between align-items-start'>
                        <div>
                          <div className='fw-bold'>{part.description || 'Pattern Part'}</div>
                          <small className='text-muted text-capitalize'>{part.feature_type}</small>
                        </div>
                        <button
                          type='button'
                          className='btn btn-sm btn-danger'
                          onClick={(e) => {
                            e.stopPropagation()
                            deletePart(part.id)
                          }}
                        >
                          ×
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
                )}
          </div>
          {selectedPart && (
            <div className='card-footer'>
              <div className='mb-3'>
                <label className='form-label text-white'>Description</label>
                <input
                  type='text'
                  className='form-control form-control-sm'
                  value={selectedPart.description || ''}
                  onChange={(e) => updatePartDescription(selectedPart.id, e.target.value)}
                  placeholder='e.g., Rim decoration, Handle pattern'
                />
              </div>
              <div className='mb-3'>
                <label className='form-label text-white'>Feature Type</label>
                <select
                  className='form-select form-select-sm'
                  value={selectedPart.feature_type || 'texture'}
                  onChange={(e) => updatePartFeatureType(selectedPart.id, e.target.value)}
                >
                  <option value='texture'>Texture</option>
                  <option value='color'>Color</option>
                  <option value='edge'>Edge</option>
                </select>
              </div>
            </div>
          )}
          <div className='card-footer'>
            <button
              type='button'
              className='btn btn-primary w-100'
              onClick={handleSubmit}
            >
              Continue ({patternParts.length} parts)
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
