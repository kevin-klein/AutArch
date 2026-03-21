import LoadingDialog from './LoadingDialog'
import React, { useState, useRef, useEffect } from 'react'
import { Stage, Layer, Rect, Image as KonvaImage, Line, Circle as KonvaCircle } from 'react-konva'

function normalizeBox (boxData, index) {
  const [x1, y1, x2, y2] = boxData.box

  return {
    id: boxData.id,
    index,
    x1,
    y1,
    x2,
    y2,
    type: boxData.label,
    contour: boxData.contour || []
  }
}

export default function Contours ({ boxes: initialBoxes, image, onNext, onBack, imageFile, label }) {
  const defaultCenters = initialBoxes.reduce((acc, item) => {
    const [x1, y1, x2, y2] = item.box
    acc[item.id] = [[Math.round((x1 + x2) / 2), Math.round((y1 + y2) / 2)]]
    return acc
  }, {})

  const [boxes, setBoxes] = useState(() => initialBoxes.map((b, i) => normalizeBox(b, i)))
  const [selectedBoxId, setSelectedBoxId] = useState(null)
  const [samPoints, setSamPoints] = useState(defaultCenters)
  const [loading, setLoading] = useState(false)
  const [isCreatingNewBox, setIsCreatingNewBox] = useState(false)
  const [newBoxPoints, setNewBoxPoints] = useState([])

  const divRef = useRef(null)
  const stageRef = useRef(null)
  const [dimensions, setDimensions] = useState({ width: 0, height: 0 })
  const [stageScale, setStageScale] = useState(1)

  // Initialize dimensions based on container
  useEffect(() => {
    if (divRef.current && image) {
      const width = divRef.current.offsetWidth
      const height = (width / image.width) * image.height
      setDimensions({ width, height })
      setStageScale(width / image.width)
    }
  }, [image])

  const selectedBox = boxes.find(b => b.id === selectedBoxId)

  // Handle stage click for adding SAM points or new box points
  const handleStageClick = (e) => {
    const stage = e.target.getStage()
    const pointer = stage.getPointerPosition()
    if (!pointer) return

    const x = pointer.x / stageScale
    const y = pointer.y / stageScale

    if (isCreatingNewBox) {
      setNewBoxPoints(prev => [...prev, [x, y]])
    } else if (selectedBoxId !== null) {
      setSamPoints({
        ...samPoints,
        [selectedBoxId]: [...samPoints[selectedBoxId], [Math.round(x), Math.round(y)]]
      })
    }
  }

  const removeSamPoint = (index) => {
    setSamPoints({
      ...samPoints,
      [selectedBoxId]: [...samPoints[selectedBoxId].filter((_, i) => i !== index)]
    })
  }

  // Update SAM contours for the selected box
  const updateSamContours = async () => {
    if (!selectedBox || samPoints[selectedBoxId].length === 0) return

    try {
      setLoading(true)

      const formData = new FormData()
      formData.append('image', imageFile)
      formData.append('points', JSON.stringify(samPoints[selectedBoxId]))

      const response = await fetch('/size_figures/update_contour', {
        method: 'POST',
        body: formData,
        headers: { Accept: 'application/json' }
      })

      if (!response.ok) throw new Error('Failed to update contour')

      const result = await response.json()

      // Update the box with new contour
      setBoxes(prev => prev.map(box =>
        box.id === selectedBoxId
          ? { ...box, contour: result.contour }
          : box
      ))
      // Don't clear samPoints - keep them for review
    } catch (err) {
      console.error('Error updating contour:', err)
      alert('Failed to update contour')
    } finally {
      setLoading(false)
    }
  }

  // Create a new box from control points
  const createNewBox = async () => {
    if (newBoxPoints.length === 0) return

    try {
      setLoading(true)

      const formData = new FormData()
      formData.append('image', imageFile)
      formData.append('points', JSON.stringify(newBoxPoints))

      const response = await fetch('/size_figures/new_box', {
        method: 'POST',
        headers: { Accept: 'application/json' },
        body: formData
      })

      if (!response.ok) throw new Error('Failed to create new box')

      const result = await response.json()
      setBoxes(prev => [...prev, { ...result, type: label }])
      setSamPoints({ ...samPoints, [response.id]: newBoxPoints })
      setNewBoxPoints([])
      setIsCreatingNewBox(false)
    } catch (err) {
      console.error('Error creating new box:', err)
      alert('Failed to create new box')
    } finally {
      setLoading(false)
    }
  }

  // Cancel new box creation
  const cancelNewBox = () => {
    setIsCreatingNewBox(false)
    setNewBoxPoints([])
  }

  const renderContour = (box) => {
    if (!box.contour || box.contour.length === 0) return null

    const isSelected = box.id === selectedBoxId
    const strokeColor = isSelected ? '#F44336' : '#3F51B5'
    const fillColor = isSelected ? 'rgba(244, 67, 54, 0.3)' : 'rgba(63, 81, 181, 0.3)'

    // Handle both single contour and array of contours
    const contours = Array.isArray(box.contour[0]) && Array.isArray(box.contour[0][0])
      ? box.contour // Multiple contours
      : [box.contour] // Single contour

    return contours.map((contour, idx) => {
      const points = contour.flat(5)
      return (
        <Line
          key={`contour-${idx}`}
          points={points}
          stroke={strokeColor}
          strokeWidth={20}
          lineJoin='round'
          closed
          fill={fillColor}
          y={0}
        />
      )
    })
  }

  // Render box rectangle
  const renderBox = (box) => {
    const isSelected = box.id === selectedBoxId
    const strokeColor = isSelected ? '#F44336' : 'purple'
    const fillColor = isSelected ? 'rgba(244, 143, 54, 0.44)' : 'rgba(128, 0, 128, 0.11)'

    return (
      <Rect
        key={`box-${box.id}`}
        x={box.x1}
        y={box.y1}
        width={box.x2 - box.x1}
        height={box.y2 - box.y1}
        fill={fillColor}
        stroke={strokeColor}
        strokeWidth={2}
        onClick={() => {
          setSelectedBoxId(box.id)
        }}
        onTap={() => {
          setSelectedBoxId(box.id)
        }}
      />
    )
  }

  return (
    <div className='row'>
      {loading && <LoadingDialog />}

      {/* Left side - Image with boxes */}
      <div className='col-md-8'>
        <div className='card' ref={divRef}>
          <div className='d-flex justify-content-between align-items-center mb-2'>
            <h3>Select Box & Set Control Points</h3>
            <div>
              <button className='btn btn-info me-2' onClick={onBack}>Back</button>
              <button className='btn btn-info' onClick={() => onNext(boxes)}>Next</button>
            </div>
          </div>

          {/* --- NEW: User Instructions Section --- */}
          <div className='alert alert-info mb-2' role="alert">
            <h5 className="alert-heading">How to use this interface:</h5>
            <ul className="mb-0">
              <li><strong>1. Select a Box:</strong> Click on any detected box (purple outline) in the image list or directly on the image to select it.</li>
              <li><strong>2. Add Control Points:</strong> Once a box is selected, click in the image to add control points (red dots). Add as many points as needed to define the object's shape.</li>
              <li><strong>3. Update Contour:</strong> After adding points, click the <strong>"Update Contour"</strong> button. The system will use these points to generate a precise contour around the object.</li>
              <li><strong>4. Create New Box:</strong> If no box is detected for an object, click <strong>"+ New Box"</strong> in the list. Click on the image to place control points, then click <strong>"Create Box"</strong> to generate a new detection.</li>
              <li><strong>5. Remove Box:</strong> If a detection is incorrect, click the <strong>"Remove"</strong> button next to the box in the list to delete it.</li>
            </ul>
          </div>
          {/* -------------------------------------- */}

          {isCreatingNewBox && (
            <div className='alert alert-info mb-2'>
              <span>Click on the image to add control points for the new box. </span>
              <button className='btn btn-sm btn-success ms-2' onClick={createNewBox}>Create Box</button>
              <button className='btn btn-sm btn-secondary ms-1' onClick={cancelNewBox}>Cancel</button>
            </div>
          )}

          {selectedBoxId !== null && !isCreatingNewBox && (
            <div className='alert alert-info mb-2'>
              <span>Click inside the selected box to add SAM control points. </span>
              <button
                className='btn btn-sm btn-success ms-2'
                onClick={updateSamContours}
                disabled={samPoints[selectedBoxId].length === 0}
              >
                Update Contour
              </button>
              <button
                className='btn btn-sm btn-secondary ms-1'
                onClick={() => setSamPoints({ ...samPoints, [selectedBoxId]: [] })}
                disabled={samPoints[selectedBoxId].length === 0}
              >
                Clear Points
              </button>
            </div>
          )}

          <Stage
            width={dimensions.width}
            height={dimensions.height}
            scaleX={stageScale}
            scaleY={stageScale}
            ref={stageRef}
            onClick={handleStageClick}
            style={{ border: '1px solid #ddd', cursor: isCreatingNewBox ? 'crosshair' : 'default' }}
          >
            <Layer>
              <KonvaImage
                image={image}
                width={image.width}
                height={image.height}
                x={0}
                y={0}
              />

              {/* Render all boxes */}
              {/* {boxes.map(box => renderBox(box))} */}

              {/* Render contours for all boxes */}
              {boxes.map(box => renderContour(box))}

              {/* Render SAM points for selected box */}
              {selectedBoxId !== null && samPoints[selectedBoxId].map((point, idx) => (
                <KonvaCircle
                  key={`sam-${idx}`}
                  x={point[0]}
                  y={point[1]}
                  radius={4 / stageScale}
                  fill='red'
                  opacity={0.8}
                  onClick={(e) => {
                    e.cancelBubble = true
                    removeSamPoint(idx)
                  }}
                />
              ))}

              {/* Render new box points */}
              {isCreatingNewBox && newBoxPoints.map((point, idx) => (
                <KonvaCircle
                  key={`new-${idx}`}
                  x={point[0]}
                  y={point[1]}
                  radius={8 / stageScale}
                  fill='green'
                  opacity={0.8}
                  onClick={(e) => {
                    e.cancelBubble = true
                    setNewBoxPoints(newBoxPoints.filter((p, id) => id !== idx))
                  }}
                />
              ))}
            </Layer>
          </Stage>
        </div>
      </div>

      {/* Right side - Box list */}
      <div className='col-md-4'>
        <div className='card'>
          <div className='d-flex justify-content-between align-items-center mb-2'>
            <h4>Detected Boxes</h4>
            <button
              className='btn btn-sm btn-primary'
              onClick={() => {
                setIsCreatingNewBox(true)
                setSelectedBoxId(null)
                setSamPoints([])
              }}
              disabled={isCreatingNewBox}
            >
              + New Box
            </button>
          </div>

          <div className='list-group' style={{ maxHeight: '600px', overflowY: 'auto' }}>
            {boxes.map((box) => (
              <React.Fragment key={box.id}>
                <div
                  className='d-flex align-items-center list-group-item list-group-item-action'
                  style={{ cursor: 'pointer' }}
                  onClick={() => {
                    setSelectedBoxId(box.id)
                    setIsCreatingNewBox(false)
                  }}
                >
                  <div className='flex-grow-1'>
                    <div className='d-flex justify-content-between align-items-center'>
                      <span className='font-weight-bold'>{box.type || 'Unknown'}</span>
                      <span className='badge bg-secondary'>#{box.id + 1}</span>
                    </div>
                    {box.contour && box.contour.length > 0 && (
                      <div className='mt-1'>
                        <span className='badge bg-info'>Has Contour</span>
                      </div>
                    )}
                  </div>
                  <button
                    className='btn btn-outline-danger btn-sm ms-2' onClick={(e) => {
                      e.stopPropagation()

                      setBoxes(boxes.filter(filterBox => filterBox.id !== box.id))
                    }}
                  >
                    Remove
                  </button>
                </div>
              </React.Fragment>
            ))}
          </div>

          {boxes.length === 0 && (
            <div className='text-center text-muted py-4'>
              <p>No boxes detected.</p>
              <button
                className='btn btn-primary'
                onClick={() => setIsCreatingNewBox(true)}
              >
                Create New Box
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
