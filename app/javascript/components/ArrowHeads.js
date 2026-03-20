import React, { useState, useRef, useEffect } from 'react'
import { Stage, Layer, Rect, Image as KonvaImage, Line, Circle as KonvaCircle } from 'react-konva'
import { Box } from './BoxCanvas'
import UploadStep from './arrowheads/UploadStep'
import LoadingDialog from './arrowheads/LoadingDialog'

/**
 * Convert box data from API format to internal format
 * API format: { box: [x1, y1, x2, y2], contour: [[x, y], ...], type: string }
 */
function normalizeBox (boxData, index) {
  const [x1, y1, x2, y2] = boxData.box
  return {
    id: index,
    index,
    x1,
    y1,
    x2,
    y2,
    type: boxData.label,
    contour: boxData.contour || []
  }
}

function Contours ({ boxes: initialBoxes, image, onNext, onBack, imageFile }) {
  const [boxes, setBoxes] = useState(() => initialBoxes.map((b, i) => normalizeBox(b, i)))
  const [selectedBoxId, setSelectedBoxId] = useState(null)
  const [samPoints, setSamPoints] = useState([])
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

    // Convert to image coordinates
    const x = pointer.x / stageScale
    const y = pointer.y / stageScale

    if (isCreatingNewBox) {
      setNewBoxPoints(prev => [...prev, [x, y]])
    } else if (selectedBoxId !== null) {
      // if (x >= selectedBox.x1 && x <= selectedBox.x2 && y >= selectedBox.y1 && y <= selectedBox.y2) {
      setSamPoints([...samPoints, [Math.round(x), Math.round(y)]])
      // }
    }
  }

  // Remove a SAM point
  const removeSamPoint = (index) => {
    setSamPoints(prev => prev.filter((_, i) => i !== index))
  }

  // Update SAM contours for the selected box
  const updateSamContours = async () => {
    if (!selectedBox || samPoints.length === 0) return

    try {
      setLoading(true)

      const formData = new FormData()
      formData.append('image', imageFile)
      formData.append('points', JSON.stringify(samPoints))

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
      setSamPoints([])
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

      const response = await fetch('/size_figures/new_box', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          points: newBoxPoints,
          image: image.src || image.url // Use the image data
        })
      })

      if (!response.ok) throw new Error('Failed to create new box')

      const result = await response.json()
      const newBox = normalizeBox(result, boxes.length)
      setBoxes(prev => [...prev, newBox])
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
              <button className='btn btn-default' onClick={onBack}>Back</button>
              <button className='btn btn-default' onClick={onNext}>Next</button>
            </div>
          </div>

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
                disabled={samPoints.length === 0}
              >
                Update Contour
              </button>
              <button
                className='btn btn-sm btn-secondary ms-1'
                onClick={() => setSamPoints([])}
                disabled={samPoints.length === 0}
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
              {selectedBoxId !== null && samPoints.map((point, idx) => (
                <KonvaCircle
                  key={`sam-${idx}`}
                  x={point[0]}
                  y={point[1]}
                  radius={8 / stageScale}
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
              <button
                key={box.id}
                className={`list-group-item list-group-item-action ${selectedBoxId === box.id ? 'active' : ''}`}
                onClick={() => {
                  setSelectedBoxId(box.id)
                  setSamPoints([])
                  setIsCreatingNewBox(false)
                }}
              >
                <div className='d-flex justify-content-between align-items-center'>
                  <span className='font-weight-bold'>{box.type || 'Unknown'}</span>
                  <span className='badge bg-secondary'>#{box.id + 1}</span>
                </div>
                {box.contour && box.contour.length > 0 && (
                  <div className='mt-1'>
                    <span className='badge bg-info'>Has Contour</span>
                  </div>
                )}
              </button>
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

function TableExport () {

}

export default function () {
  const [currentStep, setCurrentStep] = useState(0)
  const [boxes, setBoxes] = useState([]) // boxes returned from /size_figures/boxes
  const [uploading, setUploading] = useState(false)
  const [image, setImage] = useState(null)
  const [imageFile, setImageFile] = useState(null)

  async function uploadImage (file, objectType) {
    const formData = new FormData()
    formData.append('image', file)
    formData.append('object_type', objectType)

    try {
    // Send the request
      const response = await fetch('/size_figures/boxes', {
        method: 'POST',
        body: formData
      // Optional: add headers if your API expects them
      // headers: { 'Accept': 'application/json' },
      })

      // Check for HTTP errors
      if (!response.ok) {
        const errorText = await response.text()
        throw new Error(`Upload failed: ${errorText}`)
      }

      // Parse JSON (or whatever your endpoint returns)
      const result = await response.json()
      return result // e.g., { url: 'https://...', id: 123 }
    } catch (err) {
      console.error('Error uploading image:', err)
      throw err // Re‑throw so callers can handle it
    } finally {
      setUploading(false)
    }
  }

  /* ---------- step navigation ---------- */
  const goNext = async (payload) => {
    if (payload && payload.file) {
      const imageUrl = URL.createObjectURL(payload.file)
      const imageObject = new Image()
      imageObject.src = imageUrl
      setImage(imageObject)
      setUploading(true)
      try {
        const res = await uploadImage(payload.file)
        setBoxes(res.boxes || []) // store the boxes for the next step
      } catch (e) {
        console.error(e)
        // You could add an error state here and show a message to the user
      }
      setCurrentStep((s) => s + 1)
    } else {
      setCurrentStep((s) => s + 1)
    }
  }

  const goNextWithObjectType = async (file, objectType) => {
    if (file) {
      const imageUrl = URL.createObjectURL(file)
      const imageObject = new Image()
      imageObject.src = imageUrl
      setImage(imageObject)
      setImageFile(file)
      setUploading(true)
      try {
        const res = await uploadImage(file, objectType)
        setBoxes(res.boxes || []) // store the boxes for the next step
      } catch (e) {
        console.error(e)
        // You could add an error state here and show a message to the user
      }
      setCurrentStep((s) => s + 1)
    } else {
      setCurrentStep((s) => s + 1)
    }
  }

  const goBack = () => setCurrentStep((s) => Math.max(0, s - 1))

  const steps = [
    <UploadStep
      key='upload'
      onNext={(file, objectType) => goNextWithObjectType(file, objectType)}
    />,
    <Contours
      key='select'
      boxes={boxes}
      image={image}
      imageFile={imageFile}
      onNext={goNext}
      onBack={goBack}
    />,
    <TableExport
      key='export'
      onBack={goBack}
    />
  ]

  return (
    <div className='upload-wizard'>
      <h2>Step {currentStep + 1} of {steps.length}</h2>

      {uploading && (
        <div className='progress-container' style={{ marginBottom: '1rem' }}>
          <progress style={{ width: '100%' }} />
          <span>Processing Image ....</span>
        </div>
      )}

      {steps[currentStep]}
    </div>
  )
}
